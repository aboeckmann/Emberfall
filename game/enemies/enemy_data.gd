class_name EnemyData
extends Resource
## Enemy stat block. See Docs/11_Balance_Bible.md for the Wolf and Dire Wolf.
## This is stats only -- full AI decision-making (when to circle, retreat, or
## Howl) is a future combat-encounter task; see EnemyRules for the pure,
## stateless checks that are implemented so far, and Docs/04_Combat_Design.md
## (Enemy AI) for the design intent.

@export var id: String = ""
@export var display_name: String = ""
@export var max_hp: int = 0
@export var bite_damage_min: int = 0
@export var bite_damage_max: int = 0
@export var evasion_chance: float = 0.0

@export var circles_before_engaging: bool = false
@export var retreats_at_low_hp: bool = false
@export var retreat_hp_fraction: float = 0.0

@export var has_howl: bool = false
@export var enrage_hp_fraction: float = 0.0
@export var enrage_damage_multiplier: float = 1.0
