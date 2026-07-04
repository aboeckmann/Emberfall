class_name Skill
extends RefCounted
## A single trainable skill: level plus the skill-gain bucket.
## See Docs/03_Game_Systems.md (Skill Gain) and Docs/11_Balance_Bible.md (curve/rates).

const XP_CURVE_COEFFICIENT := 20.0
const XP_CURVE_EXPONENT := 1.5
const SKILL_CAP := 100  # not finalized -- see Docs/05_Skills_And_Progression.md

const PASSIVE_DRAIN_RATE := 0.01       # fraction of bucket converted per minute, everywhere
const BASTION_REST_DRAIN_RATE := 0.10  # fraction of bucket converted per minute, while Resting

var skill_name: String
var level: int = 0
var xp: float = 0.0       # progress toward the next level
var bucket: float = 0.0   # unconverted XP waiting to drain

func _init(p_skill_name: String) -> void:
	skill_name = p_skill_name

## XP required to go from `level` to `level + 1`.
static func xp_required_for_level(level: int) -> int:
	return int(round(XP_CURVE_COEFFICIENT * pow(level, XP_CURVE_EXPONENT)))

## Adds XP earned from an action into the bucket, clamped to `bucket_cap`
## (see Attributes.skill_bucket_cap). A full bucket simply stops accepting more
## until it drains -- it never blocks the action that earned the XP.
func add_bucket_xp(amount: float, bucket_cap: int) -> void:
	if amount <= 0.0:
		return
	bucket = minf(bucket + amount, float(bucket_cap))

## Drains the bucket for `minutes` of elapsed time at `rate` (fraction per minute),
## converting drained bucket contents into real skill XP and applying any level-ups.
func drain_bucket(rate: float, minutes: float) -> void:
	if bucket <= 0.0 or level >= SKILL_CAP:
		return
	var drained: float = minf(bucket * rate * minutes, bucket)
	bucket -= drained
	_gain_xp(drained)

func _gain_xp(amount: float) -> void:
	xp += amount
	while level < SKILL_CAP and xp >= xp_required_for_level(level + 1):
		xp -= xp_required_for_level(level + 1)
		level += 1
	if level >= SKILL_CAP:
		xp = 0.0
