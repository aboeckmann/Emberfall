class_name Combatant
extends RefCounted
## Runtime combat state shared by the player and enemies: HP, Stamina, Initiative,
## and battlefield position. See Docs/04_Combat_Design.md.

var display_name: String
var max_hp: int
var current_hp: int
var max_stamina: int
var current_stamina: int
var initiative: int = 0
var position: CombatPosition.Position = CombatPosition.Position.BALANCED

func _init(p_display_name: String, p_max_hp: int, p_max_stamina: int) -> void:
	display_name = p_display_name
	max_hp = p_max_hp
	current_hp = p_max_hp
	max_stamina = p_max_stamina
	current_stamina = p_max_stamina

func is_alive() -> bool:
	return current_hp > 0

func is_low_stamina() -> bool:
	return StaminaRules.is_low(current_stamina)

func take_damage(amount: int) -> void:
	current_hp = maxi(current_hp - amount, 0)

## Stamina never blocks an action -- running it out just floors at 0 and
## triggers the low-Stamina penalty (StaminaRules), which is the documented
## pacing mechanism, not a hard gate on what actions are available.
func spend_stamina(amount: int) -> void:
	current_stamina = maxi(current_stamina - amount, 0)

func regen_stamina(was_guard_or_wait: bool) -> void:
	current_stamina = mini(current_stamina + StaminaRules.regen_amount(was_guard_or_wait), max_stamina)

func gain_initiative(delta: int) -> void:
	initiative = ThreatAndInitiative.apply_delta(initiative, delta)
