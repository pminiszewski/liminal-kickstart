@tool
extends EditorPlugin

var _toolbar: LiminalKickstartToolbar

func _enter_tree() -> void:
	_register_project_settings()
	_add_toolbar.call_deferred()


func _add_toolbar() -> void:
	_toolbar = LiminalKickstartToolbar.new()
	_toolbar.name = "LiminalKickstartToolbar"
	add_control_to_container(CONTAINER_TOOLBAR, _toolbar)
	# Move to the left of the play buttons
	var parent: Control = _toolbar.get_parent()
	if parent:
		for i in parent.get_child_count():
			if parent.get_child(i).get_class() == "EditorRunBar":
				parent.move_child(_toolbar, i)
				break


func _exit_tree() -> void:
	if _toolbar and is_instance_valid(_toolbar):
		remove_control_from_container(CONTAINER_TOOLBAR, _toolbar)
		_toolbar.queue_free()

func _run_scene(scene: String, args: PackedStringArray) -> PackedStringArray:
	if _toolbar == null or not is_instance_valid(_toolbar):
		return args
	if not _toolbar.is_viewport_camera_mode():
		return args
	var cam := EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
	if not is_instance_valid(cam):
		push_warning("LiminalKickstart: No 3D viewport camera active; using default spawn.")
		return args
	args.append(_encode_spawn_arg(cam.global_transform))
	return args


static func _encode_spawn_arg(xform: Transform3D) -> String:
	var o := xform.origin
	var e := xform.basis.get_euler()
	return "--lk-spawn=%s,%s,%s,%s,%s,%s" % [o.x, o.y, o.z, e.x, e.y, e.z]


func _register_project_settings() -> void:
	var key := LiminalKickstartToolbar.SCENE_GLOBS_SETTING
	if not ProjectSettings.has_setting(key):
		ProjectSettings.set_setting(key, PackedStringArray())
		ProjectSettings.set_initial_value(key, PackedStringArray())
	ProjectSettings.add_property_info({
		"name": key,
		"type": TYPE_PACKED_STRING_ARRAY,
	})
