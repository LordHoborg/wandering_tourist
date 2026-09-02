class_name TropicalBackdrop
extends RefCounted

## Shared procedural tropical scene: gradient sky, glowing sun, drifting
## clouds, animated sea waves, a distant island, and a sandy beach with palms.
## Pure static drawing helpers so the playfield and the title screen render
## the same world; reduced motion freezes every animated element.

static func draw(canvas: CanvasItem, area: Vector2, time: float, reduced_motion: bool, theme_id: StringName = &"tropical") -> void:
	var t := 0.0 if reduced_motion else time
	var horizon := area.y * 0.46
	var palette := _palette(theme_id)
	_sky(canvas, area, horizon, palette)
	_sun(canvas, Vector2(area.x * 0.78, horizon * 0.60), t, palette)
	_clouds(canvas, area, t)
	_sea(canvas, area, horizon, t, palette)
	if theme_id == &"sunset_city":
		_city(canvas, area, horizon, palette)
	elif theme_id == &"ancient_ruins":
		_ruins(canvas, area, horizon, palette)
	else:
		_island(canvas, area, horizon)
		_beach(canvas, area)
		_palm(canvas, Vector2(area.x * 0.085, area.y * 0.90), 1.0)
		_palm(canvas, Vector2(area.x * 0.925, area.y * 0.915), 0.85)

static func _sky(canvas: CanvasItem, area: Vector2, horizon: float, palette: Dictionary) -> void:
	var top: Color = palette["sky_top"]
	var bottom: Color = palette["sky_bottom"]
	var bands := 26
	for band in bands:
		var f := float(band) / bands
		canvas.draw_rect(Rect2(0, f * horizon, area.x, horizon / bands + 1.5), top.lerp(bottom, pow(f, 1.35)))

static func _sun(canvas: CanvasItem, center: Vector2, t: float, palette: Dictionary) -> void:
	var shimmer := 0.10 + 0.04 * sin(t * 0.9)
	canvas.draw_circle(center, 128, Color(palette["sun"], shimmer * 0.6))
	canvas.draw_circle(center, 92, Color(palette["sun"], shimmer))
	canvas.draw_circle(center, 58, palette["sun"])
	canvas.draw_circle(center, 42, palette["sun_core"])

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

static func _sea(canvas: CanvasItem, area: Vector2, horizon: float, t: float, palette: Dictionary) -> void:
	var near: Color = palette["sea_near"]
	var deep: Color = palette["sea_deep"]
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

static func _city(canvas: CanvasItem, area: Vector2, horizon: float, palette: Dictionary) -> void:
	var base := horizon + 18.0
	for index in 9:
		var width := 44.0 + float((index * 17) % 35)
		var height := 75.0 + float((index * 41) % 140)
		var x := float(index) * area.x / 8.0 - 26.0
		canvas.draw_rect(Rect2(x, base - height, width, height), palette["city_shadow"])
		for row in range(3, int(height / 24.0)):
			for column in range(1, int(width / 19.0)):
				if (row + column + index) % 3 != 0:
					canvas.draw_rect(Rect2(x + column * 18.0, base - row * 24.0, 7, 9), Color(palette["window"], 0.72))
	canvas.draw_rect(Rect2(0, base, area.x, area.y - base), palette["street"])
	for lane in 5:
		canvas.draw_line(Vector2(lane * area.x / 4.0, base + 30), Vector2(lane * area.x / 4.0 + 80, area.y), Color(1, 0.78, 0.42, 0.18), 3.0)

static func _ruins(canvas: CanvasItem, area: Vector2, horizon: float, palette: Dictionary) -> void:
	var base := horizon + 10.0
	var temple := PackedVector2Array([Vector2(area.x * 0.26, base), Vector2(area.x * 0.33, base - 130), Vector2(area.x * 0.67, base - 130), Vector2(area.x * 0.74, base)])
	canvas.draw_colored_polygon(temple, palette["ruin"])
	canvas.draw_rect(Rect2(area.x * 0.30, base - 116, area.x * 0.40, 18), palette["stone_light"])
	for column in 4:
		var x := area.x * 0.33 + column * area.x * 0.11
		canvas.draw_rect(Rect2(x, base - 105, 24, 105), palette["stone_light"])
		canvas.draw_line(Vector2(x + 6, base - 92), Vector2(x + 6, base - 10), palette["stone_shadow"], 3.0)
	canvas.draw_colored_polygon(PackedVector2Array([Vector2(0, base), Vector2(area.x * 0.18, base - 58), Vector2(area.x * 0.34, base), Vector2(area.x * 0.48, base - 36), Vector2(area.x * 0.65, base), Vector2(area.x * 0.84, base - 48), Vector2(area.x, base)]), palette["sand"])
	for index in 7:
		var x := 40.0 + index * 104.0
		canvas.draw_circle(Vector2(x, base + 34.0 + (index % 2) * 26.0), 5.0, palette["relic"])

static func _palette(theme_id: StringName) -> Dictionary:
	if theme_id == &"sunset_city":
		return {"sky_top": Color("3c286e"), "sky_bottom": Color("f29b72"), "sun": Color("ffd17b"), "sun_core": Color("fff0b0"), "sea_near": Color("5e5ca7"), "sea_deep": Color("171c4d"), "city_shadow": Color("20214b"), "window": Color("ffd878"), "street": Color("252448")}
	if theme_id == &"ancient_ruins":
		return {"sky_top": Color("243b73"), "sky_bottom": Color("d88f74"), "sun": Color("f6bd73"), "sun_core": Color("ffe8ac"), "sea_near": Color("586a93"), "sea_deep": Color("1c294e"), "ruin": Color("73545a"), "stone_light": Color("b48a6c"), "stone_shadow": Color("513e4c"), "sand": Color("9d7559"), "relic": Color("f2c06c")}
	return {"sky_top": Color("0d3f78"), "sky_bottom": Color("f7c87b"), "sun": Color("ffd97a"), "sun_core": Color("fff3c4"), "sea_near": Color("1c9fb5"), "sea_deep": Color("07456a")}

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
