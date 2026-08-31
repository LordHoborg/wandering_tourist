class_name WarningMonitor
extends RefCounted

## Tracks parameter warning bands and decides when warning cues fire:
## one cue on band entry, then at most one reminder every REMINDER_PERIOD
## seconds while the parameter stays in the band; leaving the band resets it.
## Pure timing logic; the view layer owns pulse rendering and cue playback.

const REMINDER_PERIOD := 5.0
const LOW_BAND := 30.0
const HIGH_BAND := 70.0

var _in_band: Dictionary = {}
var _next_reminder_at: Dictionary = {}

## Feed current parameter values and the current time (seconds). Returns the
## cue ids to play this update (empty when nothing is due).
func update(values: Dictionary, now: float) -> Array[StringName]:
	var cues: Array[StringName] = []
	for parameter_id in values:
		var value: float = values[parameter_id]
		var warning := value <= LOW_BAND or value >= HIGH_BAND
		if warning and not _in_band.get(parameter_id, false):
			_in_band[parameter_id] = true
			_next_reminder_at[parameter_id] = now + REMINDER_PERIOD
			cues.append(&"warning")
		elif warning and now >= _next_reminder_at.get(parameter_id, INF):
			_next_reminder_at[parameter_id] = now + REMINDER_PERIOD
			cues.append(&"warning")
		elif not warning:
			_in_band[parameter_id] = false
	return cues

func reset() -> void:
	_in_band.clear()
	_next_reminder_at.clear()
