class_name EnemyRules
extends RefCounted
## Pure stat-check helpers evaluated against EnemyData. Full AI decision-making
## (circling, retreat timing, when to trigger Howl) is a future combat-encounter
## task, not implemented here. The Wolf's "Emboldened" state (bonus damage after
## landing a Bite, until the player regains Initiative) is also not implemented
## yet -- it depends on combat-loop state, not just the enemy's stat block.
## See Docs/11_Balance_Bible.md.

static func is_enraged(enemy: EnemyData, current_hp: int) -> bool:
	if enemy.enrage_hp_fraction <= 0.0:
		return false
	return float(current_hp) / float(enemy.max_hp) <= enemy.enrage_hp_fraction

static func roll_bite_damage(enemy: EnemyData, current_hp: int, rng: RandomNumberGenerator) -> int:
	var damage: int = rng.randi_range(enemy.bite_damage_min, enemy.bite_damage_max)
	if is_enraged(enemy, current_hp):
		damage = int(round(damage * enemy.enrage_damage_multiplier))
	return damage

static func should_retreat(enemy: EnemyData, current_hp: int) -> bool:
	if not enemy.retreats_at_low_hp:
		return false
	return float(current_hp) / float(enemy.max_hp) <= enemy.retreat_hp_fraction

static func roll_evades(enemy: EnemyData, rng: RandomNumberGenerator) -> bool:
	return rng.randf() < enemy.evasion_chance
