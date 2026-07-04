class_name CombatEncounter
extends RefCounted
## Orchestrates a turn-by-turn Sword-vs-Wolf/Dire-Wolf fight, one round per
## resolve_round() call, using the rest of the game/combat and game/skills
## rules layer. See Docs/04_Combat_Design.md and Docs/11_Balance_Bible.md.
##
## First-pass simplifications, clearly not full AI/positioning design:
## - Circling and Retreating are plain round counters, not a spatial/cornering
##   system ("re-engages if cornered" isn't modeled -- retreat just expires).
## - Defense resolution (does Parry/Dodge/Guard actually stop the incoming
##   Bite) wasn't specified anywhere in the Balance Bible; this implements a
##   deterministic first pass (correct defensive choice during the attack's
##   round succeeds outright, no separate chance roll) documented in
##   Docs/11_Balance_Bible.md under "Defense Resolution (Prototype)".
## - Enemy Stamina isn't modeled -- only the player has a Stamina pool.

const CIRCLING_ROUNDS := 2       # Docs/11_Balance_Bible.md: "circles for the first 2 rounds"
const RETREAT_DURATION_ROUNDS := 3  # first-pass number for Balance Bible's "several rounds"

var player: Combatant
var player_sheet: CharacterSheet
var enemy: Combatant
var enemy_data: EnemyData
var rng: RandomNumberGenerator

var round_number: int = 0
var current_intent: EnemyIntent.Intent
## Shared tug-of-war meter: 100 = player in full control, 0 = enemy in full
## control. Starts neutral. See Docs/04_Combat_Design.md (Balance).
var balance: int = ThreatAndBalance.BALANCE_NEUTRAL

var _circling_rounds_remaining: int
var _retreating_rounds_remaining: int = 0
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
	_circling_rounds_remaining = CIRCLING_ROUNDS if enemy_data.circles_before_engaging else 0
	_decide_next_intent()

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

## Resolves one full round: the player's action, then the enemy's telegraphed
## intent, then Stamina regen and the enemy's next intent. `target_position`
## is only used when `player_action` is REPOSITION.
func resolve_round(player_action: CombatAction.Action, target_position = null) -> Array:
	var log: Array = []
	round_number += 1

	if player_action == CombatAction.Action.REPOSITION and target_position != null:
		player.position = target_position

	var cost := int(round(CombatAction.stamina_cost(player_action) * player_sheet.equipped_weapon.stamina_cost_modifier))
	player.spend_stamina(cost)

	if player_action == CombatAction.Action.ATTACK or player_action == CombatAction.Action.HEAVY_ATTACK:
		_resolve_player_attack(player_action, log)

	if enemy.is_alive():
		_resolve_enemy_intent(player_action, log)

	player.regen_stamina(player_action == CombatAction.Action.GUARD)

	if not is_over():
		_decide_next_intent()

	return log

func _resolve_player_attack(action: CombatAction.Action, log: Array) -> void:
	if EnemyRules.roll_evades(enemy_data, rng):
		log.append("%s attacks but %s evades!" % [player_sheet.character_name, enemy_data.display_name])
		return

	var is_heavy := action == CombatAction.Action.HEAVY_ATTACK
	var blades_level: int = player_sheet.get_skill("Blades").level
	var damage := DamageCalculator.calculate_attack_damage(
		player_sheet.equipped_weapon, blades_level, player.position, is_heavy, 0, player.is_low_stamina(), rng
	)

	var precision_level: int = player_sheet.get_skill("Precision").level
	var chance := DamageCalculator.crit_chance(precision_level, player.position)
	if DamageCalculator.roll_crit(chance, rng):
		damage = DamageCalculator.apply_crit(damage)
		log.append("Critical hit!")

	enemy.take_damage(damage)
	log.append("%s hits %s for %d damage." % [player_sheet.character_name, enemy_data.display_name, damage])
	balance = ThreatAndBalance.apply_delta(balance, ThreatAndBalance.BALANCE_ON_HIT_LANDED)
	_grant_skill_xp(action)

