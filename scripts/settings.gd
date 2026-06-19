extends Node

const APP_NAME = "projectPomodoro"
const VERSION: String = "v0.5.0"
const AUTHOR = "Furio Faerfax"
const USER_DIR: String = "user://"
const SETTINGS_FILE: String = "settings.json"
const COPYRIGHT_YEAR := 2026
const sound_dir: String = "sounds/"


var bb_link_color = "#aaaaFF"


#region settings variables etc.
# this should be used to deactivate certain functionalities when exporting to web platforms,
# e.g. having multiple windows, storing data on a specific path, etc.
# In the world script is a export var to toggle this state more easily
var web_export :bool = false
var dev_mode :bool
var edit_mode := true
var init = false

enum LANGUAGES{
	ENG,
	GER,
}

# Theoretically you can use the Project Settings for the keys, but for remapping purposes, you need to save and load them anyways, setting them in the settings gives you autocomplete functionality
var key_bindings: = {
	"wheel_down": MOUSE_BUTTON_WHEEL_DOWN,
	"wheel_up": MOUSE_BUTTON_WHEEL_UP,
	#"wheel_pressed": MOUSE_BUTTON_MIDDLE,#Setting these two entries, somehow prevents the app to recognize them in orbit mode
	#"mouse_right": MOUSE_BUTTON_RIGHT,
	"mouse_left": MOUSE_BUTTON_WHEEL_LEFT,
}

var settings: Dictionary = {
	"first_start": true,
	"key_bindings": key_bindings,
	"language": LANGUAGES.ENG,
	"music_path": "",
	"music_enabled": false,
	}

var key_map: Dictionary = {"f1": KEY_F1, "f2": KEY_F2, } # Entries written in this line are not saved by default to the settings file
#endregion

func _ready() -> void:
	_load_settings()
	
	if settings["first_start"] == true:
		DirAccess.make_dir_recursive_absolute(USER_DIR+sound_dir)
		init = true
		print("JHKLH")
		change_setting("first_start", false)
		_save_settings()
		_load_settings()
	
	_load_key_map()
	#var file = file_handler.new()


#region settings logic
func _input(event: InputEvent) -> void:
	if !Settings.web_export:
		if event.is_action_pressed("ui_cancel") and Settings.dev_mode:
			get_tree().quit()
		
		if event.is_action_pressed("f1"):
			_open_user_directory()

func _open_user_directory():
	OS.shell_open(OS.get_user_data_dir())

func change_setting(setting, boo):
	## When a setting is changed, the dictionary gets updated
	if setting in settings:
		settings[setting] = boo
	_save_settings()

func _save_settings():
	var file = FileAccess.open(str(USER_DIR,SETTINGS_FILE), FileAccess.WRITE)
	file.store_line(JSON.stringify(settings))
	file.close()

func _load_settings():
	var file = FileAccess.open(str(USER_DIR,SETTINGS_FILE), FileAccess.READ)
	var json_string
	var _settings
	if file: 
		json_string = file.get_as_text()
		file.close()
		var json = JSON.parse_string(json_string)
		if json != null:
			_settings = json
		else:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())

	for setting in settings:
		
		match setting:
			"first_start":
				if !_settings:
					_save_settings()
					_load_settings()
					return
				settings["first_start"] = true if _settings["first_start"] else false
				
			"key_bindings":
				for key in _settings["key_bindings"].keys():
					if key in key_bindings:
						key_bindings[key] = _settings["key_bindings"][key]
						key_map[key] = key_bindings[key]
					else:
						print("This key is not valid, sorry")
			"music_enabled":
				settings[setting] = _settings[setting]
			"music_path":
				settings[setting] = _settings[setting]
			_:
				pass
	#resaves the settings after a key was added in the dictionary
	if key_bindings.size() != _settings["key_bindings"].size():
		_save_settings()
#region Keybinding logic
## Change or add Keybindings, add = true if a new key should be added, false if you just wantto change a existing one
func change_or_add_key_binding(action: String, new_key: Key, add: bool):
	if InputMap.has_action(action):
		InputMap.action_erase_events(action)
	else:
		InputMap.add_action(action)
	
	var ev = InputEventKey.new()
	ev.keycode = new_key
	InputMap.action_add_event(action, ev)
	
	if not add:
		print(new_key)
		settings["key_bindings"][action] = new_key
		key_map[action] = new_key
	_save_settings()

func _load_key_map():
	for key in key_map.size():
		change_or_add_key_binding(key_map.keys()[key], key_map[key_map.keys()[key]] as Key, true)
#endregion
#endregion

func get_app_infos() -> String:
	var info = str(APP_NAME," - ", VERSION, "\nCopyright (c) ",COPYRIGHT_YEAR," ",AUTHOR,"\n\n")
	info += str("\n\n", "The Project itself is available on [url=https://github.com/FurioFaerfax/projectPomodoro][color=",bb_link_color,"]Github[/color][/url] under the [url=https://www.apache.org/licenses/LICENSE-2.0][color=",bb_link_color,"]Apache License 2.0[/color][/url]")
	return info
