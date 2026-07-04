class_name Combatant
extends RefCounted
## Runtime combat state shared by the player and enemies: HP, Stamina, and
## stance. See Docs/04_Combat_Design.md. (Balance is not here -- it's a single
## meter shared by both sides, owned by CombatEncounter.)

var display_name: String
var max_hp: int
var current_hp: int
var max_stamina: int
var current_stamina: float
var position: CombatPosition.Position = CombatPosition.Position.BALANCED

func _init(p_display_name: String, p_max_hp: int, p_max_stamina: int) -> void:
	display_name = p_display_name
	max_hp = p_max_hp
	current_hp = p_max_hp
	max_stamina = p_max_stamina
	current_stamina = float(p_max_stamina)

func is_alive() -> bool:
	return current_hp > 0

func is_low_stamina() -> bool:
	return StaminaRules.is_low(current_stamina)

func take_damage(amount: int) -> void:
	current_hp = maxi(current_hp - amount, 0)

## Stamina never blocks an action -- running it out just floors at 0 and
## triggers the low-Stamina penalty (StaminaRules), which is the documented
## pacing mechanism, not a hard gate on what actions are available.
func spend_stamina(amount: float) -> void:
	current_stamina = maxf(current_stamina - amount, 0.0)

## Continuous regen; rate depends on stance (see StaminaRules).
func regen_stamina(delta: float) -> void:
	current_stamina = minf(current_stamina + StaminaRules.regen_per_second(position) * delta, float(max_stamina))
