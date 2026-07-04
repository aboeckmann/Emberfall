class_name CombatAction
extends RefCounted
## Combat actions and their Stamina costs. See Docs/04_Combat_Design.md, 11_Balance_Bible.md.

enum Action { ATTACK, HEAVY_ATTACK, PARRY, DODGE, GUARD, REPOSITION }

const STAMINA_COST := {
	Action.ATTACK: 10,
	Action.HEAVY_ATTACK: 20,
	Action.PARRY: 8,
	Action.DODGE: 15,
	Action.GUARD: 0,
	Action.REPOSITION: 12,
}

static func stamina_cost(action: Action) -> int:
	return STAMINA_COST[action]
