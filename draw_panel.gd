extends Panel

@export var brush_thickness : float = 15
@export var brush_color : Color = Color.WHITE
@export var brush_softness: float = 0.5
@export var width_curve : Curve = preload("res://width_curve.tres")

# current Line2D object
var active_line

# materials used for pen and eraser
var draw_material
var erase_material

const LINE_GROUP = preload("res://line_group.tscn")
const BLUR = preload("res://blur.tres")

@onready var mode_label: Label = $Panel/VBoxContainer/ModeLabel
@onready var root := $Lines/LineGroup

# operating modes
enum MODE {
	DRAW,
	ERASE,
}
var current_mode = MODE.DRAW

func _ready():
	draw_material = CanvasItemMaterial.new()
	draw_material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	erase_material = CanvasItemMaterial.new()
	erase_material.blend_mode = CanvasItemMaterial.BLEND_MODE_SUB
	root.material.set_shader_parameter("blur_radius", brush_softness)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_LEFT:
				active_line = Line2D.new()
				if current_mode == MODE.DRAW:
					active_line.default_color = brush_color
					active_line.material = draw_material
				elif current_mode == MODE.ERASE:
					active_line.default_color = Color(0, 0, 0, 1)
					active_line.material = erase_material
				active_line.position = event.position
				active_line.width = brush_thickness
				active_line.points = [Vector2(0, 0)]
				active_line.width_curve = width_curve
				active_line.joint_mode = Line2D.LINE_JOINT_ROUND
				active_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
				active_line.end_cap_mode = Line2D.LINE_CAP_ROUND
				root.add_child(active_line)

	elif event is InputEventScreenDrag:
		var points = active_line.points
		points.append(event.position - active_line.position)
		active_line.points = points

func undo_last():
	var count = root.get_child_count()
	if count > 0:
		print("Undo. Current stroke count:", count)
		root.get_child(count - 2).queue_free()
		root.get_child(count - 1).queue_free()


func _on_color_changed(color: Color) -> void:
	brush_color = color


func _on_thickness_changed(value: float) -> void:
	brush_thickness = value


func _on_softness_changed(value: float) -> void:
	brush_softness = value
	root.material.set_shader_parameter("blur_radius", brush_softness)
	
	# # uncomment this part if you want independent softness for each line
	#var new_line_group = LINE_GROUP.instantiate()
	#$Lines.add_child(new_line_group)
	#new_line_group.material = BLUR.duplicate()
	#root = new_line_group
	#new_line_group.material.set_shader_parameter("blur_radius", brush_softness)


func _on_brush_button_pressed() -> void:
	current_mode = MODE.DRAW
	mode_label.text = "DRAW MODE"

func _on_eraser_button_pressed() -> void:
	current_mode = MODE.ERASE
	mode_label.text = "ERASE MODE"

func _on_undo_button_pressed() -> void:
	undo_last()
