@tool
class_name LiminalKickstartToolbar
extends HBoxContainer

const SCENE_GLOBS_SETTING := "liminal_editor/kickstart/scene_globs"
const _ES_SPAWN := "liminal_kickstart/spawn_mode"

# Item IDs in the Quick Play popup
const _ID_CURRENT := 0
const _ID_MAIN := 1
const _ID_SCENES_START := 100  # glob-matched scenes use IDs 100, 101, 102, …

var _spawn_dd: OptionButton
var _play_btn: MenuButton


func _ready() -> void:
	size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var sep_l := VSeparator.new()
	add_child(sep_l)

	_spawn_dd = OptionButton.new()
	_spawn_dd.add_item("Default Start", 0)
	_spawn_dd.add_item("Viewport Camera", 1)
	_spawn_dd.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_spawn_dd.flat = true
	_spawn_dd.theme_type_variation = "TopBarOptionButton"
	add_child(_spawn_dd)

	_play_btn = MenuButton.new()
	_play_btn.text = "▶  Quick Play"
	_play_btn.flat = true
	_play_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_child(_play_btn)

	var sep_r := VSeparator.new()
	add_child(sep_r)

	_spawn_dd.item_selected.connect(func(_i): _save_spawn())
	_play_btn.get_popup().about_to_popup.connect(_populate_play_menu)
	_play_btn.get_popup().id_pressed.connect(_on_scene_chosen)

	_restore_spawn()


func is_viewport_camera_mode() -> bool:
	return _spawn_dd.selected == 1 and not _spawn_dd.is_item_disabled(1)


func _refresh_viewport_option() -> void:
	var cam := EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
	var ok := is_instance_valid(cam)
	_spawn_dd.set_item_disabled(1, not ok)
	_spawn_dd.set_item_tooltip(1, "" if ok else "No 3D viewport camera is active")
	if _spawn_dd.is_item_disabled(_spawn_dd.selected):
		_spawn_dd.select(0)


func _restore_spawn() -> void:
	var es := EditorInterface.get_editor_settings()
	if es.has_setting(_ES_SPAWN):
		_spawn_dd.select(clampi(int(es.get_setting(_ES_SPAWN)), 0, 1))
	_refresh_viewport_option()


func _save_spawn() -> void:
	EditorInterface.get_editor_settings().set_setting(_ES_SPAWN, _spawn_dd.selected)


func _populate_play_menu() -> void:
	_refresh_viewport_option()
	var popup := _play_btn.get_popup()
	popup.clear()

	popup.add_item("Current Scene", _ID_CURRENT)
	popup.add_item("Main Scene", _ID_MAIN)

	var globs: PackedStringArray = ProjectSettings.get_setting(
			SCENE_GLOBS_SETTING, PackedStringArray())
	var scenes := LiminalKickstartSceneScanner.find_scenes(globs)
	if not scenes.is_empty():
		popup.add_separator()
		for i in scenes.size():
			popup.add_item(scenes[i].get_file().get_basename(), _ID_SCENES_START + i)
			popup.set_item_metadata(popup.item_count - 1, scenes[i])


func _on_scene_chosen(id: int) -> void:
	match id:
		_ID_CURRENT:
			var root := EditorInterface.get_edited_scene_root()
			if root == null or root.scene_file_path.is_empty():
				EditorInterface.play_current_scene()
			else:
				EditorInterface.play_custom_scene(root.scene_file_path)
		_ID_MAIN:
			EditorInterface.play_main_scene()
		_:
			var popup := _play_btn.get_popup()
			for i in popup.item_count:
				if popup.get_item_id(i) == id:
					EditorInterface.play_custom_scene(str(popup.get_item_metadata(i)))
					break
