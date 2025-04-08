extends CtrlInventoryGrid

func _refresh_field_background_grid() -> void:
	super._refresh_field_background_grid()
	for a in _field_background_grid.get_children():
		_field_background_grid.remove_child(a)

	if !is_instance_valid(inventory):
		return
	var grid_constraint: GridConstraint = inventory.get_constraint(GridConstraint)
	if grid_constraint == null:
		return

	var inv_size := grid_constraint.size
	for i in range(inv_size.x):
		_field_backgrounds.append([])
		for j in range(inv_size.y):
			var field_panel: Button = Button.new()
			field_panel.size = field_dimensions
			field_panel.position = _ctrl_inventory_grid_basic._get_field_position(Vector2i(i, j))
			_field_background_grid.add_child(field_panel)
			_field_backgrounds[i].append(field_panel)
	
