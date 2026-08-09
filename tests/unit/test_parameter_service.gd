extends SceneTree

func _init() -> void:
	var hunger := ParameterDefinition.new()
	hunger.id = &"hunger"
	var service := ParameterService.new([hunger])
	assert(service.state.values[&"hunger"] == 50.0)
	assert(service.apply({&"hunger": -30.0}))
	assert(not service.apply({&"hunger": -0.1}))
	assert(service.tick(1.0) == false)
	quit()
