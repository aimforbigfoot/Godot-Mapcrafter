# Godot Mapcrafter
## DOCS 
https://www.nadlabs.xyz/GodotMapcrafterDocs
## Overview
Welcome to the Godot Mapcrafter project, your comprehensive toolkit for generating 2D grid-based maps in Godot. This script provides a robust set of tools for creating maps with customizable tiles, including walls, floors, areas of interest, and more. Designed with flexibility and extensibility in mind, it supports a variety of map generation and manipulation techniques.

## Key Features
- Seamless Integration: Easily integrates into your projects, providing the backbone for any system that requires map generation and real-time modifications.
- Variety of Algorithms: Define and modify map sections based on various patterns and rules.
- Advanced Tools: Mark areas of interest and define sections using advanced algorithms.
- Thread-Safe Map Generation: Capable of handling large map sizes in the background. 
## Getting Started
### Installation
1. Download the Script: Save the script file as MapGenHandler.gd in your Godot project's script directory.
2. Attach to a Node: Attach the MapGenHandler script to a Node in your Godot scene.
### Initialization
In your Godot scene, attach the script to a Node and call the necessary functions to generate and manipulate your maps. Here's an example of how to initialize and use the MapGenHandler:
```gdscript
extends Node

var mapGenHandler := MapGenHandler.new()

func _ready():
    randomize()
    var width = 50
    var height = 50
    var initialTile = MapGenHandler.TILES.FLOOR
    var map = mapGenHandler.generateBlankMap(width, height, initialTile)
    map = mapGenHandler.applyStochasticCellularAutomota(map, MapGenHandler.TILES.WALL)
    mapGenHandler.printMap(map)
```

## Contributing
If you'd like to contribute to this project, please fork the repository and submit a pull request. For major changes, please open an issue to discuss what you would like to change.

## License
This project is licensed under the MIT License.
