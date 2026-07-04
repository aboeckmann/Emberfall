class_name StaminaRules
extends RefCounted
## Stamina regen and the low-Stamina pacing penalty. See Docs/11_Balance_Bible.md.

const REGEN_DEFAULT := 5
const REGEN_GUARD_OR_WAIT := 10
const LOW_STAMINA_THRESHOLD := 20
const LOW_STAMINA_MULTIPLIER := 0.75  # -25% damage dealt / defense effectiveness while low

static func regen_amount(was_guard_or_wait: bool) -> int:
	return REGEN_GUARD_OR_WAIT if was_guard_or_wait else REGEN_DEFAULT

static func is_low(current_stamina: int) -> bool:
	return current_stamina < LOW_STAMINA_THRESHOLD
