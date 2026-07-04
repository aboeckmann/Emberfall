class_name CombatAction
extends RefCounted
## Player-selectable actions, their Stamina costs, and the shared cooldown each
## triggers. Defense (Parry/Dodge/Block) is NOT here -- it's a passive check,
## see DefenseRules. See Docs/04_Combat_Design.md, 11_Balance_Bible.md.

enum Action { ATTACK, HEAVY_ATTACK, CHANGE_STANCE }

const STAMINA_COST := {
	Action.ATTACK: 10.0,
	Action.HEAVY_ATTACK: 20.0,
	Action.CHANGE_STANCE: 12.0,
}

## Seconds before the player can act again. One shared cooldown gate -- any
## action locks all actions for its own duration.
const COOLDOWN_SECONDS := {
	Action.ATTACK: 2.0,
	Action.HEAVY_ATTACK: 4.0,
	Action.CHANGE_STANCE: 3.0,
}

static func stamina_cost(action: Action) -> float:
	return STAMINA_COST[action]

static func cooldown_seconds(action: Action) -> float:
	return COOLDOWN_SECONDS[action]
