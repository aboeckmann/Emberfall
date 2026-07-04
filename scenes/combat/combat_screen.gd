extends Control
## Combat screen: presentation layer over CombatEncounter (game/combat).
## Combat runs in real time -- _process feeds frame deltas into the encounter
## and streams its events into the log. Player input is attacks and stance
## changes only; defense is passive (DefenseRules) and just shows up in the
## log. Per the architecture rule in Docs/02_Technical_Design_Document.md this
## script only displays state and forwards choices -- all rules live in game/.
##
## Stances are limited to Frontline/Balanced/Guarded: Flanking is "available
## against groups" and Rear "only in some encounters" (Docs/04_Combat_Design.md),
## and the Prototype's encounters are single-enemy.

const SWORD: WeaponData = preload("res://data/weapons/sword.tres")
const WOLF: EnemyData = preload("res://data/enemies/wolf.tres")
const DIRE_WOLF: EnemyData = preload("res://data/enemies/dire_wolf.tres")

var encounter: CombatEncounter
var _fight_finished: bool = false

@onready var enemy_name_label: Label = %EnemyNameLabel
@onready var enemy_hp_bar: ProgressBar = %EnemyHPBar
@onready var enemy_hp_value: Label = %EnemyHPValue
@onready var intent_label: Label = %IntentLabel
@onready var log_text: RichTextLabel = %LogText
@onready var player_hp_bar: ProgressBar = %PlayerHPBar
@onready var player_hp_value: Label = %PlayerHPValue
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var stamina_value: Label = %StaminaValue
@onready var balance_bar: ProgressBar = %BalanceBar
@onready var balance_value: Label = %BalanceValue
@onready var cooldown_bar: ProgressBar = %CooldownBar
@onready var cooldown_value: Label = %CooldownValue
@onready var end_panel: PanelContainer = %EndPanel
@onready var result_label: Label = %ResultLabel

@onready var stance_buttons: Dictionary = {
	CombatPosition.Position.FRONTLINE: %FrontlineButton,
	CombatPosition.Position.BALANCED: %BalancedButton,
	CombatPosition.Position.GUARDED: %GuardedButton,
}

func _ready() -> void:
	%AttackButton.pressed.connect(_on_attack_pressed.bind(false))
	%HeavyAttackButton.pressed.connect(_on_attack_pressed.bind(true))
	for stance in stance_buttons:
		stance_buttons[stance].pressed.connect(_on_stance_pressed.bind(stance))
	%FightWolfButton.pressed.connect(func() -> void: _start_fight(WOLF))
	%FightDireWolfButton.pressed.connect(func() -> void: _start_fight(DIRE_WOLF))
	_start_fight(WOLF)

func _process(delta: float) -> void:
	if encounter == null or _fight_finished:
		return
	_append_log(encounter.advance_time(delta))
	_update_ui()
	if encounter.is_over():
		_finish_fight()

func _start_fight(enemy_data: EnemyData) -> void:
	var sheet := CharacterSheet.create_new("Hero", SWORD)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	encounter = CombatEncounter.create(sheet, enemy_data, rng)
	_fight_finished = false
	log_text.text = ""
	_append_log(["A %s stands before you." % enemy_data.display_name])
	end_panel.visible = false
	_update_ui()

func _on_attack_pressed(is_heavy: bool) -> void:
	if encounter == null or _fight_finished:
		return
	_append_log(encounter.try_attack(is_heavy))
	_update_ui()
	if encounter.is_over():
		_finish_fight()

func _on_stance_pressed(stance: CombatPosition.Position) -> void:
	if encounter == null or _fight_finished:
		return
	_append_log(encounter.try_change_stance(stance))
	_update_ui()

func _finish_fight() -> void:
	_fight_finished = true
	_update_ui()
	if encounter.winner() == "player":
		result_label.text = "Victory! The %s is slain." % encounter.enemy_data.display_name
	else:
		result_label.text = "You have fallen..."
	end_panel.visible = true

func _append_log(lines: Array) -> void:
	for line in lines:
		log_text.append_text(str(line) + "\n")

func _update_ui() -> void:
	var locked := not encounter.can_act()

	enemy_name_label.text = encounter.enemy_data.display_name
	enemy_hp_bar.max_value = encounter.enemy.max_hp
	enemy_hp_bar.value = encounter.enemy.current_hp
	enemy_hp_value.text = "%d / %d" % [encounter.enemy.current_hp, encounter.enemy.max_hp]
	intent_label.text = "" if encounter.is_over() else _phase_text()

	player_hp_bar.max_value = encounter.player.max_hp
	player_hp_bar.value = encounter.player.current_hp
	player_hp_value.text = "%d / %d" % [encounter.player.current_hp, encounter.player.max_hp]
	stamina_bar.max_value = encounter.player.max_stamina
	stamina_bar.value = encounter.player.current_stamina
	stamina_value.text = "%d / %d" % [int(round(encounter.player.current_stamina)), encounter.player.max_stamina]
	balance_bar.value = encounter.balance
	balance_value.text = _balance_text(encounter.balance)

	if encounter.player_cooldown_total > 0.0 and encounter.player_cooldown_remaining > 0.0:
		cooldown_bar.value = (1.0 - encounter.player_cooldown_remaining / encounter.player_cooldown_total) * 100.0
		cooldown_value.text = "%.1fs" % encounter.player_cooldown_remaining
	else:
		cooldown_bar.value = 100.0
		cooldown_value.text = "Ready"

	%AttackButton.disabled = locked
	%HeavyAttackButton.disabled = locked
	for stance in stance_buttons:
		stance_buttons[stance].disabled = locked or encounter.player.position == stance

## Balance is a shared meter: 100 = player in full control, 0 = enemy in full
## control, 50 = neutral (every fight starts there).
func _balance_text(balance: int) -> String:
	if balance > ThreatAndBalance.BALANCE_NEUTRAL:
		return "%d (You)" % balance
	if balance < ThreatAndBalance.BALANCE_NEUTRAL:
		return "%d (Enemy)" % balance
	return "%d (Neutral)" % balance

## The telegraph the player reads to anticipate what's coming and when
## (Observe -> Respond, Docs/04_Combat_Design.md).
func _phase_text() -> String:
	var enemy_name: String = encounter.enemy_data.display_name
	var remaining: float = maxf(encounter.enemy_phase_remaining, 0.0)
	match encounter.enemy_phase:
		CombatEncounter.EnemyPhase.CIRCLING:
			return "The %s circles, watching for an opening. (%.1fs)" % [enemy_name, remaining]
		CombatEncounter.EnemyPhase.TELEGRAPHING_ATTACK:
			return "The %s tenses, about to lunge! (%.1fs)" % [enemy_name, remaining]
		CombatEncounter.EnemyPhase.TELEGRAPHING_HOWL:
			return "The %s throws back its head to HOWL! (%.1fs)" % [enemy_name, remaining]
		CombatEncounter.EnemyPhase.RETREATING:
			return "The %s backs away, wary. (%.1fs)" % [enemy_name, remaining]
		CombatEncounter.EnemyPhase.RECOVERING:
			return "The %s watches you." % enemy_name
	return ""
