class_name CombatEncounter
extends RefCounted
## Real-time, cooldown-driven encounter. The presentation layer feeds elapsed
## time in via advance_time(delta) and forwards player choices via try_attack()
## / try_change_stance(); everything else -- enemy behavior, passive defense,
## Balance, skill XP -- resolves in here. Pure GDScript, no engine dependencies.
## See Docs/04_Combat_Design.md and Docs/11_Balance_Bible.md.
##
## Player actions share ONE cooldown gate: any action locks all actions for
## that action's duration (CombatAction.COOLDOWN_SECONDS). The enemy runs its
## own independent clock: circle -> telegraph -> strike -> cooldown -> repeat,
## with retreat and Howl woven in at transition points.
##
## First-pass simplifications, deliberately not full AI/positioning design:
## - Circling/retreating are timers, not a spatial system ("re-engages if
##   cornered" is simplified to "retreat expires").
## - Retreat/mid-fight-Howl conditions are only checked at enemy state
##   transitions, not continuously.
## - Enemy Stamina isn't modeled; the Wolf's Emboldened state still isn't.

enum EnemyPhase { CIRCLING, TELEGRAPHING_ATTACK, TELEGRAPHING_HOWL, RETREATING, RECOVERING }

var player: Combatant
var player_sheet: CharacterSheet
var enemy: Combatant
var enemy_data: EnemyData
var rng: RandomNumberGenerator

var elapsed_time: float = 0.0
## Shared tug-of-war meter: 100 = player in full control, 0 = enemy in full
## control. Starts neutral. See Docs/04_Combat_Design.md (Balance).
var balance: int = ThreatAndBalance.BALANCE_NEUTRAL

var player_cooldown_remaining: float = 0.0
var player_cooldown_total: float = 0.0  # duration of the current lockout, for UI ratios

var enemy_phase: EnemyPhase
var enemy_phase_remaining: float = 0.0

var _has_retreated: bool = false
var _howl_used_start: bool = false
var _howl_used_mid: bool = false

func _init(
	p_player: Combatant,
	p_player_sheet: CharacterSheet,
	p_enemy: Combatant,
	p_enemy_data: EnemyData,
	p_rng: RandomNumberGenerator
) -> void:
	player = p_player
	player_sheet = p_player_sheet
	enemy = p_enemy
	enemy_data = p_enemy_data
	rng = p_rng
	if enemy_data.has_howl:
		_howl_used_start = true
		_set_enemy_phase(EnemyPhase.TELEGRAPHING_HOWL, enemy_data.howl_telegraph_seconds)
	elif enemy_data.circling_seconds > 0.0:
		_set_enemy_phase(EnemyPhase.CIRCLING, enemy_data.circling_seconds)
	else:
		_set_enemy_phase(EnemyPhase.TELEGRAPHING_ATTACK, enemy_data.telegraph_seconds)

static func create(player_sheet: CharacterSheet, enemy_data: EnemyData, rng: RandomNumberGenerator) -> CombatEncounter:
	var player_combatant := Combatant.new(
		player_sheet.character_name, player_sheet.attributes.max_hp(), player_sheet.attributes.max_stamina()
	)
	var enemy_combatant := Combatant.new(enemy_data.display_name, enemy_data.max_hp, 0)
	return CombatEncounter.new(player_combatant, player_sheet, enemy_combatant, enemy_data, rng)

func is_over() -> bool:
	return not player.is_alive() or not enemy.is_alive()

## "" while the fight is ongoing, otherwise "player" or "enemy".
func winner() -> String:
	if not player.is_alive():
		return "enemy"
	if not enemy.is_alive():
		return "player"
	return ""

func can_act() -> bool:
	return player_cooldown_remaining <= 0.0 and not is_over()

