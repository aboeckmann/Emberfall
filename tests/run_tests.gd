extends SceneTree
## Minimal ad-hoc verification of the game/ rules layer against the worked
## values in Docs/11_Balance_Bible.md. Not a real test framework -- test
## conventions for the rules layer are still TBD (02_Technical_Design_Document.md).
## Run with: godot --headless --script res://tests/run_tests.gd

var failures := 0
var _screen: Control = null

func _initialize() -> void:
	_test_attributes()
	_test_skill_xp_curve()
	_test_skill_bucket()
	_test_stamina_rules()
	_test_defense_rules()
	_test_equipment_data()
	_test_damage_formula()
	_test_crit_chance()
	_test_threat_and_balance()
	_test_enemy_data()
	_test_character_sheet()
	_test_combat_encounter_wolf_timeline()
	_test_combat_encounter_player_cooldowns()
	_test_combat_encounter_dire_wolf_howl()
	_test_combat_encounter_reaches_a_winner()

	# The combat screen needs a running tree for _ready to fire (nodes added
	# during _initialize aren't in the tree yet -- the root itself isn't).
	# Instance it here; the smoke test runs on the first process frame.
	print("Combat screen (smoke test)")
	var packed: PackedScene = load("res://scenes/combat/combat_screen.tscn")
	_check(packed != null, "combat_screen.tscn loads")
	if packed == null:
		_finish()
		return
	_screen = packed.instantiate()
	root.add_child(_screen)

func _process(_delta: float) -> bool:
	if _screen != null:
		_test_combat_screen_smoke(_screen)
		_screen.queue_free()
		_screen = null
		_finish()
	return false

func _finish() -> void:
	if failures == 0:
		print("\nALL TESTS PASSED")
	else:
		printerr("\n%d CHECK(S) FAILED" % failures)
	quit(1 if failures > 0 else 0)

func _check(condition: bool, message: String) -> void:
	if condition:
		print("  ok   - %s" % message)
	else:
		failures += 1
		printerr("  FAIL - %s" % message)

func _test_attributes() -> void:
	print("Attributes")
	var attrs := Attributes.new(10, 10, 10)
	_check(attrs.max_hp() == 100, "max_hp() at Vitality 10 == 100")
	_check(attrs.max_stamina() == 100, "max_stamina() at Vitality 10 == 100")
	_check(attrs.max_mana() == 100, "max_mana() at Willpower 10 == 100")
	_check(attrs.skill_bucket_cap() == 100, "skill_bucket_cap() at Intellect 10 == 100")

func _test_skill_xp_curve() -> void:
	print("Skill XP curve")
	_check(Skill.xp_required_for_level(0) == 0, "level 0->1 requires 0 xp")
	_check(Skill.xp_required_for_level(1) == 20, "level 1->2 requires 20 xp")
	_check(Skill.xp_required_for_level(2) == 57, "level 2->3 requires round(20*2^1.5) = 57 xp")

func _test_skill_bucket() -> void:
	print("Skill bucket")
	var blades := Skill.new("Blades")
	blades.add_bucket_xp(500.0, 100)
	_check(blades.bucket == 100.0, "bucket clamps to cap (100) even when overfed")
	blades.drain_bucket(1.0, 1.0)  # 100% rate for 1 minute -> fully drains
	_check(blades.bucket == 0.0, "a 100% drain empties the bucket")
	_check(blades.level >= 1, "draining 100 xp levels the skill up at least once (level=%d)" % blades.level)

	var slow := Skill.new("Parry")
	slow.add_bucket_xp(10.0, 100)
	slow.drain_bucket(Skill.PASSIVE_DRAIN_RATE, 1.0)
	_check(is_equal_approx(slow.bucket, 9.9), "passive drain (1%%/min) converts 1%% of the bucket per minute")

func _test_stamina_rules() -> void:
	print("Stamina rules")
	_check(StaminaRules.regen_per_second(CombatPosition.Position.BALANCED) == 4.0, "default regen is 4/s")
	_check(StaminaRules.regen_per_second(CombatPosition.Position.GUARDED) == 6.0, "Guarded stance regen is 6/s")
	_check(StaminaRules.is_low(19), "19 stamina counts as low")
	_check(not StaminaRules.is_low(20), "20 stamina does not count as low")
	_check(CombatAction.stamina_cost(CombatAction.Action.HEAVY_ATTACK) == 20.0, "heavy attack costs 20 stamina")
	_check(CombatAction.cooldown_seconds(CombatAction.Action.ATTACK) == 2.0, "attack triggers a 2s cooldown")
	_check(CombatAction.cooldown_seconds(CombatAction.Action.HEAVY_ATTACK) == 4.0, "heavy attack triggers a 4s cooldown")
	_check(CombatAction.cooldown_seconds(CombatAction.Action.CHANGE_STANCE) == 3.0, "stance change triggers a 3s cooldown")

