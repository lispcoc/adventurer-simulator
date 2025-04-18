extends TileMapLayer

## Emitted when the highlighted cell changes to a new value. An invalid cell is indicated by a value
## of [constant Gameboard.INVALID_CELL].
@warning_ignore("unused_signal")
signal focus_changed(old_focus: Vector2i, new_focus: Vector2i)

## Emitted when a cell is selected via input event.
signal selected(selected_cell: Vector2i)

@export var ptr : Node2D

func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		get_viewport().set_input_as_handled()
		set_focus(_get_cell_under_mouse())
	
	elif event.is_action_released("select"):
		get_viewport().set_input_as_handled()
		
		selected.emit(_get_cell_under_mouse())
		FieldEvents.cell_selected.emit(_get_cell_under_mouse())
		print(_get_cell_under_mouse())
		$"../Pawn".target = _get_cell_under_mouse()

		#var pos =  gameboard.cell_to_pixel(_get_cell_under_mouse())
		#var tween = get_tree().create_tween()
		#tween.tween_property(ptr, "global_position", pos, 1)
		#tween.play()
		#await tween.finished

# Convert mouse/touch coordinates to a gameboard cell.
func _get_cell_under_mouse() -> Vector2i:
	# The mouse coordinates need to be corrected for any scale or position changes in the scene.
	var mouse_position: = ((get_global_mouse_position()-global_position) / global_scale)
	var cell_under_mouse = $"..".gameboard.pixel_to_cell(mouse_position)
	
	if not $"..".gameboard.boundaries.has_point(cell_under_mouse):
		cell_under_mouse = Gameboard.INVALID_CELL
	
	return cell_under_mouse

## Change the highlighted cell to a new value. A value of [constant Gameboard.INVALID_CELL] will
## indicate that there is no highlighted cell.
## [br][br][b]Note:[/b] Values will be limited to [member valid_cells] if valid_cells is not empty.
## Values outside of valid_cells will not be focused.
func set_focus(_value: Vector2i) -> void:
	pass
