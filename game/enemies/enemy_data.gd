class_name EnemyData
extends Resource
## Enemy stat block. See Docs/11_Balance_Bible.md for the Wolf and Dire Wolf.
## Enemies act on their own real-time clock, independent of the player's
## cooldowns: circle -> telegraph -> strike -> cooldown -> repeat, with
## retreat/Howl woven in (see CombatEncounter's enemy state machine).
## This is stats only -- the state machine lives in CombatEncounter; the pure,
## stateless checks live in EnemyRules.

@export var id: String = ""
@export var display_name: String = ""
@export var max_hp: int = 0
@export var bite_damage_min: int = 0
@export var bite_damage_max: int = 0
@export var evasion_chance: float = 0.0
## Attack skill checked against the defender's Parry/Evasion/Guard skills
## in the passive defense resolution (see DefenseRules).
@export var attack_skill: int = 0

@export var telegraph_seconds: float = 0.0       # warning time before an attack lands
@export var attack_cooldown_seconds: float = 0.0 # recovery time after an attack resolves
@export var circling_seconds: float = 0.0        # opening delay before the first attack (0 = engages immediately)

@export var retreat_hp_fraction: float = 0.0     # HP fraction that triggers retreat; 0 = never retreats
@export var retreat_seconds: float = 0.0         # how long the (single) retreat lasts

@export var has_howl: bool = false
@export var howl_telegraph_seconds: float = 0.0
@export var enrage_hp_fraction: float = 0.0      # 0 = no Enrage
@export var enrage_damage_multiplier: float = 1.0
