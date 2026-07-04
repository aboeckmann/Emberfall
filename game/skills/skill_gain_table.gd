class_name SkillGainTable
extends RefCounted
## Per-action skill-bucket XP for the Prototype (Sword vs. Wolf).
## Attack actions only -- passive defense successes grant their XP through
## DefenseRules.resolve(). Difficulty multiplier is fixed at 1.0; relative
## scaling across enemies is deferred until a second enemy exists to calibrate
## against. See Docs/11_Balance_Bible.md.

## Bucket XP granted to the weapon's trained skill when an attack lands.
static func for_landed_attack(trained_skill: String, is_heavy: bool) -> Dictionary:
	return {"skill": trained_skill, "bucket_xp": 4.0 if is_heavy else 2.0}