## Advances the simulation. Returns an Array of event strings for the log.
func advance_time(delta: float) -> Array:
	var events: Array = []
	if is_over() or delta <= 0.0:
		return events
	elapsed_time += delta
	player_cooldown_remaining = maxf(player_cooldown_remaining - delta, 0.0)
	player.regen_stamina(delta)

	enemy_phase_remaining -= delta
	# A large delta can span several phases; carry leftover time into each next
	# phase so timings stay exact regardless of step size.
	while enemy_phase_remaining <= 0.0 and not is_over():
		_on_enemy_phase_end(events)
	return events

## Attempts an attack. No-op (empty Array) while on cooldown or after the
## fight has ended.
func try_attack(is_heavy: bool) -> Array:
	var events: Array = []
	if not can_act():
		return events
	var action := CombatAction.Action.HEAVY_ATTACK if is_heavy else CombatAction.Action.ATTACK
	_start_cooldown(action)
	player.spend_stamina(CombatAction.stamina_cost(action) * player_sheet.equipped_weapon.stamina_cost_modifier)

	if EnemyRules.roll_evades(enemy_data, rng):
		events.append("%s attacks but %s slips aside!" % [player_sheet.character_name, enemy_data.display_name])
		return events

	var blades_level: int = player_sheet.get_skill(player_sheet.equipped_weapon.trained_skill).level
	var damage := DamageCalculator.calculate_attack_damage(
		player_sheet.equipped_weapon, blades_level, player.position, is_heavy, 0, player.is_low_stamina(), rng
	)
	var precision_level: int = player_sheet.get_skill("Precision").level
	if DamageCalculator.roll_crit(DamageCalculator.crit_chance(precision_level, player.position), rng):
		damage = DamageCalculator.apply_crit(damage)
		events.append("Critical hit!")

	enemy.take_damage(damage)
	events.append("%s hits %s for %d damage." % [player_sheet.character_name, enemy_data.display_name, damage])
	balance = ThreatAndBalance.apply_delta(balance, ThreatAndBalance.BALANCE_ON_HIT_LANDED)
	var gain := SkillGainTable.for_landed_attack(player_sheet.equipped_weapon.trained_skill, is_heavy)
	_grant_skill_xp(gain["skill"], gain["bucket_xp"])

	if not enemy.is_alive():
		events.append("%s falls!" % enemy_data.display_name)
	return events

## Attempts a stance change. No-op while on cooldown, after the fight, or if
## already in that stance.
func try_change_stance(stance: CombatPosition.Position) -> Array:
	var events: Array = []
	if not can_act() or player.position == stance:
		return events
	_start_cooldown(CombatAction.Action.CHANGE_STANCE)
	player.spend_stamina(CombatAction.stamina_cost(CombatAction.Action.CHANGE_STANCE))
	player.position = stance
	events.append("%s shifts stance." % player_sheet.character_name)
	return events

func _start_cooldown(action: CombatAction.Action) -> void:
	player_cooldown_total = CombatAction.cooldown_seconds(action)
	player_cooldown_remaining = player_cooldown_total

func _set_enemy_phase(phase: EnemyPhase, duration: float) -> void:
	enemy_phase = phase
	# Carry any overshoot from the previous phase (enemy_phase_remaining is
	# <= 0 at transition time) so long deltas don't drift the schedule.
	enemy_phase_remaining += duration

func _on_enemy_phase_end(events: Array) -> void:
	match enemy_phase:
		EnemyPhase.CIRCLING:
			events.append("%s stops circling and tenses to strike..." % enemy_data.display_name)
			_set_enemy_phase(EnemyPhase.TELEGRAPHING_ATTACK, enemy_data.telegraph_seconds)
		EnemyPhase.TELEGRAPHING_ATTACK:
			_resolve_enemy_attack(events)
			_choose_post_action_phase(events)
		EnemyPhase.TELEGRAPHING_HOWL:
			events.append("%s howls, seizing full control of the fight!" % enemy_data.display_name)
			balance = ThreatAndBalance.BALANCE_MIN
			_set_enemy_phase(EnemyPhase.RECOVERING, enemy_data.attack_cooldown_seconds)
		EnemyPhase.RETREATING:
			events.append("%s turns and re-engages!" % enemy_data.display_name)
			_set_enemy_phase(EnemyPhase.TELEGRAPHING_ATTACK, enemy_data.telegraph_seconds)
		EnemyPhase.RECOVERING:
			_choose_next_aggression(events)

