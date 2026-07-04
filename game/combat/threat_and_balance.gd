class_name ThreatAndBalance
extends RefCounted
## Threat targeting and the Balance meter. See Docs/04_Combat_Design.md, 11_Balance_Bible.md.
## Balance is a single tug-of-war meter shared by both sides of a fight:
## 100 = player in full control, 0 = enemy in full control, 50 = neutral.
## Every fight starts at neutral.

const BALANCE_MIN := 0
const BALANCE_MAX := 100
const BALANCE_NEUTRAL := 50
const BALANCE_ON_HIT_LANDED := 10
const BALANCE_ON_SUCCESSFUL_PARRY := 15
const BALANCE_ON_SUCCESSFUL_DODGE := 5
const BALANCE_ON_HIT_TAKEN := -15
## Raised from the pre-Balance value of 50: fights now START at 50 (neutral),
## so the free-bonus-action reward requires clear advantage, not the opening bell.
const BONUS_ACTION_THRESHOLD := 75

static func calculate_threat(damage: int, presence_skill_level: int) -> float:
	return float(damage) * (1.0 + (float(presence_skill_level) / 100.0))

static func apply_delta(current_balance: int, delta: int) -> int:
	return clampi(current_balance + delta, BALANCE_MIN, BALANCE_MAX)

## True once Balance >= 75, unlocking one free bonus action (a no-cost,
## no-telegraph Heavy Attack) until Balance drops back below the threshold.
## Not yet consumed by CombatEncounter -- the payoff is still unimplemented.
static func has_bonus_action_available(current_balance: int) -> bool:
	return current_balance >= BONUS_ACTION_THRESHOLD
