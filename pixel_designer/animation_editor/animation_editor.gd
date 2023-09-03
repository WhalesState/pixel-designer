@tool
extends PanelContainer

signal frame_changed(frame: int)

var cur_anim := []
var anim_timer := Timer.new()

var anim_interval := 0.1:
    set(value):
        anim_interval = value
        anim_timer.wait_time = anim_interval

var frame := 0:
    set(value):
        frame = wrapi(value, 0, cur_anim[0].size())
        if (value != 0 and frame == 0) and not anim_timer.is_stopped() and not loop_button.button_pressed:
            _on_stop_animation_pressed()
        if cur_anim:
            emit_signal("frame_changed", cur_anim[0][frame])

@onready var pixel_editor = get_node("%PixelEditor")
@onready var cur_animation = []
@onready var loop_button = get_node("%AnimLoop")


func _ready():
    anim_timer.timeout.connect(_on_anim_timer_timeout)
    anim_timer.wait_time = anim_interval
    add_child(anim_timer)


func _on_anim_timer_timeout():
    frame += 1


func seek_frame(seek: int):
    frame += seek


func _on_play_animation_toggled(is_playing: bool):
    if is_playing:
        anim_timer.start()
    else:
        anim_timer.stop()


func _on_stop_animation_pressed():
    if not anim_timer.is_stopped():
        var play_button = get_node("%PlayButton")
        play_button.set_pressed(false)
        play_button.emit_signal("button_up")
    frame = 0


func _on_anim_speed_value_changed(value:float):
    anim_interval = value / 1000