func _choose_post_action_phase(events: Array) -> void:
	if is_over():
		return
	if _should_howl_mid():
		_howl_used_mid = true
		events.append("%s throws back its head..." % enemy_data.display_name)
		_set_enemy_phase(EnemyPhase.TELEGRAPHING_HOWL, enemy_data.howl_telegraph_seconds)
		return
	if not _has_retreated and EnemyRules.should_retreat(enemy_data, enemy.current_hp):
		_has_retreated = true
		events.append("%s backs away, wary." % enemy_data.display_name)
		_set_enemy_phase(EnemyPhase.RETREATING, enemy_data.retreat_seconds)
		return
	_set_enemy_phase(EnemyPhase.RECOVERING, enemy_data.attack_cooldown_seconds)

func _choose_next_aggression(events: Array) -> void:
	if _should_howl_mid():
		_howl_used_mid = true
		events.append("%s throws back its head..." % enemy_data.display_name)
		_set_enemy_phase(EnemyPhase.TELEGRAPHING_HOWL, enemy_data.howl_telegraph_seconds)
		return
	if not _has_retreated and EnemyRules.should_retreat(enemy_data, enemy.current_hp):
		_has_retreated = true
		events.append("%s backs away, wary." % enemy_data.display_name)
		_set_enemy_phase(EnemyPhase.RETREATING, enemy_data.retreat_seconds)
		return
	events.append("%s tenses to strike..." % enemy_data.display_name)
	_set_enemy_phase(EnemyPhase.TELEGRAPHING_ATTACK, enemy_data.telegraph_seconds)

func _should_howl_mid() -> bool:
	return enemy_data.has_howl and not _howl_used_mid \
		and enemy.current_hp <= int(enemy_data.max_hp / 2.0)

## The telegraphed attack lands: run the passive Parry -> Dodge -> Block checks
## (DefenseRules) -- no player input involved.
func _resolve_enemy_attack(events: Array) -> void:
	var outcome := DefenseRules.resolve(
		player_sheet.get_skill("Parry").level,
		player_sheet.get_skill("Evasion").level,
		player_sheet.get_skill("Guard").level,
		enemy_data.attack_skill,
		player.position,
		balance,
		player.is_low_stamina(),
		player_sheet.equipped_weapon.can_parry,
		rng
	)
	var raw_damage := EnemyRules.roll_bite_damage(enemy_data, enemy.current_hp, rng)
	var final_damage := int(round(raw_damage * outcome["damage_multiplier"]))

	match outcome["result"]:
		"parry":
			events.append("You parry the %s's bite!" % enemy_data.display_name)
		"dodge":
			events.append("You twist away from the %s's bite!" % enemy_data.display_name)
		"guard":
			events.append("You block -- the bite lands for a reduced %d damage." % final_damage)
		"hit":
			events.append("%s bites %s for %d damage!" % [enemy_data.display_name, player_sheet.character_name, final_damage])

	player.spend_stamina(outcome["stamina_cost"])
	if final_damage > 0:
		player.take_damage(final_damage)
	balance = ThreatAndBalance.apply_delta(balance, outcome["balance_delta"])
	if outcome["trained_skill"] != "":
		_grant_skill_xp(outcome["trained_skill"], outcome["bucket_xp"])

	if not player.is_alive():
		events.append("%s falls..." % player_sheet.character_name)

func _grant_skill_xp(skill_name: String, bucket_xp: float) -> void:
	var skill := player_sheet.get_skill(skill_name)
	skill.add_bucket_xp(bucket_xp, player_sheet.attributes.skill_bucket_cap())
