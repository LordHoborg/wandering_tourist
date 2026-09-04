class_name TropicalBackdrop
extends RefCounted

## Shared procedural tropical scene: gradient sky, glowing sun, drifting
## clouds, animated sea waves, a distant island, and a sandy beach with palms.
## Pure static drawing helpers so the playfield and the title screen render
## the same world; reduced motion freezes every animated element.

static func draw(canvas: CanvasItem, area: Vector2, time: float, reduced_motion: bool, theme_id: StringName = &"tropical") -> void:
	if OS.has_feature("android"):
		_draw_mobile(canvas, area, theme_id)
		return
	var time_value := 0.0 if reduced_motion else time
	var horizon := area.y * (0.50 if theme_id == &"sunset_city" else 0.46)
	var palette := _palette(theme_id)
	_sky(canvas, area, horizon, palette, theme_id, time_value)
	_sun(canvas, area, horizon, time_value, palette, theme_id)
	_clouds(canvas, area, time_value, palette, theme_id)
	_sea(canvas, area, horizon, time_value, palette, theme_id)
	if theme_id == &"sunset_city":
		_city(canvas, area, horizon, palette, time_value)
	elif theme_id == &"countryside":
		_countryside(canvas, area, horizon, palette, time_value)
	elif theme_id == &"ancient_ruins":
		_ruins(canvas, area, horizon, palette)
	elif theme_id == &"crystal_isles":
		_crystal_isles(canvas, area, horizon, palette)
	else:
		_island(canvas, area, horizon)
		_beach(canvas, area)
		_palm(canvas, Vector2(area.x * 0.085, area.y * 0.90), 1.0)
		_palm(canvas, Vector2(area.x * 0.925, area.y * 0.915), 0.85)
		_tropical_details(canvas, area, horizon, time_value)
	_foreground_atmosphere(canvas, area, theme_id)

static func _draw_mobile(canvas: CanvasItem, area: Vector2, theme_id: StringName) -> void:
	var palette := _palette(theme_id)
	var horizon := area.y * (0.50 if theme_id == &"sunset_city" else 0.46)
	var bands := 10
	for band in bands:
		var fraction := float(band) / bands
		canvas.draw_rect(Rect2(0, fraction * horizon, area.x, horizon / bands + 2.0), palette["sky_top"].lerp(palette["sky_bottom"], fraction))
	canvas.draw_circle(Vector2(area.x * 0.78, horizon * 0.60), 58, palette["sun"])
	canvas.draw_circle(Vector2(area.x * 0.78, horizon * 0.60), 38, palette["sun_core"])
	for band in 8:
		var fraction := float(band) / 8.0
		canvas.draw_rect(Rect2(0, horizon + fraction * (area.y - horizon), area.x, (area.y - horizon) / 8.0 + 2.0), palette["sea_near"].lerp(palette["sea_deep"], fraction))
	if theme_id == &"sunset_city":
		var base := horizon + 20.0
		for index in 8:
			var width := 70.0 + float(index % 3) * 24.0
			var height := 110.0 + float((index * 37) % 150)
			var x := float(index) * area.x / 7.0 - 30.0
			canvas.draw_rect(Rect2(x, base - height, width, height), palette["city_shadow"])
			canvas.draw_rect(Rect2(x + 12, base - height + 22, 8, 10), palette["neon"])
		canvas.draw_rect(Rect2(0, base, area.x, area.y - base), palette["street"])
	elif theme_id == &"countryside":
		var base := horizon + 18.0
		canvas.draw_colored_polygon(PackedVector2Array([
			Vector2(0, base + 26), Vector2(area.x * 0.25, base - 70), Vector2(area.x * 0.50, base + 18),
			Vector2(area.x * 0.76, base - 76), Vector2(area.x, base + 20), Vector2(area.x, area.y), Vector2(0, area.y)
		]), palette["hill_near"])
		for row in 4:
			canvas.draw_line(Vector2(0, base + 90 + row * 36), Vector2(area.x, base + 42 + row * 36), Color(palette["field"], 0.65), 4.0)
		canvas.draw_rect(Rect2(area.x * 0.68, base - 120, 42, 120), palette["barn"])
		canvas.draw_colored_polygon(PackedVector2Array([
			Vector2(area.x * 0.65, base - 120), Vector2(area.x * 0.71, base - 152), Vector2(area.x * 0.78, base - 120)
		]), palette["roof"])
	else:
		var base := horizon + 6.0
		canvas.draw_colored_polygon(PackedVector2Array([
			Vector2(-20, base), Vector2(area.x * 0.08, base - 50), Vector2(area.x * 0.25, base - 25),
			Vector2(area.x * 0.40, base - 58), Vector2(area.x * 0.55, base), Vector2(-20, base)
		]), Color("0d5660"))
		canvas.draw_colored_polygon(PackedVector2Array([
			Vector2(0, area.y * 0.86), Vector2(area.x, area.y * 0.86), Vector2(area.x, area.y), Vector2(0, area.y)
		]), Color("e8bd70"))

