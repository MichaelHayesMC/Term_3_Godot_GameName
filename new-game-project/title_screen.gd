extends CanvasLayer

@onready var session_id: TextEdit = %SessionID

func _ready() -> void:
	Network.tube_client.error_raised.connect(on_error_raised)
	
	if OS.has_feature('server'):
		Network.start_server()

func _on_join_tube_pressed() -> void:
	Network.tube_join(session_id.text)
	hide()

func _on_create_tube_pressed() -> void:
	Network.tube_create()
	hide()

func on_error_raised(_code, _message):
	%JoinTube.disabled
	Network.clean_up_signals()
