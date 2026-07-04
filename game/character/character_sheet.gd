class_name CharacterSheet
extends RefCounted
## A player character's persistent state. See Docs/03_Game_Systems.md (Character
## Creation) for the Prototype-minimal creation flow this implements.

## Fixed placeholder spread -- the real attribute-allocation method is TBD.
const PLACEHOLDER_STARTING_ATTRIBUTE := 10

var character_name: String
var attributes: Attributes
var skills: Dictionary = {}  # String skill_name -> Skill
var renown: int = 0
var equipped_weapon: WeaponData
var guild: String = ""  # empty string == guildless

func _init(p_character_name: String) -> void:
	character_name = p_character_name
	attributes = Attributes.new(
		PLACEHOLDER_STARTING_ATTRIBUTE, PLACEHOLDER_STARTING_ATTRIBUTE, PLACEHOLDER_STARTING_ATTRIBUTE
	)

## Skills are created lazily at level 0 the first time they're touched.
func get_skill(skill_name: String) -> Skill:
	if not skills.has(skill_name):
		skills[skill_name] = Skill.new(skill_name)
	return skills[skill_name]

func is_guildless() -> bool:
	return guild.is_empty()

## Builds a new character per the Prototype-minimal creation flow (see
## Docs/03_Game_Systems.md): fixed placeholder attributes, all skills start at
## 0 (created lazily), guildless, 0 Renown, and the given starting weapon equipped.
static func create_new(p_character_name: String, starting_weapon: WeaponData) -> CharacterSheet:
	var sheet := CharacterSheet.new(p_character_name)
	sheet.equipped_weapon = starting_weapon
	return sheet