static func _sky(canvas: CanvasItem, area: Vector2, horizon: float, palette: Dictionary, theme_id: StringName, time_value: float) -> void:
	var top: Color = palette["sky_top"]
	var bottom: Color = palette["sky_bottom"]
	var bands := 40
	for band in bands:
		var fraction := float(band) / bands
		canvas.draw_rect(Rect2(0, fraction * horizon, area.x, horizon / bands + 1.5), top.lerp(bottom, pow(fraction, 1.28)))
	canvas.draw_rect(Rect2(0, horizon - 64, area.x, 80), Color(palette["horizon_glow"], 0.18))
	if theme_id == &"sunset_city" or theme_id == &"crystal_isles":
		for star_index in 22:
			var star_x := fmod(float(star_index * 113 + 37), area.x)
			var star_y := 30.0 + fmod(float(star_index * 61), horizon * 0.55)
			var twinkle := 0.42 + 0.28 * sin(time_value * 1.6 + star_index)
			canvas.draw_circle(Vector2(star_x, star_y), 1.2 + float(star_index % 3) * 0.5, Color(1, 0.94, 0.76, twinkle))
	if theme_id == &"countryside":
		for ray_index in 5:
			var ray_x := area.x * 0.72 + ray_index * 34.0
			canvas.draw_colored_polygon(PackedVector2Array([
				Vector2(ray_x, 120), Vector2(ray_x + 22, 120), Vector2(ray_x - 150, horizon), Vector2(ray_x - 205, horizon)
			]), Color(1.0, 0.92, 0.66, 0.035))

static func _sun(canvas: CanvasItem, area: Vector2, horizon: float, time_value: float, palette: Dictionary, theme_id: StringName) -> void:
	var center := Vector2(area.x * (0.76 if theme_id != &"sunset_city" else 0.82), horizon * (0.58 if theme_id != &"sunset_city" else 0.68))
	var shimmer := 0.10 + 0.04 * sin(time_value * 0.9)
	canvas.draw_circle(center, 128, Color(palette["sun"], shimmer * 0.6))
	canvas.draw_circle(center, 92, Color(palette["sun"], shimmer))
	canvas.draw_circle(center, 58, palette["sun"])
	canvas.draw_circle(center, 42, palette["sun_core"])
	for ray_index in 12:
		var angle := float(ray_index) * TAU / 12.0 + time_value * 0.015
		var ray_start := center + Vector2(cos(angle), sin(angle)) * 68.0
		var ray_end := center + Vector2(cos(angle), sin(angle)) * (78.0 + float(ray_index % 3) * 8.0)
		canvas.draw_line(ray_start, ray_end, Color(palette["sun_core"], 0.20), 2.0)

