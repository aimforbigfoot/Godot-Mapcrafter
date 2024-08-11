# Godot Mapcrafter
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
```
gdscript
Copy code
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
## Functionality
### Map Generation Functions
- `func generateBlankMap(height: int, width: int, cellToSetWith: int) -> Array:`. This function creates a blank map of specified dimensions. Each cell in the map is initialized with the `cellToSetWith` tile type.
- `func generateBorderedMap(width: int, height: int, border_tile: int, inner_tile: int, border_thickness: int = 1) -> Array:`. This function generates a map with a border around it. The border has a specified thickness and is filled with the `border_tile`, while the inside area is filled with the `inner_tile`.
- `func generateDiagonalStripesMap(width: int, height: int, tile_type1: int, tile_type2: int, stripe_width: int = 1, reverse_direction: bool = false) -> Array:`. This function creates a map with diagonal stripes. The stripes alternate between `tile_type1` and `tile_type2`, and the width of each stripe is defined by `stripe_width.` You can reverse the direction of the stripes if desired.
- `func generateRowMap(width: int, height: int, tile_type1: int, tile_type2: int, row_thickness: int) -> Array:`. This function generates a map with horizontal stripes or rows. The rows alternate between `tile_type1` and `tile_type2`, and the thickness of each row is specified by row_thickness.
- `func generateColumnMap(width: int, height: int, tile_type1: int, tile_type2: int, column_thickness: int) -> Array:`. This function generates a map with vertical stripes or columns. The columns alternate between `tile_type1` and `tile_type2`, and the thickness of each column is specified by column_thickness.
- `func generateCheckerboardMap(width: int, height: int, tile_type1: int, tile_type2: int, square_size: int) -> Array:`. This function generates a checkerboard pattern map. The squares alternate between `tile_type1` and `tile_type2`, and the size of each square is defined by square_size.



### Map Modification Functions
applyStochasticCellularAutomota(map: Array, cellToSet: int, randomChance: float = 0.5) -> Array: Applies a stochastic cellular automaton to modify the map.
applyRadialSymmetry(map: Array) -> Array: Applies radial symmetry to the map.
applyMirrorVertical(map: Array, flipFromLeftToRight: bool = true) -> Array: Applies vertical mirroring to the map.
applyMirrorHorizontal(map: Array, flipFromTopToBottom: bool = true) -> Array: Applies horizontal mirroring to the map.
applyFastPerlinNoise(freqVal: float, thresholdValue: float, cellToSet: int, map: Array) -> Array: Applies Perlin noise to the map.
applyFastValueNoise(freqVal: float, thresholdValue: float, cellToSet: int, map: Array) -> Array: Applies value noise to the map.
applyCellularAutomata(generations: int, cellToApplyWith: int, cellToBlankWith: int, map: Array) -> Array: Applies cellular automata rules to the map.
applyErosion(iterations: int, cellToApplyWith: int, cellToGetRidOf: int, map: Array) -> Array: Applies erosion to the map.
applyConnectionsToAllSections(connectionSize: int, tile_type: int, map: Array) -> Array: Connects all sections in the map with corridors.
applySpecificTileToARandomSetOfTiles(cellToGetSelectionOf: int, cellToTurnInto: int, map: Array) -> Array: Applies a specific tile to a random set of tiles in the map.

### Utility Functions
setCell(x: int, y: int, cellToSet: int, map: Array) -> Array: Sets a cell in the map with boundary checks.
getCell(x: int, y: int, map: Array) -> int: Gets the type of a cell in the map.
getRandomTileType(arrOfPossibleTiles: Array) -> int: Returns a random tile type from an array of possible tiles.
getMapHeightAndWidth(map: Array) -> Array: Returns the height and width of the map.
getHalfWayOfLength(width: int) -> int: Returns the halfway point of a given length.
getARandomPointInMap(map: Array) -> Vector2i: Returns a random point within the map boundaries.
printMap(map: Array) -> void: Prints the map to the Godot terminal with visual indicators for different tile types.

### Advanced Functions
countTiles(map: Array) -> Dictionary: Counts the occurrences of each tile type in the map.
getLeastCommonTile(map: Array) -> int: Gets the tile type with the least occurrences in the map.
getSections(map: Array) -> Array: Gets all sections in the map.
getSectionsOfACertainTile(tile_type: int, map: Array) -> Array: Gets all sections of a certain tile type.
getARandomSection(sections: Array, map: Array) -> Array: Gets a random section from the sections array.
getLargestSectionOfTileType(tile_type: int, map: Array) -> Array: Gets the largest section of a certain tile type.
findCenterTileGivenASection(section: Array) -> Vector2: Finds the center tile of a given section.
closestPointsBetweenSections(section1: Array, section2: Array) -> Array: Calculates the closest points between two sections.
calculateCentroid(section: Array) -> Vector2: Calculates the centroid of a section.
findMostDistantPoints(section: Array, numPoints: int) -> Array: Finds the most distant points in a section using Farthest Point Sampling.

## Contributing
If you'd like to contribute to this project, please fork the repository and submit a pull request. For major changes, please open an issue to discuss what you would like to change.

## License
This project is licensed under the MIT License.
