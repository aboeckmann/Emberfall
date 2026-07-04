class_name WeaponData
extends EquipmentData
## See Docs/11_Balance_Bible.md for concrete Prototype values (the Sword).

@export var base_damage: int = 0
@export var trained_skill: String = ""
@export var can_parry: bool = false
## Multiplies the base action Stamina costs in 11_Balance_Bible.md; the hook for
## future Weapon Feel differentiation (e.g. a Great Axe costing more per swing).
## Unused for the Prototype's single weapon (Sword = 1.0).
@export var stamina_cost_modifier: float = 1.0
