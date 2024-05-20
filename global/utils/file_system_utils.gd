class_name FileSystemUtils

const USER_PATH: String = "user://"
const RESOURCES_PATH: String = "res://resources/"


static func get_user_files() -> Array[String]:
	return get_files(FileSystemUtils.USER_PATH)


static func get_files(path: String) -> Array[String]:
	var files: Array[String] = []
	for file: String in DirAccess.get_files_at(path):
		files.append(file)
	return files


static func get_resources(resource_path: String, recursive: bool) -> Dictionary:
	var path: String = FileSystemUtils.RESOURCES_PATH + resource_path + "/"
	var resources: Dictionary = {}
	for file: String in DirAccess.get_files_at(path):
		if file.ends_with(".remap"):
			file = file.trim_suffix(".remap")
		if file.ends_with(".tres"):
			var resource: Resource = load(path + file) as Resource
			if resource != null:
				var id: String = file.split(".")[0]
				resources[id] = resource
	if recursive:
		for dir: String in DirAccess.get_directories_at(path):
			var resources_dir: Dictionary = get_resources(resource_path + "/" + dir, recursive)
			resources.merge(resources_dir)
	return resources
