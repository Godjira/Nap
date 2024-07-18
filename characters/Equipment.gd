extends Node2D
class_name Equipment

var item_example = {
	"id": 0,
	"name": "Axe",
	"damage": 3.0,
	"mesh_name": "Weapon_Axe_0",
	"show":	item_show.bind(self, "Weapon_Axe_0"),
	'type': 'melee_veritical'
}


# create equepmets array to store item object
var items = [item_example]

var player

func show_items():
	for item in items:
		var mesh = item_show(item.mesh_name)
		item.mesh = mesh

func item_show(mesh_name):
	if(mesh_name):
		var m = player.model as Node3D
		var skeleton = m.get_node("Skeleton3D")
		var item_mesh = skeleton.get_node(mesh_name) as MeshInstance3D
		item_mesh.show()
		return item_mesh
