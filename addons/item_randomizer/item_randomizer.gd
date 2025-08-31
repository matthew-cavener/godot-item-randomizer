## A generic randomizer that prevents repetition by deprioritizing recently used items.
class_name ItemRandomizer
extends RefCounted

@export var items: Array = []
@export var exclusion_count: int = 1 : set = set_exclusion_count

var weights: Array = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _init(initial_items: Array = [], initial_exclusion_count: int = 1) -> void:
    if initial_items.size() > 0:
        items = initial_items.duplicate()
    exclusion_count = initial_exclusion_count

## Validates configuration and updates weights if needed. Returns true if valid.
func _validate_configuration() -> bool:
    var item_count = items.size()
    if item_count == 0:
        push_error("Cannot use empty item randomizer. Add items before use.")
        return false
    var selectable_count = item_count - exclusion_count
    if selectable_count <= 0:
        push_error("exclusion_count (%d) must be less than item count (%d). No items can be selected!" % [exclusion_count, item_count])
        return false
    if weights.size() != item_count:
        _update_weights()
    return true

## Returns a randomly selected item, avoiding recent repetitions.
func get_random_item() -> Variant:
    if not _validate_configuration():
        return null
    if items.size() == 1:
        return items[0]
    var selected_index = rng.rand_weighted(weights)
    var selected_item = items.pop_at(selected_index)
    items.append(selected_item)
    return selected_item

func _update_weights() -> void:
    var item_count = items.size()
    var selectable_count = item_count - exclusion_count
    weights = range(selectable_count, 0, -1)
    var zeros = Array()
    zeros.resize(exclusion_count)
    zeros.fill(0)
    weights.append_array(zeros)

func set_exclusion_count(value: int) -> void:
    exclusion_count = value
    if items.size() > 0:
        _validate_configuration()
        _update_weights()
