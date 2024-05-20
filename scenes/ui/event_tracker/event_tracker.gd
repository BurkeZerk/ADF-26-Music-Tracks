extends MarginContainer

@onready var event_v_box_container: VBoxContainer = %EventVBoxContainer
@onready var scroll_container: ScrollContainer = %ScrollContainer

@export var event_item_scene: PackedScene
@export var PAGE_SIZE: int = 20

var _total_lines: int = 0

###############
## overrides ##
###############


func _ready() -> void:
	_load_from_save_file()
	_connect_signals()

	if Game.params["debug_no_scrollbar"]:
		ScrollContainerUtils.disable_scrollbars(scroll_container)


#############
## helpers ##
#############


func _load_from_save_file() -> void:
	_clear_items()
	var next_index: int = SaveFile.event_log.size()
	var load_range: int = next_index
	if Game.params["debug_no_scrollbar"]:
		load_range = min(PAGE_SIZE, next_index)
	for index: int in range(load_range):
		var event_log_index: int = index + 1
		var event_log: Dictionary = SaveFile.event_log[str(event_log_index)]
		var event_data_id: String = event_log["event_data"]
		var event_data: EventData = Resources.event_datas[event_data_id]
		var vals: Array = event_log["vals"]
		_add_event(event_data, vals, event_log_index, false)


func _add_event(event_data: EventData, vals: Array, index: int, new: bool) -> void:
	var event_item: EventTrackerItem = _add_item()
	event_item.set_content(event_data, vals, index, new)
	_total_lines += 1
	if Game.params["debug_no_scrollbar"]:
		while _total_lines > PAGE_SIZE:
			NodeUtils.remove_oldest(event_v_box_container)
			_total_lines -= 1


func _add_item() -> EventTrackerItem:
	var event_item: EventTrackerItem = event_item_scene.instantiate() as EventTrackerItem
	NodeUtils.add_child_front(event_item, event_v_box_container)
	return event_item


func _clear_items() -> void:
	_total_lines = 0
	NodeUtils.clear_children(event_v_box_container)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.event_saved.connect(_on_event_saved)


func _on_event_saved(event_data: EventData, vals: Array, index: int) -> void:
	_add_event(event_data, vals, index, true)