func _resolve_enemy_intent(player_action: CombatAction.Action, log: Array) -> void:
	match current_intent:
		EnemyIntent.Intent.CIRCLING:
			log.append("%s circles, watching for an opening." % enemy_data.display_name)
		EnemyIntent.Intent.RETREATING:
			log.append("%s backs away, wary." % enemy_data.display_name)
		EnemyIntent.Intent.TELEGRAPHING_BITE:
			log.append("%s lunges!" % enemy_data.display_name)
		EnemyIntent.Intent.TELEGRAPHING_HOWL:
			log.append("%s throws back its head, preparing to howl!" % enemy_data.display_name)
		EnemyIntent.Intent.BITE:
			_resolve_bite(player_action, log)
		EnemyIntent.Intent.HOWL:
			log.append("%s howls, seizing full control of the fight!" % enemy_data.display_name)
			balance = ThreatAndBalance.BALANCE_MIN

## Defense Resolution (Prototype) -- see Docs/11_Balance_Bible.md.
func _resolve_bite(player_action: CombatAction.Action, log: Array) -> void:
	var raw_bite := EnemyRules.roll_bite_damage(enemy_data, enemy.current_hp, rng)
	var final_damage := raw_bite

	match player_action:
		CombatAction.Action.PARRY:
			if player_sheet.equipped_weapon.can_parry:
				final_damage = 0
				log.append("Parried the %s's bite!" % enemy_data.display_name)
				balance = ThreatAndBalance.apply_delta(balance, ThreatAndBalance.BALANCE_ON_SUCCESSFUL_PARRY)
				_grant_skill_xp(CombatAction.Action.PARRY)
			else:
				log.append("Can't parry with this weapon -- the bite lands!")
		CombatAction.Action.DODGE:
			final_damage = 0
			log.append("Dodged the %s's bite!" % enemy_data.display_name)
			balance = ThreatAndBalance.apply_delta(balance, ThreatAndBalance.BALANCE_ON_SUCCESSFUL_DODGE)
			_grant_skill_xp(CombatAction.Action.DODGE)
		CombatAction.Action.GUARD:
			var reduction := 0.5
			if player.is_low_stamina():
				reduction *= StaminaRules.LOW_STAMINA_MULTIPLIER
			final_damage = int(round(raw_bite * (1.0 - reduction)))
			log.append("Guarded -- the bite lands for a reduced %d damage." % final_damage)
			_grant_skill_xp(CombatAction.Action.GUARD)
		_:
			log.append("%s bites %s for %d damage!" % [enemy_data.display_name, player_sheet.character_name, final_damage])

	if final_damage > 0:
		player.take_damage(final_damage)
		balance = ThreatAndBalance.apply_delta(balance, ThreatAndBalance.BALANCE_ON_HIT_TAKEN)

func _grant_skill_xp(action: CombatAction.Action) -> void:
	var gain := SkillGainTable.for_action(action, true)
	if gain.is_empty():
		return
	var skill := player_sheet.get_skill(gain["skill"])
	skill.add_bucket_xp(gain["bucket_xp"], player_sheet.attributes.skill_bucket_cap())

## A TELEGRAPHING_* intent always resolves into its real counterpart the very
## next round; otherwise, priority is Retreating > Circling > Howl > Bite.
func _decide_next_intent() -> void:
	if current_intent == EnemyIntent.Intent.TELEGRAPHING_BITE:
		current_intent = EnemyIntent.Intent.BITE
		return
	if current_intent == EnemyIntent.Intent.TELEGRAPHING_HOWL:
		current_intent = EnemyIntent.Intent.HOWL
		return

	if _retreating_rounds_remaining > 0:
		_retreating_rounds_remaining -= 1
		current_intent = EnemyIntent.Intent.RETREATING
		return
	if _circling_rounds_remaining > 0:
		_circling_rounds_remaining -= 1
		current_intent = EnemyIntent.Intent.CIRCLING
		return
	if enemy_data.has_howl and not _howl_used_start:
		_howl_used_start = true
		current_intent = EnemyIntent.Intent.TELEGRAPHING_HOWL
		return
	if enemy_data.has_howl and not _howl_used_mid and enemy.current_hp <= int(enemy_data.max_hp / 2.0):
		_howl_used_mid = true
		current_intent = EnemyIntent.Intent.TELEGRAPHING_HOWL
		return
	if enemy_data.retreats_at_low_hp and not _has_retreated and EnemyRules.should_retreat(enemy_data, enemy.current_hp):
		_has_retreated = true
		_retreating_rounds_remaining = RETREAT_DURATION_ROUNDS - 1
		current_intent = EnemyIntent.Intent.RETREATING
		return
	current_intent = EnemyIntent.Intent.TELEGRAPHING_BITE
