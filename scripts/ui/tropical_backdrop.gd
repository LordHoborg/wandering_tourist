class_name TropicalBackdrop
extends RefCounted

## Shared procedural tropical scene: gradient sky, glowing sun, drifting
## clouds, animated sea waves, a distant island, and a sandy beach with palms.
## Pure static drawing helpers so the playfield and the title screen render
## the same world; reduced motion freezes every animated element.

static func draw(canvas: CanvasItem, area: Vector2, time: float, reduced_motion: bool) -> void:
	var t := 0.0 if reduced_motion else time
	var horizon := area.y * 0.46
	_sky(canvas, area, horizon)
	_sun(canvas, Vector2(area.x * 0.78, horizon * 0.60), t)
	_clouds(canvas, area, t)
	_sea(canvas, area, horizon, t)
	_island(canvas, area, horizon)
	_beach(canvas, area)
	_palm(canvas, Vector2(area.x * 0.085, area.y * 0.90), 1.0)
	_palm(canvas, Vector2(area.x * 0.925, area.y * 0.915), 0.85)

static func _sky(canvas: CanvasItem, area: Vector2, horizon: float) -> void:
	var top := Color(0.13, 0.38, 0.82)
	var bottom := Color(0.99, 0.83, 0.64)
	var bands := 26
	for band in bands:
		var f := float(band) / bands
		canvas.draw_rect(Rect2(0, f * horizon, area.x, horizon / bands + 1.5), top.lerp(bottom, pow(f, 1.35)))

static func _sun(canvas: CanvasItem, center: Vector2, t: float) -> void:
	var shimmer := 0.10 + 0.04 * sin(t * 0.9)
	canvas.draw_circle(center, 128, Color(1.0, 0.85, 0.55, shimmer * 0.6))
	canvas.draw_circle(center, 92, Color(1.0, 0.87, 0.60, shimmer))
	canvas.draw_circle(center, 58, Color("ffd97a"))
	canvas.draw_circle(center, 42, Color("fff3c4"))

static func _clouds(canvas: CanvasItem, area: Vector2, t: float) -> void:
	for index in 3:
		var speed := 9.0 + index * 5.0
		var x := fmod(area.x * (0.18 + 0.28 * index) + t * speed, area.x + 260.0) - 130.0
		var y := area.y * (0.09 + 0.065 * index)
		var tint := Color(1, 1, 1, 0.82 - index * 0.12)
		canvas.draw_circle(Vector2(x - 26, y + 6), 24, tint)
		canvas.draw_circle(Vector2(x + 4, y - 6), 32, tint)
		canvas.draw_circle(Vector2(x + 34, y + 8), 21, tint)
		canvas.draw_rect(Rect2(x - 30, y + 2, 76, 20), tint)

static func _sea(canvas: CanvasItem, area: Vector2, horizon: float, t: float) -> void:
	var near := Color(0.11, 0.63, 0.71)
	var deep := Color(0.03, 0.29, 0.45)
	var bands := 14
	for band in bands:
		var f := float(band) / bands
		canvas.draw_rect(Rect2(0, horizon + f * (area.y - horizon), area.x, (area.y - horizon) / bands + 1.5), near.lerp(deep, f))
	# Sun glint on the water.
	canvas.draw_rect(Rect2(area.x * 0.72, horizon, area.x * 0.12, 26), Color(1.0, 0.9, 0.7, 0.25))
	for wave in 4:
		var y := horizon + (wave + 1) * (area.y - horizon) * 0.145
		var amplitude := 4.0 + wave * 1.8
		var phase := t * (1.1 + wave * 0.35) + wave * 2.1
		var points := PackedVector2Array()
		for x in range(0, int(area.x) + 24, 24):
			points.append(Vector2(x, y + sin(x * 0.022 + phase) * amplitude))
		canvas.draw_polyline(points, Color(0.78, 0.96, 0.95, 0.16 + wave * 0.05), 2.5)

static func _island(canvas: CanvasItem, area: Vector2, horizon: float) -> void:
	var base := horizon + 6.0
	var island := PackedVector2Array([
		Vector2(-20, base), Vector2(area.x * 0.06, base - 52), Vector2(area.x * 0.16, base - 24),
		Vector2(area.x * 0.26, base - 64), Vector2(area.x * 0.38, base - 18), Vector2(area.x * 0.46, base),
	])
	canvas.draw_colored_polygon(island, Color(0.10, 0.36, 0.38))
	# Distant palms on the island silhouette.
	for spot in [Vector2(area.x * 0.10, base - 48), Vector2(area.x * 0.27, base - 60)]:
		canvas.draw_line(spot, spot + Vector2(5, -26), Color(0.08, 0.30, 0.31), 4.0)
		canvas.draw_circle(spot + Vector2(5, -28), 9, Color(0.08, 0.30, 0.31))

static func _beach(canvas: CanvasItem, area: Vector2) -> void:
	var top := area.y * 0.865
	var sand_top := Color(0.97, 0.86, 0.62)
	var sand_bottom := Color(0.85, 0.70, 0.45)
	var edge := PackedVector2Array([Vector2(0, top)])
	for x in range(0, int(area.x) + 40, 40):
		edge.append(Vector2(x, top + sin(x * 0.015) * 10.0))
	edge.append(Vector2(area.x, area.y))
	edge.append(Vector2(0, area.y))
	canvas.draw_colored_polygon(edge, sand_top)
	var bands := 8
	for band in bands:
		var f := float(band) / bands
		canvas.draw_rect(Rect2(0, top + 24 + f * (area.y - top), area.x, (area.y - top) / bands + 1.0), sand_top.lerp(sand_bottom, f))
	# Scattered shells and pebbles.
	for index in 9:
		var x := fmod(97.0 * index + 53.0, area.x - 60.0) + 30.0
		var y := top + 40.0 + fmod(61.0 * index, area.y - top - 80.0)
		canvas.draw_circle(Vector2(x, y), 3.0, Color(0.72, 0.58, 0.38, 0.8))

static func _palm(canvas: CanvasItem, base: Vector2, scale: float) -> void:
	var top := base + Vector2(-16.0, -108.0) * scale
	canvas.draw_polyline(_quad(base, base + Vector2(6.0, -58.0) * scale, top), Color(0.45, 0.30, 0.18), 9.0 * scale)
	for angle in [-2.65, -2.0, -1.35, -0.7, -0.1]:
		var direction := Vector2(cos(angle), sin(angle))
		var tip := top + direction * 52.0 * scale + Vector2(0, 16.0 * scale)
		canvas.draw_polyline(_quad(top, top + direction * 38.0 * scale, tip), Color(0.17, 0.50, 0.33), 6.5 * scale)
	canvas.draw_circle(top + Vector2(-6, 6) * scale, 5.5 * scale, Color(0.40, 0.26, 0.14))
	canvas.draw_circle(top + Vector2(7, 7) * scale, 5.5 * scale, Color(0.40, 0.26, 0.14))

static func _quad(p0: Vector2, p1: Vector2, p2: Vector2, segments: int = 7) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in segments + 1:
		var f := float(index) / segments
		points.append(p0.lerp(p1, f).lerp(p1.lerp(p2, f), f))
	return points
