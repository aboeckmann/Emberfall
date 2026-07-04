class_name CombatPosition
extends RefCounted
## Battlefield positions and their combat modifiers. See Docs/04_Combat_Design.md, 11_Balance_Bible.md.

enum Position { FRONTLINE, BALANCED, GUARDED, FLANKING, REAR }

const DAMAGE_MODIFIER := {
	Position.FRONTLINE: 1.2,
	Position.BALANCED: 1.0,
	Position.GUARDED: 0.8,
	Position.FLANKING: 1.1,
	Position.REAR: 1.0,  # not exercised by the Sword; placeholder until ranged weapons exist
}

const FLANKING_CRIT_BONUS := 0.10

static func damage_modifier(position: Position) -> float:
	return DAMAGE_MODIFIER[position]
