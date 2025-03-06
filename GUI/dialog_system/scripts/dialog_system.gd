@tool
@icon("res://GUI/dialog_system/icons/star_bubble.svg")
class_name DialogSystemNode extends CanvasLayer

signal finished
signal letter_added( letter : String )

var is_active : bool = false
var text_in_progress : bool = false

@export var text_speed : float = 0.02
var text_length : int = 0
var plain_text : String

var dialog_items : Array[DialogItem]
var dialog_item_index : int = 0

@onready var dialog_ui: Control = $DialogUI
@onready var content: RichTextLabel = $DialogUI/PanelContainer/RichTextLabel
@onready var portrait_sprite: Sprite2D = $DialogUI/PortraitSprite
@onready var dialog_progress: PanelContainer = $DialogUI/DialogProgress
@onready var dialog_progress_label: Label = $DialogUI/DialogProgress/Label
@onready var timer: Timer = $DialogUI/Timer
@onready var audio_stream_player: AudioStreamPlayer = $DialogUI/AudioStreamPlayer



func _ready() -> void:
	if Engine.is_editor_hint():
		if get_viewport() is Window:
			get_parent().remove_child( self )
			return
		return
	timer.timeout.connect(_on_timer_timeout)
	hide_dialog()
	pass

func _unhandled_input(event: InputEvent) -> void:
	if is_active == false:
		return
	if(
			event.is_action_pressed("interact") or
			event.is_action_pressed("test")
	):
		if text_in_progress == true:
			content.visible_characters = text_length
			timer.stop()
			text_in_progress = false
			show_dialog_button_indicator( true )
			return
		dialog_item_index += 1
		if dialog_item_index < dialog_items.size():
			start_dialog()
		else:
			hide_dialog()
	pass
	
func show_dialog( _items : Array[ DialogItem ] ) -> void:
	is_active = true
	dialog_ui.visible = true
	dialog_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	dialog_items = _items
	dialog_item_index = 0
	get_tree().paused = true
	await get_tree().process_frame
	start_dialog()
	pass
	
func hide_dialog() -> void:
	is_active = false
	dialog_ui.visible = false
	dialog_ui.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = false
	finished.emit()
	pass

func start_dialog() -> void:
	show_dialog_button_indicator( false )
	var _d : DialogItem = dialog_items[ dialog_item_index ]
	set_dialog_data( _d )
	
	content.visible_characters = 0
	text_length = content.get_total_character_count()
	plain_text = content.get_parsed_text()
	text_in_progress = true
	start_timer()
	pass
	
	
func set_dialog_data( _d: DialogItem ) -> void:
	if _d is DialogText:
		content.text = _d.text
	portrait_sprite.texture = _d.npc_info.portrait

	pass

func show_dialog_button_indicator( _is_visible : bool ) -> void:
	dialog_progress.visible = _is_visible
	if dialog_item_index + 1 < dialog_items.size():
		dialog_progress_label.text = "NEXT"
	else:
		dialog_progress_label.text = "END"

func start_timer() -> void:
	timer.wait_time = text_speed
	timer.start()
	pass
	
func _on_timer_timeout() -> void:
	content.visible_characters += 1
	if content.visible_characters <= text_length:
		start_timer()
	else:
		show_dialog_button_indicator( true )
		text_in_progress = false
	
	pass
