@tool
class_name LiminalKickstartSceneScanner
extends RefCounted


static func find_scenes(globs: PackedStringArray) -> Array[String]:
	if globs.is_empty():
		return []
	var results: Array[String] = []
	_scan_dir(EditorInterface.get_resource_filesystem().get_filesystem(), globs, results)
	results.sort()
	return results


static func _scan_dir(dir: EditorFileSystemDirectory,
		globs: PackedStringArray, out: Array[String]) -> void:
	for i in dir.get_file_count():
		var path := dir.get_file_path(i)
		if path.get_extension() == "tscn" and _matches_any(path, globs):
			out.append(path)
	for i in dir.get_subdir_count():
		_scan_dir(dir.get_subdir(i), globs, out)


static func _matches_any(path: String, globs: PackedStringArray) -> bool:
	for g in globs:
		if _glob_match(path.trim_prefix("res://"), g.trim_prefix("res://")):
			return true
	return false


static func _glob_match(path: String, glob: String) -> bool:
	return _seg_match(path.split("/"), glob.split("/"), 0, 0)


# Glob match algorithm
static func _seg_match(pp: PackedStringArray, gp: PackedStringArray,
		pi: int, gi: int) -> bool:
	if pi == pp.size() and gi == gp.size():
		return true
	if gi == gp.size():
		return false
	if gp[gi] == "**":
		# consume zero path segments (skip **)
		if _seg_match(pp, gp, pi, gi + 1):
			return true
		# consume one path segment and retry **
		if pi < pp.size():
			return _seg_match(pp, gp, pi + 1, gi)
		return false
	if pi == pp.size():
		return false
	return pp[pi].match(gp[gi]) and _seg_match(pp, gp, pi + 1, gi + 1)
