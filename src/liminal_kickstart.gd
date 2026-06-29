## Static API for reading the Liminal Kickstart spawn override at game runtime.
##
## Usage in your spawn code:
##   if LiminalKickstart.has_spawn_override():
##       player.position = LiminalKickstart.get_spawn_position()
##       player.rotation = LiminalKickstart.get_spawn_rotation()

class_name LiminalKickstart
extends RefCounted

const _ARG_PREFIX := "--lk-spawn="


static func has_spawn_override() -> bool:
	return not _find_arg().is_empty()


static func get_spawn_position() -> Vector3:
	var p := _parse_floats()
	if p.is_empty():
		return Vector3.ZERO
	return Vector3(p[0], p[1], p[2])


static func get_spawn_rotation() -> Vector3:
	var p := _parse_floats()
	if p.is_empty():
		return Vector3.ZERO
	return Vector3(p[3], p[4], p[5])


static func _find_arg() -> String:
	for arg in OS.get_cmdline_args():
		if arg.begins_with(_ARG_PREFIX):
			return arg.trim_prefix(_ARG_PREFIX)
	return ""


static func _parse_floats() -> PackedFloat32Array:
	var data := _find_arg()
	if data.is_empty():
		return PackedFloat32Array()
	var p := data.split(",")
	if p.size() != 6:
		push_warning("LiminalKickstart: malformed spawn arg (%d parts, expected 6)" % p.size())
		return PackedFloat32Array()
	var result := PackedFloat32Array()
	for s in p:
		result.append(float(s))
	return result
