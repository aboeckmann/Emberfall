class_name Attributes
extends RefCounted
## Core attributes: Intellect, Vitality, Willpower.
## See Docs/05_Skills_And_Progression.md (concept) and Docs/11_Balance_Bible.md (formulas).
## Pool formula is a first-pass simplification shared by all three attributes --
## nothing requires them to scale identically once real balancing starts.

const POOL_BASE := 50
const POOL_PER_POINT := 5

var intellect: int
var vitality: int
var willpower: int

func _init(p_intellect: int = 10, p_vitality: int = 10, p_willpower: int = 10) -> void:
	intellect = p_intellect
	vitality = p_vitality
	willpower = p_willpower

## Max unconverted XP a skill's bucket can hold. See Docs/03_Game_Systems.md (Skill Gain).
func skill_bucket_cap() -> int:
	return POOL_BASE + (intellect * POOL_PER_POINT)

func max_hp() -> int:
	return POOL_BASE + (vitality * POOL_PER_POINT)

func max_stamina() -> int:
	return POOL_BASE + (vitality * POOL_PER_POINT)

func max_mana() -> int:
	return POOL_BASE + (willpower * POOL_PER_POINT)

func max_focus() -> int:
	return POOL_BASE + (willpower * POOL_PER_POINT)
