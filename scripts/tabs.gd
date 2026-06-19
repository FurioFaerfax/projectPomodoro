extends TabContainer

@onready var audioplayer: TabBar = %audioplayer

func _ready() -> void:
	Signals.set_music_active_state.connect(music_player_state)
	if !Settings.settings["music_enabled"]:
		music_player_state(false)

func music_player_state(boo):
	set_tab_disabled(audioplayer.get_index(), !boo)