func _test_defense_rules() -> void:
	print("Defense rules (passive checks)")
	var base := DefenseRules.check_chance(DefenseRules.PARRY_BASE_CHANCE, 0, 10, CombatPosition.Position.BALANCED, 50, false)
	_check(is_equal_approx(base, 0.15), "skill 0 vs attack skill 10, Balanced, neutral Balance: parry chance 15%% (was %f)" % base)
	var guarded := DefenseRules.check_chance(DefenseRules.GUARD_BASE_CHANCE, 0, 10, CombatPosition.Position.GUARDED, 50, false)
	_check(is_equal_approx(guarded, 0.35), "Guarded stance adds +15%% (block chance 35%%, was %f)" % guarded)
	var frontline := DefenseRules.check_chance(DefenseRules.DODGE_BASE_CHANCE, 0, 10, CombatPosition.Position.FRONTLINE, 50, false)
	_check(is_equal_approx(frontline, 0.0), "Frontline's -10%% floors the weakest check at 0 (was %f)" % frontline)
	var high_balance := DefenseRules.check_chance(DefenseRules.PARRY_BASE_CHANCE, 0, 10, CombatPosition.Position.BALANCED, 100, false)
	_check(is_equal_approx(high_balance, 0.25), "Balance 100 adds +10%% (was %f)" % high_balance)
	var capped := DefenseRules.check_chance(DefenseRules.PARRY_BASE_CHANCE, 100, 0, CombatPosition.Position.GUARDED, 100, false)
	_check(is_equal_approx(capped, DefenseRules.MAX_CHANCE_PER_CHECK), "chances cap at 60%% (was %f)" % capped)
	var tired := DefenseRules.check_chance(DefenseRules.PARRY_BASE_CHANCE, 0, 10, CombatPosition.Position.BALANCED, 50, true)
	_check(is_equal_approx(tired, 0.15 * 0.75), "low Stamina multiplies the chance by 0.75 (was %f)" % tired)

func _test_equipment_data() -> void:
	print("Equipment data (Sword resource)")
	var sword: WeaponData = load("res://data/weapons/sword.tres")
	_check(sword != null, "data/weapons/sword.tres loads")
	if sword:
		_check(sword.base_damage == 10, "Sword base_damage == 10")
		_check(sword.trained_skill == "Blades", "Sword trains Blades")
		_check(sword.can_parry, "Sword can parry")
		_check(sword.appearance != null and sword.appearance.equipment_type == "Sword", "Sword appearance.equipment_type == 'Sword'")

func _test_damage_formula() -> void:
	print("Damage formula (Sword)")
	var sword := WeaponData.new()
	sword.base_damage = 10
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var dmg := DamageCalculator.calculate_attack_damage(sword, 0, CombatPosition.Position.BALANCED, false, 0, false, rng)
	_check(dmg >= 8 and dmg <= 12, "skill 0 Balanced attack lands in [8,12] (was %d)" % dmg)
	var heavy := DamageCalculator.calculate_attack_damage(sword, 0, CombatPosition.Position.BALANCED, true, 0, false, rng)
	_check(heavy > dmg, "a heavy attack (%d) exceeds a normal attack (%d) at the same skill" % [heavy, dmg])
	var low_stam := DamageCalculator.calculate_attack_damage(sword, 0, CombatPosition.Position.BALANCED, false, 0, true, rng)
	_check(low_stam < dmg + 2, "low-Stamina damage is reduced relative to a full-Stamina attack")

func _test_crit_chance() -> void:
	print("Crit chance")
	var base := DamageCalculator.crit_chance(0, CombatPosition.Position.BALANCED)
	_check(is_equal_approx(base, 0.05), "base crit chance is 5%% (was %f)" % base)
	var flanking := DamageCalculator.crit_chance(0, CombatPosition.Position.FLANKING)
	_check(is_equal_approx(flanking, 0.15), "flanking adds +10%% crit chance (was %f)" % flanking)
	var precise := DamageCalculator.crit_chance(50, CombatPosition.Position.BALANCED)
	_check(is_equal_approx(precise, 0.15), "50 Precision adds +10%% crit chance (was %f)" % precise)

