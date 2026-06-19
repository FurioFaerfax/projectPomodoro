extends AudioStreamPlayer

var path := ""#"user://sounds/music/"

const DEFAULT = preload("uid://b3vsw365lf3ut")
@onready var music_path_not_valid: ConfirmationDialog = %music_path_not_valid
@onready var music_path: FileDialog = %music_path
@onready var audio_title_label: Label = %audio_title_label
@onready var audio_time_label: Label = %audio_time_label
@onready var audio_progress_bar: TextureProgressBar = %audio_progress_bar
@onready var audio_timer: Timer = %audioTimer

#var soundNames := [str(path, "alienruins.ogg"), str(path, "battleUx.ogg"), str(path, "corpoBoss.ogg"), str(path, "filature.ogg"), str(path, "hacked.ogg"), str(path, "humanFarm.ogg"), str(path, "intruding.ogg"), str(path, "streetFight.mp3")]
var files_in_directory := []
var supported_extensions := ["ogg", "mp3"]
var supported_string := "":
	set(val):
		supported_string = " (supported formats: "
		for type in supported_extensions:
			supported_string+=type
			if type != supported_extensions[supported_extensions.size()-1]:
				supported_string += ", "
		supported_string += ")"

var playlist := {}
var current_track_id := 0
var current_track = ""
var current_track_remaining_length = 0

func _ready() -> void:
	supported_string = ""
	initialize_music()
	Signals.set_music_active_state.connect(toggled_music_state)

func toggled_music_state(active):
	initialize_music()
		
func initialize_music():
	if Settings.settings["music_enabled"]:
		if playlist.size() == 0:
			if Settings.settings["music_path"] == "":
				music_path.popup()
			else:
				path = Settings.settings["music_path"]
				setup_playlist()
			
		current_track_remaining_length = stream.get_length()
	else:
		stop()
			
			
func setup_playlist():
	get_playlist(read_directory_contents(path))
	if playlist.size() > 0:
		print("PLAYLIST:\n",get_playlist_entries())
		print("Now playing: ",current_track)
	else:
		path = ""
		files_in_directory = []
		music_path_not_valid.popup()

func get_next_track():
	current_track_id = 0 if current_track_id == playlist.size()-1 else current_track_id+1
	set_sound(playlist[current_track_id])
	current_track_remaining_length = stream.get_length()
	audio_progress_bar.value = 0.0
	audio_progress_bar.max_value = current_track_remaining_length



##Sets the sound if it exists, otherwise it will place the default sound
func set_sound(snd):
	if snd[1]:
		stream = snd[1]
		current_track = snd[0]
	else:
		stream = DEFAULT
		current_track = "DEFAULT"
	
	audio_title_label.text = "Now Playing: "+current_track
	audio_time_label.text = "Now Playing: "+current_track

#region setting up the playlist
func get_path_parts(path_to_file: String) -> Array:
	var error = OK
	var error_msg = ""
	var path_splitted = path_to_file.split("/")
	var file = path_splitted[path_splitted.size()-1]
	var _path = path_to_file.erase(path_to_file.length() - file.length(), file.length())
	var file_name = file.split(".")[0] if file.split(".").size() == 2 else ""
	var file_extension = ""
	if file_name != "":
		file_extension = file.split(".")[1] if file.split(".")[1] in supported_extensions else ""
	var splitsize:int = file.split(".").size()
	
	if file_extension == "":
		error = FAILED
		error_msg = str("ERROR: Filetype not supported",supported_string)
	if splitsize == 1:
		error = FAILED
		file_name = file
		error_msg = str("ERROR: no extension recognized",supported_string)
	elif splitsize > 2:
		error = FAILED
		file_name = file
		error_msg = str("ERROR: filename may should have a single extension and no leading period",supported_string)
	
	if error == OK:
		return [[_path, file_name, file_extension], OK, "file successfully splitted"]
	else:
		return [["", file_name, ""], error, error_msg]

func get_playlist(files):
	for track in files:
		var file_path_splitted = get_path_parts(track)
		#print(file_path_splitted)
		var snd = null
		if file_path_splitted[1] == OK:
			if file_path_splitted[0][2] == "ogg":
				snd = load_song_ogg(file_path_splitted[0])
			elif file_path_splitted[0][2] == "mp3":
				snd = load_song_mp3(file_path_splitted[0])
				
			if snd != null:
				playlist[playlist.size()] = [file_path_splitted[0][1], snd]
			else:
				print("ERROR: File not found: ", file_path_splitted[0][1],".",file_path_splitted[0][2])
				for _track in playlist:
					if _track.has(file_path_splitted[1]):
						playlist.erase(_track)
		else:
			print("Problem with:", file_path_splitted[0][1], " ", file_path_splitted[2])
	if playlist.size() > 0:
		set_sound(playlist[0])
	else:
		set_sound([null, null])
#endregion

#region different loading functions
func load_song_ogg(_file):
	var path :String = str(_file[0],_file[1],".ogg")
	#print(path)
	var file = FileAccess.open(path, FileAccess.READ)
	if file != null:
		var _sound = AudioStreamOggVorbis.load_from_file(path)
		return _sound
	else:
		return null

func load_song_mp3(_file):
	var path :String = str(_file[0],_file[1],".mp3")
	#print(path)
	var file = FileAccess.open(path, FileAccess.READ)
	var sound := AudioStreamMP3.new()
	#print(path," ",file," ", sound)
	if file != null:
		sound.data = file.get_buffer(file.get_length())
		return sound
	else:
		return null
#endregion

func get_playlist_entries() -> String:
	var track_names:= ""
	for track in playlist:
		track_names += str(track+1, ": ", playlist[track][0],"\n")
	return track_names



func read_directory_contents(dir_path: String) -> PackedStringArray:
	var file_paths = []
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				file_paths.append(dir_path.path_join(file_name))
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Cannot open directory: " + dir_path)
	return file_paths


func _on_music_path_confirmed() -> void:
	pass


func _on_music_path_dir_selected(dir: String) -> void:
	print(dir)
	path = dir+"/"
	Settings.change_setting("music_path", path)
	setup_playlist()


func _on_music_path_canceled() -> void:
	pass


func _on_music_path_not_valid_canceled() -> void:
	pass # Replace with function body.


func _on_music_path_not_valid_confirmed() -> void:
	music_path.popup()


func _on_music_volume_value_changed(value: float) -> void:
	volume_linear = value

func startTimerStop(start, restart):
	print(start, " ", restart)
	if start:
		audio_progress_bar.max_value = stream.get_length()
		if restart:
			current_track_remaining_length = stream.get_length()
			audio_progress_bar.value = 0.0
		audio_timer.start()
	else:
		audio_timer.stop()
		if restart:
			current_track_remaining_length = stream.get_length()
			audio_progress_bar.value = 0.0

func _on_audio_timer_timeout() -> void:
	if current_track_remaining_length > 0:
		audio_timer.start(1)
		current_track_remaining_length -= 1
		print(current_track_remaining_length)
		print(str(stream.get_length()-current_track_remaining_length, " / ", stream.get_length()))
		print(audio_progress_bar.value, " / ", audio_progress_bar.max_value)
		
		audio_progress_bar.value+= 1


func _on_finished() -> void:
	get_next_track()
	play()
