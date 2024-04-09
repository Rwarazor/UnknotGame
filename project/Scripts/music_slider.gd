extends HSlider

@onready var MUSIC_BUS_ID

func _ready() -> void:
	MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
	value_changed.connect(_on_music_slider_value_changed)
	value = db_to_linear(AudioServer.get_bus_volume_db(MUSIC_BUS_ID))
	
func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < .05)
