class_name SkillGainTable
extends RefCounted
## Per-action skill-bucket XP for the Prototype (Sword vs. Wolf).
## Difficulty multiplier is fixed at 1.0 -- relative-difficulty scaling across
## enemies is deferred until a second enemy exists to calibrate against.
## See Docs/11_Balance_Bible.md.

## Returns { "skill": String, "bucket_xp": float } for a landed action, or an
## empty Dictionary if the action doesn't train a skill (or didn't land).
static func for_action(action: CombatAction.Action, landed: bool) -> Dictionary:
	if not landed:
		return {}
	match action:
		CombatAction.Action.ATTACK:
			return {"skill": "Blades", "bucket_xp": 2.0}
		CombatAction.Action.HEAVY_ATTACK:
			return {"skill": "Blades", "bucket_xp": 4.0}
		CombatAction.Action.PARRY:
			return {"skill": "Parry", "bucket_xp": 3.0}
		CombatAction.Action.DODGE:
			return {"skill": "Evasion", "bucket_xp": 2.0}
		CombatAction.Action.GUARD:
			return {"skill": "Guard", "bucket_xp": 1.0}
		_:
			return {}