func _test_threat_and_balance() -> void:
	print("Threat and Balance")
	_check(is_equal_approx(ThreatAndBalance.calculate_threat(10, 0), 10.0), "threat with 0 Presence == raw damage")
	_check(is_equal_approx(ThreatAndBalance.calculate_threat(10, 50), 15.0), "50 Presence adds +50%% threat")
	_check(ThreatAndBalance.BALANCE_NEUTRAL == 50, "neutral Balance is 50")
	_check(ThreatAndBalance.apply_delta(95, 10) == 100, "Balance clamps at 100")
	_check(ThreatAndBalance.apply_delta(5, -15) == 0, "Balance clamps at 0")
	_check(ThreatAndBalance.has_bonus_action_available(75), "Balance 75 unlocks the bonus action")
	_check(not ThreatAndBalance.has_bonus_action_available(74), "Balance 74 does not")
	_check(not ThreatAndBalance.has_bonus_action_available(ThreatAndBalance.BALANCE_NEUTRAL), "the neutral starting Balance does not unlock the bonus action")

func _test_enemy_data() -> void:
	print("Enemy data (Wolf / Dire Wolf resources)")
	var wolf: EnemyData = load("res://data/enemies/wolf.tres")
	_check(wolf != null and wolf.max_hp == 60, "Wolf loads with 60 HP")
	var dire_wolf: EnemyData = load("res://data/enemies/dire_wolf.tres")
	_check(dire_wolf != null and dire_wolf.max_hp == 220, "Dire Wolf loads with 220 HP")
	if dire_wolf:
		_check(not EnemyRules.is_enraged(dire_wolf, 100), "Dire Wolf at 100/220 HP is not yet enraged")
		_check(EnemyRules.is_enraged(dire_wolf, 60), "Dire Wolf at 60/220 HP (<=33%%) is enraged")
		var rng := RandomNumberGenerator.new()
		rng.seed = 2
		var enraged_bite := EnemyRules.roll_bite_damage(dire_wolf, 60, rng)
		var guaranteed_enraged_floor := int(round(dire_wolf.bite_damage_min * dire_wolf.enrage_damage_multiplier))
		_check(enraged_bite >= guaranteed_enraged_floor, "enraged bite damage (%d) respects the enrage-multiplied floor (%d)" % [enraged_bite, guaranteed_enraged_floor])

func _test_character_sheet() -> void:
	print("Character creation (Prototype-minimal)")
	var sword: WeaponData = load("res://data/weapons/sword.tres")
	var sheet := CharacterSheet.create_new("Test Hero", sword)
	_check(sheet.attributes.intellect == 10, "new character starts with placeholder Intellect 10")
	_check(sheet.get_skill("Blades").level == 0, "new character's Blades skill starts at level 0")
	_check(sheet.is_guildless(), "new character starts guildless")
	_check(sheet.renown == 0, "new character starts with 0 Renown")
	_check(sheet.equipped_weapon == sword, "new character is equipped with the given starting weapon")

func _make_encounter(enemy_path: String, seed_value: int) -> CombatEncounter:
	var sword: WeaponData = load("res://data/weapons/sword.tres")
	var sheet := CharacterSheet.create_new("Test Hero", sword)
	var enemy_data: EnemyData = load(enemy_path)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return CombatEncounter.create(sheet, enemy_data, rng)

func _test_combat_encounter_wolf_timeline() -> void:
	print("Combat encounter (Wolf real-time timeline)")
	var encounter := _make_encounter("res://data/enemies/wolf.tres", 10)
	_check(encounter.enemy_phase == CombatEncounter.EnemyPhase.CIRCLING, "Wolf opens by circling")

	encounter.advance_time(3.9)  # circling lasts 4.0s
	_check(encounter.enemy_phase == CombatEncounter.EnemyPhase.CIRCLING, "still circling at 3.9s")
	_check(encounter.player.current_hp == encounter.player.max_hp, "no damage while circling")

	encounter.advance_time(0.2)  # crosses 4.0s
	_check(encounter.enemy_phase == CombatEncounter.EnemyPhase.TELEGRAPHING_ATTACK, "circling ends into an attack telegraph")
	_check(encounter.player.current_hp == encounter.player.max_hp, "telegraph itself deals no damage")

	var events := encounter.advance_time(1.5)  # telegraph is 1.5s; attack resolves
	var attack_resolved := false
	for e in events:
		if "bite" in str(e).to_lower() or "parry" in str(e).to_lower() or "twist" in str(e).to_lower() or "block" in str(e).to_lower():
			attack_resolved = true
	_check(attack_resolved, "the telegraphed attack resolves after the telegraph elapses (events: %s)" % str(events))
	_check(encounter.enemy_phase != CombatEncounter.EnemyPhase.TELEGRAPHING_ATTACK, "the enemy moves on after striking")