static func _clouds(canvas: CanvasItem, area: Vector2, time_value: float, palette: Dictionary, theme_id: StringName) -> void:
	var cloud_count := 5 if theme_id == &"countryside" else 4
	var cloud_color: Color = palette["cloud"]
	for index in cloud_count:
		var speed := 9.0 + index * 5.0
		var cloud_x := fmod(area.x * (0.12 + 0.23 * index) + time_value * speed, area.x + 280.0) - 140.0
		var cloud_y := area.y * (0.075 + 0.052 * index)
		var cloud_scale := 0.72 + float(index % 3) * 0.18
		var tint := Color(cloud_color, 0.72 - index * 0.07)
		canvas.draw_circle(Vector2(cloud_x - 28 * cloud_scale, cloud_y + 6), 24 * cloud_scale, Color(0.02, 0.05, 0.12, 0.10))
		canvas.draw_circle(Vector2(cloud_x + 4, cloud_y - 8), 32 * cloud_scale, tint)
		canvas.draw_circle(Vector2(cloud_x - 27 * cloud_scale, cloud_y + 5), 23 * cloud_scale, tint)
		canvas.draw_circle(Vector2(cloud_x + 34 * cloud_scale, cloud_y + 8), 21 * cloud_scale, tint)
		canvas.draw_rect(Rect2(cloud_x - 31 * cloud_scale, cloud_y + 1, 78 * cloud_scale, 20 * cloud_scale), tint)
		canvas.draw_line(Vector2(cloud_x - 24 * cloud_scale, cloud_y + 18 * cloud_scale), Vector2(cloud_x + 39 * cloud_scale, cloud_y + 18 * cloud_scale), Color(palette["cloud_shadow"], 0.22), 2.0)

static func _sea(canvas: CanvasItem, area: Vector2, horizon: float, time_value: float, palette: Dictionary, theme_id: StringName) -> void:
	var near: Color = palette["sea_near"]
	var deep: Color = palette["sea_deep"]
	var bands := 18
	for band in bands:
		var fraction := float(band) / bands
		canvas.draw_rect(Rect2(0, horizon + fraction * (area.y - horizon), area.x, (area.y - horizon) / bands + 1.5), near.lerp(deep, fraction))
	for glint_index in 8:
		var glint_y := horizon + glint_index * 16.0
		var glint_width := 88.0 - glint_index * 7.0
		canvas.draw_line(Vector2(area.x * 0.76 - glint_width * 0.5, glint_y), Vector2(area.x * 0.76 + glint_width * 0.5, glint_y), Color(palette["reflection"], 0.24 - glint_index * 0.018), 3.0)
	for wave in 6:
		var wave_y := horizon + (wave + 1) * (area.y - horizon) * 0.105
		var amplitude := 3.0 + wave * 1.4
		var phase := time_value * (1.05 + wave * 0.30) + wave * 2.1
		var points := PackedVector2Array()
		for wave_x in range(0, int(area.x) + 20, 20):
			points.append(Vector2(wave_x, wave_y + sin(wave_x * 0.024 + phase) * amplitude))
		canvas.draw_polyline(points, Color(palette["foam"], 0.12 + wave * 0.035), 2.2)
	if theme_id == &"sunset_city":
		for reflection_index in 12:
			var reflection_x := 26.0 + reflection_index * 61.0
			var reflection_height := 90.0 + float((reflection_index * 29) % 140)
			canvas.draw_rect(Rect2(reflection_x, horizon + 18, 7, reflection_height), Color(palette["window"], 0.09 + float(reflection_index % 3) * 0.04))

