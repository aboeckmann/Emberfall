class_name DamageCalculator
extends RefCounted
## Sword attack damage and critical hits. See Docs/11_Balance_Bible.md.

const VARIANCE_MIN := 0.85
const VARIANCE_MAX := 1.15
const HEAVY_ATTACK_MULTIPLIER := 1.8
const BASE_CRIT_CHANCE := 0.05
const CRIT_CHANCE_PER_5_PRECISION := 0.01
const CRIT_DAMAGE_MULTIPLIER := 2.0

## Returns the final damage of one attack, rounded to an integer and floored at 0.
static func calculate_attack_damage(
	weapon: WeaponData,
	blades_skill_level: int,
	position: CombatPosition.Position,
	is_heavy: bool,
	enemy_defense: int,
	is_low_stamina: bool,
	rng: RandomNumberGenerator
) -> int:
	var skill_bonus: int = int(floor(blades_skill_level / 10.0))
	var base_damage: float = float(weapon.base_damage + skill_bonus)
	var position_modifier: float = CombatPosition.damage_modifier(position)
	var variance: float = rng.randf_range(VARIANCE_MIN, VARIANCE_MAX)

	var damage: float = (base_damage * position_modifier * variance) - float(enemy_defense)
	if is_heavy:
		damage *= HEAVY_ATTACK_MULTIPLIER
	if is_low_stamina:
		damage *= StaminaRules.LOW_STAMINA_MULTIPLIER

	return int(maxf(round(damage), 0.0))

static func crit_chance(precision_skill_level: int, position: CombatPosition.Position) -> float:
	var chance: float = BASE_CRIT_CHANCE + (float(precision_skill_level) / 5.0) * CRIT_CHANCE_PER_5_PRECISION
	if position == CombatPosition.Position.FLANKING:
		chance += CombatPosition.FLANKING_CRIT_BONUS
	return chance

static func roll_crit(chance: float, rng: RandomNumberGenerator) -> bool:
	return rng.randf() < chance

static func apply_crit(damage: int) -> int:
	return int(round(damage * CRIT_DAMAGE_MULTIPLIER))
