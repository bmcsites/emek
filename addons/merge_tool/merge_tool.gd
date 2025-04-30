
extends EditorPlugin

var button

func _enter_tree():
	button = Button.new()
	button.text = "🧱 Merge Buildings"
	button.pressed.connect(_on_merge_pressed)
	add_control_to_container(CONTAINER_TOOLBAR, button)

func _exit_tree():
	remove_control_from_container(CONTAINER_TOOLBAR, button)
	button.queue_free()

func _on_merge_pressed():
	var scene = get_editor_interface().get_edited_scene_root()
	if not scene:
		print("No scene loaded.")
		return

	var buildings_root = scene.get_node("buildings")
	if not buildings_root:
		push_error("Node 'buildings' not found.")
		return

	for row in buildings_root.get_children():
		var array_mesh := ArrayMesh.new()
		var has_mesh := false

		for building in row.get_children():
			var mesh_instance := building.find_child("MeshInstance3D", true, false)
			if mesh_instance and mesh_instance.mesh:
				var arrays = mesh_instance.mesh.surface_get_arrays(0)
				array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
				has_mesh = true

		if has_mesh:
			var merged_instance := MeshInstance3D.new()
			merged_instance.name = "MergedMesh"
			merged_instance.mesh = array_mesh
			row.add_child(merged_instance)

			var static_body = StaticBody3D.new()
			static_body.name = "MergedCollider"
			var collision_shape = CollisionShape3D.new()
			collision_shape.shape = array_mesh.create_trimesh_shape()
			static_body.add_child(collision_shape)
			row.add_child(static_body)

			print("✅ Merged:", row.name)
