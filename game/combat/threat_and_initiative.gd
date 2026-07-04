class_name ThreatAndInitiative
extends RefCounted
## Threat targeting and the Initiative tug-of-war. See Docs/04_Combat_Design.md, 11_Balance_Bible.md.

const INITIATIVE_MIN := 0
const INITIATIVE_MAX := 100
const INITIATIVE_ON_HIT_LANDED := 10
const INITIATIVE_ON_SUCCESSFUL_PARRY := 15
const INITIATIVE_ON_SUCCESSFUL_DODGE := 5
const INITIATIVE_ON_HIT_TAKEN := -15
const BONUS_ACTION_THRESHOLD := 50

static func calculate_threat(damage: int, presence_skill_level: int) -> float:
	return float(damage) * (1.0 + (float(presence_skill_level) / 100.0))

static func apply_delta(current_initiative: int, delta: int) -> int:
	return clampi(current_initiative + delta, INITIATIVE_MIN, INITIATIVE_MAX)

## True once Initiative >= 50, unlocking one free bonus action (a no-cost,
## no-telegraph Heavy Attack) until Initiative drops back below the threshold.
static func has_bonus_action_available(current_initiative: int) -> bool:
	return current_initiative >= BONUS_ACTION_THRESHOLD
