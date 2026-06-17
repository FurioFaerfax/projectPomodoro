extends Window

func _input(event: InputEvent) -> void:
	if !Settings.web_export:
		if event.is_action_pressed("ui_cancel"):
			close_requested.emit()
