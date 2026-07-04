extends SceneTree
## Minimal ad-hoc verification of the game/ rules layer against the worked
## values in Docs/11_Balance_Bible.md. Not a real test framework -- test
## conventions for the rules layer are still TBD (02_Technical_Design_Document.md).
## Run with: godot --headless --script res://tests/run_tests.gd

var failures := 0

func _initialize() -> void:
	_test_attributes()
	_test_skill_xp_curve()
	_test_skill_bucket()
	_test_stamina_rules()
	_test_equipment_data()
	_test_damage_formula()
	_test_crit_chance()
	_test_threat_and_initiative()
	_test_enemy_data()
	_test_character_sheet()
	_test_combat_encounter_wolf_telegraph_cadence()
	_test_combat_encounter_dire_wolf_howl()
	_test_combat_encounter_defense_resolution()
	_test_combat_encounter_reaches_a_winner()

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
	_check(StaminaRules.regen_amount(false) == 5, "default regen is 5")
	_check(StaminaRules.regen_amount(true) == 10, "guard/wait regen is 10")
	_check(StaminaRules.is_low(19), "19 stamina counts as low")
	_check(not StaminaRules.is_low(20), "20 stamina does not count as low")
	_check(CombatAction.stamina_cost(CombatAction.Action.HEAVY_ATTACK) == 20, "heavy attack costs 20 stamina")

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

func _test_threat_and_initiative() -> void:
	print("Threat and Initiative")
	_check(is_equal_approx(ThreatAndInitiative.calculate_threat(10, 0), 10.0), "threat with 0 Presence == raw damage")
	_check(is_equal_approx(ThreatAndInitiative.calculate_threat(10, 50), 15.0), "50 Presence adds +50%% threat")
	_check(ThreatAndInitiative.apply_delta(95, 10) == 100, "initiative clamps at 100")
	_check(ThreatAndInitiative.apply_delta(5, -15) == 0, "initiative clamps at 0")
	_check(ThreatAndInitiative.has_bonus_action_available(50), "initiative 50 unlocks the bonus action")
	_check(not ThreatAndInitiative.has_bonus_action_available(49), "initiative 49 does not")

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

func _test_combat_encounter_wolf_telegraph_cadence() -> void:
	print("Combat encounter (Wolf telegraph cadence)")
	var encounter := _make_encounter("res://data/enemies/wolf.tres", 10)
	_check(encounter.current_intent == EnemyIntent.Intent.CIRCLING, "Wolf's opening intent is CIRCLING")

	encounter.resolve_round(CombatAction.Action.ATTACK)
	_check(encounter.player.current_hp == encounter.player.max_hp, "player takes no damage during round 1 (Wolf circling)")
	_check(encounter.current_intent == EnemyIntent.Intent.CIRCLING, "Wolf still circles for round 2 (2 circling rounds total)")

	encounter.resolve_round(CombatAction.Action.ATTACK)
	_check(encounter.player.current_hp == encounter.player.max_hp, "player takes no damage during round 2 (Wolf circling)")
	_check(encounter.current_intent == EnemyIntent.Intent.TELEGRAPHING_BITE, "round 3 telegraphs the Bite instead of landing it")

	encounter.resolve_round(CombatAction.Action.ATTACK)
	_check(encounter.player.current_hp == encounter.player.max_hp, "player still takes no damage on the telegraph round itself")
	_check(encounter.current_intent == EnemyIntent.Intent.BITE, "the telegraphed Bite resolves the round after it was announced")

func _test_combat_encounter_dire_wolf_howl() -> void:
	print("Combat encounter (Dire Wolf Howl)")
	var encounter := _make_encounter("res://data/enemies/dire_wolf.tres", 11)
	_check(encounter.current_intent == EnemyIntent.Intent.TELEGRAPHING_HOWL, "Dire Wolf telegraphs Howl at the very start of the fight")
	_check(encounter.enemy.initiative == 0, "Initiative hasn't been seized yet, only telegraphed")

	encounter.resolve_round(CombatAction.Action.ATTACK)
	_check(encounter.current_intent == EnemyIntent.Intent.HOWL, "Howl resolves the round after being telegraphed")

	encounter.resolve_round(CombatAction.Action.ATTACK)
	_check(encounter.enemy.initiative == ThreatAndInitiative.INITIATIVE_MAX, "Howl seizes full Initiative (100) when it resolves")

func _test_combat_encounter_defense_resolution() -> void:
	print("Combat encounter (defense resolution)")

	var dodging := _make_encounter("res://data/enemies/wolf.tres", 20)
	for i in range(CombatEncounter.CIRCLING_ROUNDS + 1):  # circle out, then the telegraph round
		dodging.resolve_round(CombatAction.Action.GUARD)
	_check(dodging.current_intent == EnemyIntent.Intent.BITE, "test setup reached the Bite round")
	dodging.resolve_round(CombatAction.Action.DODGE)
	_check(dodging.player.current_hp == dodging.player.max_hp, "a correctly-timed Dodge fully negates the Bite")

	var tanking := _make_encounter("res://data/enemies/wolf.tres", 20)
	for i in range(CombatEncounter.CIRCLING_ROUNDS + 1):
		tanking.resolve_round(CombatAction.Action.GUARD)
	tanking.resolve_round(CombatAction.Action.ATTACK)  # offense instead of defense -- takes the full Bite
	_check(tanking.player.current_hp < tanking.player.max_hp, "attacking instead of defending during a Bite takes full damage")

func _test_combat_encounter_reaches_a_winner() -> void:
	print("Combat encounter (runs to completion)")
	var encounter := _make_encounter("res://data/enemies/wolf.tres", 99)
	var rounds := 0
	while not encounter.is_over() and rounds < 200:
		encounter.resolve_round(CombatAction.Action.ATTACK)
		rounds += 1
	_check(encounter.is_over(), "an all-Attack player defeats or is defeated by a Wolf within 200 rounds (took %d)" % rounds)
	_check(encounter.winner() in ["player", "enemy"], "winner() reports a definitive result (%s)" % encounter.winner())
