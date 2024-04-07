extends HSlider

@onready var SFX_BUS_ID

func _ready() -> void:
	SFX_BUS_ID = AudioServer.get_bus_index("SFX")
	value_changed.connect(_on_music_slider_value_changed)
	value = db_to_linear(AudioServer.get_bus_volume_db(SFX_BUS_ID))
	
func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_BUS_ID, value < .05)
