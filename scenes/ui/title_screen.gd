class_name TitleScreen
extends Control

## Vertical-slice entry point: title art, best score, and the settings UI
## (mute, SFX volume, reduced motion) required by the GDD. Emits
## start_requested; gameplay_root owns the actual run start.

signal start_requested

const Backdrop = preload("res://scripts/ui/tropical_backdrop.gd")
const CoinWalletClass = preload("res://scripts/game/coin_wallet.gd")
const MiloTexture = preload("res://resources/art/milo_story.png")
const BACKDROP_FRAME_INTERVAL := 1.0 / 30.0

var best_score: int = 0
var _backdrop_elapsed := 0.0
var coin_wallet
var _shop_open := false
var _shop_index := 0
var _shop_controls: Array[Button] = []
var _shop_action_button: Button

@onready var _mute_button: Button = $Buttons/MuteButton
@onready var _volume_button: Button = $Buttons/VolumeButton
@onready var _motion_button: Button = $Buttons/MotionButton
@onready var _shop_button: Button = $Buttons/ShopButton

func _ready() -> void:
	$Buttons/StartButton.pressed.connect(func() -> void: start_requested.emit())
	_mute_button.pressed.connect(_on_mute_pressed)
	_volume_button.pressed.connect(_on_volume_pressed)
	_motion_button.pressed.connect(_on_motion_pressed)
	_shop_button.pressed.connect(_toggle_shop)
	_build_shop_controls()
	_refresh_settings_labels()

func _process(delta: float) -> void:
	if OS.has_feature("android"):
		return
	if AppSettings.reduced_motion:
		return
	_backdrop_elapsed += delta
	if _backdrop_elapsed >= BACKDROP_FRAME_INTERVAL:
		_backdrop_elapsed = fmod(_backdrop_elapsed, BACKDROP_FRAME_INTERVAL)
		queue_redraw()

func set_best_score(value: int) -> void:
	best_score = value
	queue_redraw()

func set_coin_wallet(wallet) -> void:
	coin_wallet = wallet
	_refresh_shop()
	queue_redraw()

func _draw() -> void:
	Backdrop.draw(self, size, Time.get_ticks_msec() / 1000.0, AppSettings.reduced_motion)
	if _shop_open:
		_draw_shop()
		return
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(92, 373), "WANDERING", HORIZONTAL_ALIGNMENT_CENTER, 540, 58, Color(0.10, 0.16, 0.30, 0.55))
	draw_string(font, Vector2(92, 443), "TOURIST", HORIZONTAL_ALIGNMENT_CENTER, 540, 58, Color(0.10, 0.16, 0.30, 0.55))
	draw_string(font, Vector2(90, 370), "WANDERING", HORIZONTAL_ALIGNMENT_CENTER, 540, 58, Color("fff0bd"))
	draw_string(font, Vector2(90, 440), "TOURIST", HORIZONTAL_ALIGNMENT_CENTER, 540, 58, Color("fff0bd"))
	draw_string(font, Vector2(90, 500), "Keep Hunger, Rest and Fun in the safe zone.", HORIZONTAL_ALIGNMENT_CENTER, 540, 18, Color(0.08, 0.20, 0.32))
	draw_string(font, Vector2(90, 640), "BEST SCORE  %d" % best_score, HORIZONTAL_ALIGNMENT_CENTER, 540, 22, Color("6b4a1f"))
	_draw_coin_badge(Vector2(290, 685), coin_wallet.balance if coin_wallet != null else 0, Color("6b4a1f"))

func _on_mute_pressed() -> void:
	AppSettings.set_muted(not AppSettings.muted)
	_refresh_settings_labels()

func _on_volume_pressed() -> void:
	var steps := [0.0, 0.25, 0.5, 0.75, 1.0]
	var index := 0
	var best_gap := INF
	for i in steps.size():
		var gap: float = absf(steps[i] - AppSettings.sfx_volume)
		if gap < best_gap:
			best_gap = gap
			index = i
	AppSettings.set_sfx_volume(steps[(index + 1) % steps.size()])
	_refresh_settings_labels()

