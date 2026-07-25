extends Panel

@onready var close_panel: PanelContainer = $PopupBox/ClosePanel
@onready var back_panel: PanelContainer = $PopupBox/BackPanel

# Page 1
@onready var page_1: MarginContainer = $PopupBox/Page_1
@onready var heading: Label = $PopupBox/Page_1/Column/Header/Label
@onready var word_list: VBoxContainer = $PopupBox/Page_1/Column/ScrollContainer/WordList
@onready var word_template: Button = $PopupBox/Page_1/Column/ScrollContainer/WordList/WordTemplate
@onready var padding_template: MarginContainer = $PopupBox/Page_1/Column/ScrollContainer/WordList/PaddingTemplate

# Page 2
@onready var page_2: MarginContainer = $PopupBox/Page_2
@onready var word_heading: Label = $PopupBox/Page_2/Column/Concept/Word
@onready var word_definition: RichTextLabel = $PopupBox/Page_2/Column/Concept/Definition
@onready var count: Label =  $PopupBox/Page_2/Column/ButtonRow/Count/Label
@onready var left_btn: Button = $PopupBox/Page_2/Column/ButtonRow/LeftButton
@onready var right_btn: Button = $PopupBox/Page_2/Column/ButtonRow/RightButton

var current_concepts: Dictionary = {}
var current_index: int = 0
var current_size: int = 0

func _ready() -> void:
	page_1.show()
	page_2.hide()
	back_panel.hide()
	close_panel.gui_input.connect(_on_close_panel_gui_input)
	back_panel.gui_input.connect(_on_back_panel_gui_input)
	left_btn.pressed.connect(_on_left_btn_pressed)
	right_btn.pressed.connect(_on_right_btn_pressed)
	word_definition.bbcode_enabled = true

func setup_word_list(concepts: Dictionary) -> void:
	word_template.hide()
	padding_template.hide()
	
	var words: Array = concepts.keys()
	current_concepts = concepts
	current_size = words.size()
	heading.text = str(words.size()) + " Concepts"
	
	for word in words:
		var new_word = word_template.duplicate()
		new_word.text = word
		new_word.show()
		new_word.pressed.connect(_on_word_pressed.bind(word))
		word_list.add_child(new_word)
	
	var padding_bottom = padding_template.duplicate()
	padding_bottom.show()
	word_list.add_child(padding_bottom)

func open_word_clicked(word: String) -> void:
	open_popup()
	_on_word_pressed(word)

# -- POPUP BUTTONS --
func open_popup() -> void:
	page_1.show()
	page_2.hide()
	back_panel.hide()
	show()

func close_popup() -> void:
	hide()

func _on_close_panel_gui_input(event: InputEvent) -> void:
	var is_tap = event is InputEventScreenTouch and event.pressed
	var is_click = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	
	if is_tap or is_click:
		close_popup()

func _on_word_pressed(word: String):
	page_1.hide()
	page_2.show()
	back_panel.show()
	
	word_heading.text = word
	word_definition.text = current_concepts.get(word)
	current_index = current_concepts.keys().find(word)
	count.text = str(current_index + 1) + " / " + str(current_size)

func _on_back_panel_gui_input(event: InputEvent) -> void:
	var is_tap = event is InputEventScreenTouch and event.is_released()
	var is_click = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released()
	
	if is_tap or is_click:
		page_1.show()
		page_2.hide()
		back_panel.hide()

func _on_left_btn_pressed() -> void:
	if current_index == 0:
		current_index = current_size - 1
	else:
		current_index -= 1
	_on_word_pressed(current_concepts.keys()[current_index])

func _on_right_btn_pressed() -> void:
	if current_index == current_size - 1:
		current_index = 0
	else:
		current_index += 1
	_on_word_pressed(current_concepts.keys()[current_index])