static func _city(canvas: CanvasItem, area: Vector2, horizon: float, palette: Dictionary, time_value: float) -> void:
	var base := horizon + 18.0
	for back_index in 13:
		var back_width := 46.0 + float((back_index * 19) % 34)
		var back_height := 70.0 + float((back_index * 37) % 120)
		var back_x := float(back_index) * area.x / 12.0 - 24.0
		canvas.draw_rect(Rect2(back_x, base - back_height, back_width, back_height), Color(palette["city_far"], 0.92))
	for building_index in 10:
		var width := 52.0 + float((building_index * 23) % 42)
		var height := 110.0 + float((building_index * 47) % 190)
		var building_x := float(building_index) * area.x / 9.0 - 32.0
		canvas.draw_rect(Rect2(building_x, base - height, width, height), palette["city_shadow"])
		canvas.draw_rect(Rect2(building_x + 6, base - height + 8, width - 12, 5), Color(palette["neon"], 0.24))
		for row in range(2, int(height / 25.0)):
			for column in range(1, int(width / 18.0)):
				if (row + column + building_index) % 3 != 0:
					var window_color: Color = palette["window"] if (row + building_index) % 2 == 0 else palette["neon"]
					canvas.draw_rect(Rect2(building_x + column * 17.0, base - row * 24.0, 7, 10), Color(window_color, 0.72))
		if building_index in [2, 6, 8]:
			var sign_color: Color = palette["neon"] if building_index % 2 == 0 else palette["window"]
			canvas.draw_rect(Rect2(building_x + 9, base - height * 0.56, width - 18, 18), Color(sign_color, 0.20))
			canvas.draw_rect(Rect2(building_x + 13, base - height * 0.56 + 5, width - 26, 3), Color(sign_color, 0.85))
	var tower_x := area.x * 0.17
	canvas.draw_rect(Rect2(tower_x, base - 250, 34, 250), Color("191b43"))
	canvas.draw_line(Vector2(tower_x + 17, base - 250), Vector2(tower_x + 17, base - 302), Color(palette["neon"], 0.75), 3.0)
	canvas.draw_circle(Vector2(tower_x + 17, base - 306), 5.0 + sin(time_value * 3.0) * 1.5, palette["neon"])
	canvas.draw_rect(Rect2(0, base, area.x, area.y - base), Color(palette["street"], 0.78))
	for road_index in 6:
		var road_x := road_index * area.x / 5.0
		canvas.draw_line(Vector2(road_x, base + 18), Vector2(road_x + 105, area.y), Color(palette["neon"], 0.10), 3.0)

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

static func _countryside(canvas: CanvasItem, area: Vector2, horizon: float, palette: Dictionary, time_value: float) -> void:
	var base := horizon + 18.0
	canvas.draw_colored_polygon(PackedVector2Array([
		Vector2(0, base + 20), Vector2(area.x * 0.20, base - 82), Vector2(area.x * 0.42, base + 8),
		Vector2(area.x * 0.64, base - 102), Vector2(area.x, base + 14), Vector2(area.x, area.y), Vector2(0, area.y)
	]), palette["hill_far"])
	canvas.draw_colored_polygon(PackedVector2Array([
		Vector2(0, base + 70), Vector2(area.x * 0.28, base - 6), Vector2(area.x * 0.55, base + 54),
		Vector2(area.x * 0.78, base - 18), Vector2(area.x, base + 44), Vector2(area.x, area.y), Vector2(0, area.y)
	]), palette["hill_near"])
	for row in 5:
		var field_y := base + 76.0 + row * 34.0
		canvas.draw_line(Vector2(0, field_y), Vector2(area.x, field_y - 42), Color(palette["field"], 0.48), 4.0)
		for crop_index in 12:
			var crop_x := crop_index * 72.0 + row * 13.0
			canvas.draw_line(Vector2(crop_x, field_y + 7), Vector2(crop_x + 5, field_y - 8), Color(palette["crop"], 0.65), 2.0)
	var tower := Rect2(area.x * 0.68, base - 152, 42, 152)
	canvas.draw_rect(tower, palette["barn"])
	canvas.draw_colored_polygon(PackedVector2Array([
		Vector2(tower.position.x - 12, tower.position.y), Vector2(tower.position.x + 21, tower.position.y - 34),
		Vector2(tower.end.x + 12, tower.position.y)
	]), palette["roof"])
	canvas.draw_rect(Rect2(tower.position + Vector2(12, 28), Vector2(18, 24)), palette["window"])
	var windmill_center := Vector2(area.x * 0.28, base - 104)
	canvas.draw_line(windmill_center, Vector2(windmill_center.x, base + 20), palette["wood"], 10.0)
	canvas.draw_circle(windmill_center, 12, palette["roof"])
	for blade_index in 4:
		var blade_angle := time_value * 0.12 + blade_index * PI * 0.5
		var blade_end := windmill_center + Vector2(cos(blade_angle), sin(blade_angle)) * 62.0
		canvas.draw_line(windmill_center, blade_end, palette["wood"], 7.0)
		canvas.draw_line(blade_end, blade_end + Vector2(-sin(blade_angle), cos(blade_angle)) * 16.0, Color(palette["fence"], 0.85), 5.0)
	for index in 6:
		var fence_x := 36.0 + index * 104.0
		canvas.draw_line(Vector2(fence_x, base + 34), Vector2(fence_x + 18, base - 8), palette["fence"], 3.0)
		canvas.draw_line(Vector2(fence_x + 18, base - 8), Vector2(fence_x + 37, base + 34), palette["fence"], 3.0)
	for tree_index in 8:
		var tree_x := 24.0 + tree_index * 98.0
		var tree_y := base + 18.0 + float(tree_index % 2) * 35.0
		canvas.draw_line(Vector2(tree_x, tree_y), Vector2(tree_x, tree_y - 38), palette["wood"], 5.0)
		canvas.draw_circle(Vector2(tree_x, tree_y - 50), 21, Color(palette["tree"], 0.86))

