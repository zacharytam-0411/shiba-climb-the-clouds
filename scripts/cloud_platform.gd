extends Node2D

@export var tilemap_layer: TileMapLayer
@export var tile_names: Array[String] = ["Cloud1", "Cloud2", "Cloud3"]

var tile_name_lookup: Dictionary = {}
