extends Control
## Combat screen: presentation layer over CombatEncounter (game/combat).
## Per the architecture rule in Docs/02_Technical_Design_Document.md, this
## script only displays state and forwards player choices -- all rules live
## in game/. Layout is functional-first; no Art Direction exists yet
## (Docs/12_Art_Direction.md).
##
## Position options are limited to Frontline/Balanced/Guarded: Flanking is
## "available against groups" and Rear "only in some encounters"
## (Docs/04_Combat_Design.md), and the Prototype's encounters are single-enemy.

const SWORD: WeaponData = preload("res://data/weapons/sword.tres")
const WOLF: EnemyData = preload("res://data/enemies/wolf.tres")
const DIRE_WOLF: EnemyData = preload("res://data/enemies/dire_wolf.tres")

var encounter: CombatEncounter

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
@onready var end_panel: PanelContainer = %EndPanel
@onready var result_label: Label = %ResultLabel

@onready var position_buttons: Dictionary = {
	CombatPosition.Position.FRONTLINE: %FrontlineButton,
	CombatPosition.Position.BALANCED: %BalancedButton,
	CombatPosition.Position.GUARDED: %GuardedButton,
}
@onready var action_buttons: Dictionary = {
	CombatAction.Action.ATTACK: %AttackButton,
	CombatAction.Action.HEAVY_ATTACK: %HeavyAttackButton,
	CombatAction.Action.PARRY: %ParryButton,
	CombatAction.Action.DODGE: %DodgeButton,
	CombatAction.Action.GUARD: %GuardButton,
}

func _ready() -> void:
	for action in action_buttons:
		action_buttons[action].pressed.connect(_on_action_pressed.bind(action))
	for pos in position_buttons:
		position_buttons[pos].pressed.connect(_on_position_pressed.bind(pos))
	%FightWolfButton.pressed.connect(func() -> void: _start_fight(WOLF))
	%FightDireWolfButton.pressed.connect(func() -> void: _start_fight(DIRE_WOLF))
	_start_fight(WOLF)

func _start_fight(enemy_data: EnemyData) -> void:
	var sheet := CharacterSheet.create_new("Hero", SWORD)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	encounter = CombatEncounter.create(sheet, enemy_data, rng)
	log_text.text = ""
	_append_log(["A %s stands before you." % enemy_data.display_name])
	end_panel.visible = false
	_update_ui()

func _on_action_pressed(action: CombatAction.Action) -> void:
	_play_round(action, null)

func _on_position_pressed(pos: CombatPosition.Position) -> void:
	_play_round(CombatAction.Action.REPOSITION, pos)

func _play_round(action: CombatAction.Action, target_position) -> void:
	if encounter.is_over():
		return
	_append_log(["", "-- Round %d --" % (encounter.round_number + 1)])
	_append_log(encounter.resolve_round(action, target_position))
	_update_ui()
	if encounter.is_over():
		_finish_fight()

func _finish_fight() -> void:
	if encounter.winner() == "player":
		result_label.text = "Victory! The %s is slain." % encounter.enemy_data.display_name
	else:
		result_label.text = "You have fallen..."
	end_panel.visible = true

func _append_log(lines: Array) -> void:
	for line in lines:
		log_text.append_text(str(line) + "\n")

func _update_ui() -> void:
	var over := encounter.is_over()

	enemy_name_label.text = encounter.enemy_data.display_name
	enemy_hp_bar.max_value = encounter.enemy.max_hp
	enemy_hp_bar.value = encounter.enemy.current_hp
	enemy_hp_value.text = "%d / %d" % [encounter.enemy.current_hp, encounter.enemy.max_hp]
	intent_label.text = "" if over else _intent_text(encounter.current_intent)

	player_hp_bar.max_value = encounter.player.max_hp
	player_hp_bar.value = encounter.player.current_hp
	player_hp_value.text = "%d / %d" % [encounter.player.current_hp, encounter.player.max_hp]
	stamina_bar.max_value = encounter.player.max_stamina
	stamina_bar.value = encounter.player.current_stamina
	stamina_value.text = "%d / %d" % [encounter.player.current_stamina, encounter.player.max_stamina]
	balance_bar.value = encounter.balance
	balance_value.text = _balance_text(encounter.balance)

	for action in action_buttons:
		action_buttons[action].disabled = over
	action_buttons[CombatAction.Action.PARRY].disabled = over or not encounter.player_sheet.equipped_weapon.can_parry
	for pos in position_buttons:
		position_buttons[pos].disabled = over or encounter.player.position == pos

## Balance is a shared meter: 100 = player in full control, 0 = enemy in full
## control, 50 = neutral (every fight starts there).
func _balance_text(balance: int) -> String:
	if balance > ThreatAndBalance.BALANCE_NEUTRAL:
		return "%d (You)" % balance
	if balance < ThreatAndBalance.BALANCE_NEUTRAL:
		return "%d (Enemy)" % balance
	return "%d (Neutral)" % balance

## `encounter.current_intent` is what the enemy will do during the NEXT
## resolve_round call, so this label is the telegraph the player reads
## before choosing their action (Observe -> Respond, Docs/04_Combat_Design.md).
func _intent_text(intent: EnemyIntent.Intent) -> String:
	var enemy_name: String = encounter.enemy_data.display_name
	match intent:
		EnemyIntent.Intent.CIRCLING:
			return "The %s circles, watching for an opening." % enemy_name
		EnemyIntent.Intent.TELEGRAPHING_BITE:
			return "The %s tenses, about to lunge..." % enemy_name
		EnemyIntent.Intent.BITE:
			return "BITE INCOMING -- defend or trade blows!"
		EnemyIntent.Intent.RETREATING:
			return "The %s backs away, wary." % enemy_name
		EnemyIntent.Intent.TELEGRAPHING_HOWL:
			return "The %s throws back its head..." % enemy_name
		EnemyIntent.Intent.HOWL:
			return "A HOWL is coming -- it cannot be stopped!"
	return ""