static func _crystal_isles(canvas: CanvasItem, area: Vector2, horizon: float, palette: Dictionary) -> void:
	var base := horizon + 10.0
	var ground := PackedVector2Array([Vector2(0, base + 58), Vector2(area.x * 0.18, base - 4), Vector2(area.x * 0.39, base + 28), Vector2(area.x * 0.58, base - 24), Vector2(area.x * 0.83, base + 18), Vector2(area.x, base - 6), Vector2(area.x, area.y), Vector2(0, area.y)])
	canvas.draw_colored_polygon(ground, palette["crystal_ground"])
	for index in 8:
		var x := 30.0 + index * 94.0
		var height := 42.0 + float((index * 19) % 48)
		var crystal := PackedVector2Array([Vector2(x, base + 24), Vector2(x + 18, base - height), Vector2(x + 36, base + 24)])
		canvas.draw_colored_polygon(crystal, palette["crystal"])
		canvas.draw_line(Vector2(x + 18, base - height), Vector2(x + 25, base + 20), Color(1, 1, 1, 0.35), 2.0)
	for index in 5:
		var x := area.x * 0.12 + index * area.x * 0.19
		canvas.draw_circle(Vector2(x, base - 82 - (index % 2) * 22), 7, Color(palette["glow"], 0.65))