func _test_combat_encounter_player_cooldowns() -> void:
	print("Combat encounter (player cooldowns)")
	var encounter := _make_encounter("res://data/enemies/wolf.tres", 30)
	_check(encounter.can_act(), "player can act at fight start")
	var events := encounter.try_attack(false)
	_check(not events.is_empty(), "the first attack resolves")
	_check(not encounter.can_act(), "attacking locks the player out (shared cooldown)")
	_check(encounter.try_attack(false).is_empty(), "a second attack during cooldown is a no-op")
	_check(encounter.try_change_stance(CombatPosition.Position.GUARDED).is_empty(), "a stance change during cooldown is a no-op too")
	encounter.advance_time(2.0)  # attack cooldown is 2.0s
	_check(encounter.can_act(), "the attack cooldown expires after 2s")

	events = encounter.try_change_stance(CombatPosition.Position.GUARDED)
	_check(not events.is_empty(), "stance change resolves when ready")
	_check(encounter.player.position == CombatPosition.Position.GUARDED, "stance actually changed")
	_check(not encounter.can_act(), "stance changes trigger their own cooldown")
	encounter.advance_time(2.9)
	_check(not encounter.can_act(), "stance cooldown (3s) still running at 2.9s")
	encounter.advance_time(0.2)
	_check(encounter.can_act(), "stance cooldown expires after 3s")

func _test_combat_encounter_dire_wolf_howl() -> void:
	print("Combat encounter (Dire Wolf Howl)")
	var encounter := _make_encounter("res://data/enemies/dire_wolf.tres", 11)
	_check(encounter.balance == ThreatAndBalance.BALANCE_NEUTRAL, "the fight starts at neutral Balance (50)")
	_check(encounter.enemy_phase == CombatEncounter.EnemyPhase.TELEGRAPHING_HOWL, "Dire Wolf telegraphs Howl at the very start")

	encounter.advance_time(1.9)  # howl telegraph is 2.0s
	_check(encounter.balance == ThreatAndBalance.BALANCE_NEUTRAL, "Balance hasn't been seized during the telegraph")
	encounter.advance_time(0.2)
	_check(encounter.balance == ThreatAndBalance.BALANCE_MIN, "Howl slams Balance to 0 (full enemy control) when it resolves")

func _test_combat_encounter_reaches_a_winner() -> void:
	print("Combat encounter (runs to completion)")
	var encounter := _make_encounter("res://data/enemies/wolf.tres", 99)
	var simulated := 0.0
	while not encounter.is_over() and simulated < 600.0:
		encounter.advance_time(0.1)
		simulated += 0.1
		if encounter.can_act():
			encounter.try_attack(false)
	_check(encounter.is_over(), "an attack-when-ready player finishes a Wolf fight within 600 simulated seconds (took %.1fs)" % simulated)
	_check(encounter.winner() in ["player", "enemy"], "winner() reports a definitive result (%s)" % encounter.winner())

func _test_combat_screen_smoke(screen: Control) -> void:
	_check(screen.is_node_ready(), "combat screen reached _ready in the running tree")
	_check(screen.encounter != null, "screen auto-starts a Wolf encounter on ready")
	if screen.encounter == null:
		return
	# Fast-forward by calling _process directly with large deltas (the engine
	# also calls it per frame with tiny real deltas; those are harmless).
	var simulated := 0.0
	while not screen.encounter.is_over() and simulated < 600.0:
		screen._process(0.25)
		simulated += 0.25
		if screen.encounter.can_act():
			screen.get_node("%AttackButton").emit_signal("pressed")
	_check(screen.encounter.is_over(), "attacking whenever ready ends the fight (%.0fs simulated)" % simulated)
	_check(screen.get_node("%EndPanel").visible, "end panel becomes visible when the fight ends")
	screen.get_node("%FightDireWolfButton").emit_signal("pressed")
	_check(not screen.encounter.is_over(), "restart button begins a fresh encounter")
	_check(screen.encounter.enemy_data.id == "dire_wolf", "restart button swaps in the chosen enemy (Dire Wolf)")
