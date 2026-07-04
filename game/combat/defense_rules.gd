class_name DefenseRules
extends RefCounted
## Passive defense: when an enemy attack lands, the defender automatically
## checks Parry, then Dodge, then Block (Guard) -- no player input. Each check
## is a chance built from defender skill vs. attacker skill, shifted by stance
## and Balance, and penalized at low Stamina. First success wins.
## See Docs/04_Combat_Design.md (Defense) and 11_Balance_Bible.md.

const PARRY_BASE_CHANCE := 0.20
const DODGE_BASE_CHANCE := 0.15
const GUARD_BASE_CHANCE := 0.25
const SKILL_DIFF_PER_POINT := 0.005   # +/-0.5% per point of (defender skill - attacker skill)
const BALANCE_PER_POINT := 0.002      # +/-0.2% per point of Balance away from neutral (50)
const MAX_CHANCE_PER_CHECK := 0.60

const STANCE_MODIFIER := {
	CombatPosition.Position.FRONTLINE: -0.10,
	CombatPosition.Position.BALANCED: 0.0,
	CombatPosition.Position.GUARDED: 0.15,
	CombatPosition.Position.FLANKING: 0.0,
	CombatPosition.Position.REAR: 0.0,
}

const GUARD_DAMAGE_MULTIPLIER := 0.5  # a successful Block halves damage; Parry/Dodge negate it

const PARRY_STAMINA_COST := 8.0
const DODGE_STAMINA_COST := 15.0
const GUARD_STAMINA_COST := 0.0

static func check_chance(
	base_chance: float,
	defender_skill_level: int,
	attacker_skill_level: int,
	stance: CombatPosition.Position,
	balance: int,
	is_low_stamina: bool
) -> float:
	var chance := base_chance
	chance += float(defender_skill_level - attacker_skill_level) * SKILL_DIFF_PER_POINT
	chance += STANCE_MODIFIER[stance]
	chance += float(balance - ThreatAndBalance.BALANCE_NEUTRAL) * BALANCE_PER_POINT
	if is_low_stamina:
		chance *= StaminaRules.LOW_STAMINA_MULTIPLIER
	return clampf(chance, 0.0, MAX_CHANCE_PER_CHECK)

## Resolves an incoming attack against the defender's passive defenses.
## Returns: { "result": "parry"|"dodge"|"guard"|"hit", "damage_multiplier": float,
##            "balance_delta": int, "stamina_cost": float,
##            "trained_skill": String, "bucket_xp": float }
static func resolve(
	parry_skill_level: int,
	evasion_skill_level: int,
	guard_skill_level: int,
	attacker_skill_level: int,
	stance: CombatPosition.Position,
	balance: int,
	is_low_stamina: bool,
	weapon_can_parry: bool,
	rng: RandomNumberGenerator
) -> Dictionary:
	if weapon_can_parry:
		var parry_chance := check_chance(PARRY_BASE_CHANCE, parry_skill_level, attacker_skill_level, stance, balance, is_low_stamina)
		if rng.randf() < parry_chance:
			return {
				"result": "parry", "damage_multiplier": 0.0,
				"balance_delta": ThreatAndBalance.BALANCE_ON_SUCCESSFUL_PARRY,
				"stamina_cost": PARRY_STAMINA_COST,
				"trained_skill": "Parry", "bucket_xp": 3.0,
			}
	var dodge_chance := check_chance(DODGE_BASE_CHANCE, evasion_skill_level, attacker_skill_level, stance, balance, is_low_stamina)
	if rng.randf() < dodge_chance:
		return {
			"result": "dodge", "damage_multiplier": 0.0,
			"balance_delta": ThreatAndBalance.BALANCE_ON_SUCCESSFUL_DODGE,
			"stamina_cost": DODGE_STAMINA_COST,
			"trained_skill": "Evasion", "bucket_xp": 2.0,
		}
	var guard_chance := check_chance(GUARD_BASE_CHANCE, guard_skill_level, attacker_skill_level, stance, balance, is_low_stamina)
	if rng.randf() < guard_chance:
		return {
			"result": "guard", "damage_multiplier": GUARD_DAMAGE_MULTIPLIER,
			"balance_delta": ThreatAndBalance.BALANCE_ON_SUCCESSFUL_GUARD,
			"stamina_cost": GUARD_STAMINA_COST,
			"trained_skill": "Guard", "bucket_xp": 1.0,
		}
	return {
		"result": "hit", "damage_multiplier": 1.0,
		"balance_delta": ThreatAndBalance.BALANCE_ON_HIT_TAKEN,
		"stamina_cost": 0.0,
		"trained_skill": "", "bucket_xp": 0.0,
	}