static func _palette(theme_id: StringName) -> Dictionary:
	if theme_id == &"sunset_city":
		return {"sky_top": Color("17163f"), "sky_bottom": Color("d95c78"), "horizon_glow": Color("ffb06b"), "sun": Color("ff9270"), "sun_core": Color("ffd6a0"), "cloud": Color("73537f"), "cloud_shadow": Color("241c4d"), "sea_near": Color("514f91"), "sea_deep": Color("111433"), "foam": Color("b8a7ff"), "reflection": Color("ffd49b"), "city_far": Color("30285c"), "city_shadow": Color("151735"), "window": Color("ffd878"), "neon": Color("65e7e1"), "street": Color("17182e")}
	if theme_id == &"ancient_ruins":
		return {"sky_top": Color("243b73"), "sky_bottom": Color("d88f74"), "horizon_glow": Color("f6bd73"), "sun": Color("f6bd73"), "sun_core": Color("ffe8ac"), "cloud": Color("d7b4a3"), "cloud_shadow": Color("5c4a68"), "sea_near": Color("586a93"), "sea_deep": Color("1c294e"), "foam": Color("d9d1c8"), "reflection": Color("f6bd73"), "ruin": Color("73545a"), "stone_light": Color("b48a6c"), "stone_shadow": Color("513e4c"), "sand": Color("9d7559"), "relic": Color("f2c06c")}
	if theme_id == &"countryside":
		return {"sky_top": Color("2b7891"), "sky_bottom": Color("f7db94"), "horizon_glow": Color("fff0b0"), "sun": Color("ffe28b"), "sun_core": Color("fff8d2"), "cloud": Color("fff4d6"), "cloud_shadow": Color("9db5a8"), "sea_near": Color("5fb5a4"), "sea_deep": Color("245d63"), "foam": Color("d7f6dc"), "reflection": Color("fff0b0"), "hill_far": Color("75a77b"), "hill_near": Color("3f755c"), "field": Color("d4df86"), "crop": Color("eef0a4"), "barn": Color("b65d4d"), "roof": Color("713e49"), "window": Color("ffe08a"), "fence": Color("e0c28a"), "wood": Color("78513d"), "tree": Color("3f8558")}
	if theme_id == &"crystal_isles":
		return {"sky_top": Color("292c72"), "sky_bottom": Color("b5a4ed"), "horizon_glow": Color("e7d5ff"), "sun": Color("e7d5ff"), "sun_core": Color("fff5ff"), "cloud": Color("d7d0ff"), "cloud_shadow": Color("766fb6"), "sea_near": Color("4b91c4"), "sea_deep": Color("17295c"), "foam": Color("b9f5ff"), "reflection": Color("f5b6ff"), "crystal_ground": Color("3c4d91"), "crystal": Color("78d7e8"), "glow": Color("f5b6ff")}
	return {"sky_top": Color("07558c"), "sky_bottom": Color("f8c777"), "horizon_glow": Color("fff0b0"), "sun": Color("ffd56b"), "sun_core": Color("fff6ca"), "cloud": Color("fff5dc"), "cloud_shadow": Color("72a6b1"), "sea_near": Color("1bb2c2"), "sea_deep": Color("064a70"), "foam": Color("ccffff"), "reflection": Color("fff0b0")}

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

static func _tropical_details(canvas: CanvasItem, area: Vector2, horizon: float, time_value: float) -> void:
	var hut_base := Vector2(area.x * 0.23, horizon - 8)
	canvas.draw_rect(Rect2(hut_base - Vector2(32, 30), Vector2(64, 30)), Color("8f5b3f"))
	canvas.draw_colored_polygon(PackedVector2Array([
		hut_base + Vector2(-42, -30), hut_base + Vector2(0, -62), hut_base + Vector2(42, -30)
	]), Color("d9a55f"))
	canvas.draw_rect(Rect2(hut_base + Vector2(-8, -20), Vector2(16, 20)), Color("3e3b3b"))
	for bird_index in 3:
		var bird_center := Vector2(area.x * (0.36 + bird_index * 0.08), horizon * (0.28 + bird_index * 0.05))
		var wing := 7.0 + sin(time_value * 2.0 + bird_index) * 2.0
		canvas.draw_arc(bird_center + Vector2(-wing, 0), wing, PI * 0.08, PI * 0.86, 8, Color(0.05, 0.20, 0.30, 0.72), 2.0)
		canvas.draw_arc(bird_center + Vector2(wing, 0), wing, PI * 0.14, PI * 0.92, 8, Color(0.05, 0.20, 0.30, 0.72), 2.0)
	for foam_index in 4:
		var foam_y := area.y * 0.85 + foam_index * 10.0
		canvas.draw_line(Vector2(0, foam_y), Vector2(area.x, foam_y + sin(time_value + foam_index) * 4.0), Color(1, 1, 1, 0.12), 2.0)

static func _foreground_atmosphere(canvas: CanvasItem, area: Vector2, theme_id: StringName) -> void:
	var foreground_tint := Color("09172b")
	if theme_id == &"sunset_city":
		foreground_tint = Color("120f28")
	elif theme_id == &"countryside":
		foreground_tint = Color("183c35")
	canvas.draw_rect(Rect2(0, 0, area.x, 22), Color(foreground_tint, 0.22))
	canvas.draw_rect(Rect2(0, area.y - 42, area.x, 42), Color(foreground_tint, 0.16))

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
