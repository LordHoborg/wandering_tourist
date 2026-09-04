extends SceneTree

const Wallet = preload("res://scripts/game/coin_wallet.gd")

var passed := 0
var failed := 0
var path := "user://coin_wallet_test.cfg"

func _init() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	var wallet = Wallet.new(path)
	_check(wallet.balance == 0 and wallet.owns(&"classic") and wallet.equipped == &"classic", "wallet starts with the classic cosmetic")
	_check(wallet.earn(125) == 125 and wallet.balance == 125 and wallet.lifetime_earned == 125, "earning coins updates the balance and lifetime total")
	_check(wallet.earn(-20) == 0 and wallet.balance == 125, "negative coin awards are ignored")
	_check(not wallet.purchase_or_equip(&"neon_shades"), "insufficient balance blocks a cosmetic purchase")
	_check(wallet.earn(100) == 100 and wallet.purchase_or_equip(&"neon_shades"), "enough coins unlock and equip a cosmetic")
	_check(wallet.balance == 45 and wallet.owns(&"neon_shades") and wallet.equipped == &"neon_shades", "purchase deducts the exact cosmetic price")
	_check(wallet.purchase_or_equip(&"classic") and wallet.balance == 45 and wallet.equipped == &"classic", "owned cosmetics can be equipped without spending")
	var reloaded = Wallet.new(path)
	_check(reloaded.balance == 45 and reloaded.owns(&"neon_shades") and reloaded.equipped == &"classic", "wallet balance, ownership, and equipment persist")
	_check(not reloaded.purchase_or_equip(&"not_a_cosmetic"), "unknown cosmetics are rejected")
	print("TESTS PASSED: %d" % passed)
	print("TESTS FAILED: %d" % failed)
	quit(0 if failed == 0 else 1)

func _check(condition: bool, name: String) -> void:
	if condition:
		passed += 1
		print("PASS: %s" % name)
	else:
		failed += 1
		push_error("FAIL: %s" % name)
