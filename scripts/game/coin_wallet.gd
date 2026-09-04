class_name CoinWallet
extends RefCounted

const DEFAULT_PATH := "user://coin_wallet.cfg"
const COSMETICS: Array[Dictionary] = [
	{"id": &"classic", "name": "CLASSIC MILO", "cost": 0, "tagline": "The original lost-tourist look."},
	{"id": &"neon_shades", "name": "NEON SHADES", "cost": 180, "tagline": "For pretending the map is obvious."},
	{"id": &"scarlet_scarf", "name": "SCARLET SCARF", "cost": 320, "tagline": "Dramatic in every climate."},
	{"id": &"postcard_aura", "name": "POSTCARD AURA", "cost": 520, "tagline": "Proof that Milo survived the itinerary."},
]

var storage_path: String
var balance: int = 0
var lifetime_earned: int = 0
var lifetime_spent: int = 0
var owned: Dictionary[StringName, bool] = {&"classic": true}
var equipped: StringName = &"classic"

func _init(path: String = DEFAULT_PATH) -> void:
	storage_path = path
	load_wallet()

func earn(amount: int) -> int:
	var awarded := maxi(0, amount)
	if awarded == 0:
		return 0
	balance += awarded
	lifetime_earned += awarded
	_save()
	return awarded

func owns(cosmetic_id: StringName) -> bool:
	return owned.get(cosmetic_id, false)

func purchase_or_equip(cosmetic_id: StringName) -> bool:
	var cosmetic := cosmetic_for(cosmetic_id)
	if cosmetic.is_empty():
		return false
	if owns(cosmetic_id):
		equipped = cosmetic_id
		_save()
		return true
	var cost := int(cosmetic["cost"])
	if balance < cost:
		return false
	balance -= cost
	lifetime_spent += cost
	owned[cosmetic_id] = true
	equipped = cosmetic_id
	_save()
	return true

func cosmetic_for(cosmetic_id: StringName) -> Dictionary:
	for cosmetic: Dictionary in COSMETICS:
		if cosmetic["id"] == cosmetic_id:
			return cosmetic
	return {}

func load_wallet() -> void:
	if storage_path.is_empty():
		return
	var config := ConfigFile.new()
	if config.load(storage_path) != OK:
		return
	balance = maxi(0, int(config.get_value("wallet", "balance", balance)))
	lifetime_earned = maxi(balance, int(config.get_value("wallet", "lifetime_earned", lifetime_earned)))
	lifetime_spent = maxi(0, int(config.get_value("wallet", "lifetime_spent", lifetime_spent)))
	owned = {&"classic": true}
	for cosmetic_id in config.get_value("cosmetics", "owned", PackedStringArray(["classic"])):
		owned[StringName(cosmetic_id)] = true
	var stored_equipped := StringName(config.get_value("cosmetics", "equipped", "classic"))
	equipped = stored_equipped if owns(stored_equipped) else &"classic"

func save_wallet() -> void:
	_save()

func _save() -> void:
	if storage_path.is_empty():
		return
	var owned_ids := PackedStringArray()
	for cosmetic_id: StringName in owned:
		if owned[cosmetic_id]:
			owned_ids.append(String(cosmetic_id))
	var config := ConfigFile.new()
	config.set_value("wallet", "balance", balance)
	config.set_value("wallet", "lifetime_earned", lifetime_earned)
	config.set_value("wallet", "lifetime_spent", lifetime_spent)
	config.set_value("cosmetics", "owned", owned_ids)
	config.set_value("cosmetics", "equipped", String(equipped))
	config.save(storage_path)