func _on_motion_pressed() -> void:
	AppSettings.set_reduced_motion(not AppSettings.reduced_motion)
	_refresh_settings_labels()

func _refresh_settings_labels() -> void:
	_mute_button.text = "SOUND: OFF" if AppSettings.muted else "SOUND: ON"
	_volume_button.text = "VOLUME: %d%%" % int(round(AppSettings.sfx_volume * 100.0))
	_motion_button.text = "REDUCED MOTION: ON" if AppSettings.reduced_motion else "REDUCED MOTION: OFF"

func _build_shop_controls() -> void:
	var previous := _new_shop_control()
	previous.text = "‹"
	previous.position = Vector2(82, 850)
	previous.size = Vector2(100, 62)
	previous.pressed.connect(_previous_cosmetic)
	add_child(previous)
	_shop_controls.append(previous)
	_shop_action_button = _new_shop_control()
	_shop_action_button.position = Vector2(205, 850)
	_shop_action_button.size = Vector2(310, 62)
	_shop_action_button.pressed.connect(_purchase_or_equip)
	add_child(_shop_action_button)
	_shop_controls.append(_shop_action_button)
	var next := _new_shop_control()
	next.text = "›"
	next.position = Vector2(538, 850)
	next.size = Vector2(100, 62)
	next.pressed.connect(_next_cosmetic)
	add_child(next)
	_shop_controls.append(next)
	var close := _new_shop_control()
	close.text = "BACK"
	close.position = Vector2(260, 955)
	close.size = Vector2(200, 58)
	close.pressed.connect(_toggle_shop)
	add_child(close)
	_shop_controls.append(close)
	for control in _shop_controls:
		control.hide()

func _new_shop_control() -> Button:
	var button := Button.new()
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color("13213c"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("8ce4d8")
	normal.border_color = Color("fff0bd")
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(16)
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate()
	hover.bg_color = Color("b0f2e4")
	button.add_theme_stylebox_override("hover", hover)
	var disabled := normal.duplicate()
	disabled.bg_color = Color("516a72")
	button.add_theme_stylebox_override("disabled", disabled)
	return button

func _toggle_shop() -> void:
	_shop_open = not _shop_open
	$Buttons/StartButton.visible = not _shop_open
	_mute_button.visible = not _shop_open
	_volume_button.visible = not _shop_open
	_motion_button.visible = not _shop_open
	_shop_button.visible = not _shop_open
	for control in _shop_controls:
		control.visible = _shop_open
	_refresh_shop()
	queue_redraw()

func _previous_cosmetic() -> void:
	_shop_index = (_shop_index + CoinWalletClass.COSMETICS.size() - 1) % CoinWalletClass.COSMETICS.size()
	_refresh_shop()

func _next_cosmetic() -> void:
	_shop_index = (_shop_index + 1) % CoinWalletClass.COSMETICS.size()
	_refresh_shop()

func _purchase_or_equip() -> void:
	if coin_wallet == null:
		return
	var cosmetic: Dictionary = CoinWalletClass.COSMETICS[_shop_index]
	if coin_wallet.purchase_or_equip(cosmetic["id"]):
		_refresh_shop()

func _refresh_shop() -> void:
	if _shop_action_button == null or coin_wallet == null:
		return
	var cosmetic: Dictionary = CoinWalletClass.COSMETICS[_shop_index]
	var cosmetic_id: StringName = cosmetic["id"]
	if coin_wallet.equipped == cosmetic_id:
		_shop_action_button.text = "EQUIPPED"
		_shop_action_button.disabled = true
	elif coin_wallet.owns(cosmetic_id):
		_shop_action_button.text = "EQUIP"
		_shop_action_button.disabled = false
	else:
		var cost := int(cosmetic["cost"])
		_shop_action_button.text = "BUY  %d COINS" % cost if coin_wallet.balance >= cost else "NEED  %d MORE" % (cost - coin_wallet.balance)
		_shop_action_button.disabled = coin_wallet.balance < cost
	queue_redraw()

func _draw_shop() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.03, 0.08, 0.66))
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color("10233d")
	panel.border_color = Color("f6c85f")
	panel.set_border_width_all(3)
	panel.set_corner_radius_all(30)
	panel.shadow_color = Color(0, 0, 0, 0.45)
	panel.shadow_size = 10
	draw_style_box(panel, Rect2(42, 118, 636, 930))
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(80, 180), "MILO'S COIN CLOSET", HORIZONTAL_ALIGNMENT_CENTER, 560, 32, Color("fff0bd"))
	_draw_coin_badge(Vector2(290, 220), coin_wallet.balance if coin_wallet != null else 0, Color("ffe08a"))
	var preview := Rect2(242, 245, 236, 354)
	if coin_wallet != null and coin_wallet.equipped == &"postcard_aura":
		for radius in [145.0, 126.0, 108.0]:
			draw_arc(preview.get_center(), radius, 0, TAU, 48, Color(0.55, 0.90, 0.84, 0.10 + (145.0 - radius) * 0.004), 5.0)
	draw_texture_rect(MiloTexture, preview, false)
	var cosmetic: Dictionary = CoinWalletClass.COSMETICS[_shop_index]
	_draw_cosmetic_preview(preview, cosmetic["id"])
	draw_string(font, Vector2(90, 660), cosmetic["name"], HORIZONTAL_ALIGNMENT_CENTER, 540, 27, Color("fff0bd"))
	draw_multiline_string(font, Vector2(110, 702), cosmetic["tagline"], HORIZONTAL_ALIGNMENT_CENTER, 500, 17, 2, Color("a8e5dc"))
	var status := "OWNED" if coin_wallet != null and coin_wallet.owns(cosmetic["id"]) else "%d COINS" % int(cosmetic["cost"])
	draw_string(font, Vector2(110, 775), status, HORIZONTAL_ALIGNMENT_CENTER, 500, 20, Color("f6c85f"))

