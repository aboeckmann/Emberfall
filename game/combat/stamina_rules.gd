class_name StaminaRules
extends RefCounted
## Stamina regen and the low-Stamina pacing penalty. Regen is continuous
## (per second) now that combat runs in real time. See Docs/11_Balance_Bible.md.

const REGEN_PER_SECOND := 4.0
const REGEN_PER_SECOND_GUARDED := 6.0  # the defensive stance recovers faster
const LOW_STAMINA_THRESHOLD := 20.0
const LOW_STAMINA_MULTIPLIER := 0.75  # -25% damage dealt / defense chance while low

static func regen_per_second(stance: CombatPosition.Position) -> float:
	return REGEN_PER_SECOND_GUARDED if stance == CombatPosition.Position.GUARDED else REGEN_PER_SECOND

static func is_low(current_stamina: float) -> bool:
	return current_stamina < LOW_STAMINA_THRESHOLD
