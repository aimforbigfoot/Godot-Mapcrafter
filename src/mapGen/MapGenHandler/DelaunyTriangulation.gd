extends Node

class Edge:
	var p1: Vector2
	var p2: Vector2
	
	func _init(p1: Vector2, p2: Vector2):
		self.p1 = p1
		self.p2 = p2

class Triangle:
	var p1: Vector2
	var p2: Vector2
	var p3: Vector2
	
	func _init(p1: Vector2, p2: Vector2, p3: Vector2):
		self.p1 = p1
		self.p2 = p2
		self.p3 = p3
	
	func contains_vertex(p: Vector2) -> bool:
		return p1 == p or p2 == p or p3 == p
	
	func circum_circle_contains(p: Vector2) -> bool:
		var ab = p1 - p
		var ac = p2 - p
		var ad = p3 - p
		
		var ab_length = ab.length_squared()
		var ac_length = ac.length_squared()
		var ad_length = ad.length_squared()
		
		var determinant = (ab.x * ac.y * ad_length) - (ab.x * ac_length * ad.y) - (ab_length * ac.y * ad.x) + (ab_length * ac_length * ad.y) + (ab.y * ac.x * ad.x) - (ab.y * ac_length * ad_length)
		return determinant > 0

class DelaunayTriangulation:
	var triangles: Array = []
	
	func triangulate(points: Array) -> Array:
		triangles.clear()
		
		var super_triangle = Triangle(Vector2(-1000, -1000), Vector2(1000, -1000), Vector2(0, 1000))
		triangles.append(super_triangle)
		
		for point in points:
			var edges = []
			for triangle in triangles:
				if triangle.circum_circle_contains(point):
					edges.append(Edge(triangle.p1, triangle.p2))
					edges.append(Edge(triangle.p2, triangle.p3))
					edges.append(Edge(triangle.p3, triangle.p1))
			
			triangles = triangles.filter(func(t: Triangle):
				for edge in edges:
					if t.contains_vertex(edge.p1) and t.contains_vertex(edge.p2):
						return false
				return true)
			
			for edge in edges:
				triangles.append(Triangle(edge.p1, edge.p2, point))
		
		triangles = triangles.filter(func(t: Triangle):
			return not super_triangle.contains_vertex(t.p1) and not super_triangle.contains_vertex(t.p2) and not super_triangle.contains_vertex(t.p3))
		
		return triangles