func _draw_coin_badge(position: Vector2, amount: int, color: Color) -> void:
	draw_circle(position, 15, Color("f6c85f"))
	draw_circle(position, 10, Color("fff0bd"))
	draw_string(ThemeDB.fallback_font, position + Vector2(24, 7), "COINS  %d" % amount, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, color)

func _draw_cosmetic_preview(preview: Rect2, cosmetic_id: StringName) -> void:
	var face := preview.position + Vector2(preview.size.x * 0.56, preview.size.y * 0.24)
	if cosmetic_id == &"neon_shades":
		draw_rect(Rect2(face + Vector2(-37, -4), Vector2(30, 15)), Color("20153b"))
		draw_rect(Rect2(face + Vector2(5, -4), Vector2(30, 15)), Color("20153b"))
		draw_line(face + Vector2(-7, 2), face + Vector2(5, 2), Color("f49ad6"), 4)
		draw_line(face + Vector2(-35, -2), face + Vector2(-10, 8), Color("65e7e1"), 3)
		draw_line(face + Vector2(7, -2), face + Vector2(32, 8), Color("65e7e1"), 3)
	elif cosmetic_id == &"scarlet_scarf":
		var neck := preview.position + Vector2(preview.size.x * 0.55, preview.size.y * 0.39)
		draw_arc(neck, 38, 0.10, PI - 0.10, 24, Color("df4b5f"), 12)
		draw_colored_polygon(PackedVector2Array([neck + Vector2(19, 15), neck + Vector2(53, 75), neck + Vector2(29, 66)]), Color("c73b52"))
	elif cosmetic_id == &"postcard_aura":
		for index in 6:
			var angle := index * TAU / 6.0
			var center := preview.get_center() + Vector2(cos(angle), sin(angle)) * 142.0
			draw_circle(center, 6, Color("ffe08a"))
