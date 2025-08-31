# Godot Item Randomizer

A Godot 4.x addon for randomly selecting from an array with repetition prevention.
Spun out from needing a way to add variety to notepad textures in [House on ||REDACTED|| St.](https://github.com/matthew-cavener/house-on-redacted-st)
and being irritated when the _same texture **was selected repeatedly!**_ Ya know, _instead_ of doing the many other far more important things that needed done before the end of the jam.

Useful for anytime when players will notice repetition. Got 6 textures to choose from and only going to show one at a time for an extended period?
Got a 9 page letter from your hyper detail oriented late uncle and think its strange 3 consecutive pages are all stained in the exact same way?

This is great for both!

Spawning ~500 enemies in 500 milliseconds? Nobody's likely to be able to tell the order they spawned in, this probably isn't helpful.

## Usage

```gdscript
# Create randomizer
var texture_randomizer = ItemRandomizer.new(items = [texture1, texture2, texture3], exclusion_count = 1)

# Get random texture (prefers less recently selected ones)
var texture = texture_randomizer.get_random_item()
$Sprite.texture = texture

# Works with any `Array` of items! (I'm pretty sure at least. Go wild, let me know if it works for ya)
var enemy_randomizer = ItemRandomizer.new(items = [enemy1, enemy2, enemy3], exclusion_count = 2)
var next_enemy = enemy_randomizer.get_random_item()
enemy = next_enemy.instantiate()
```

## Installation

### From Godot Asset Library

1. Open AssetLib in Godot
2. Search for "Item Randomizer"
3. Install and enable in Project Settings > Plugins

### Manual Installation

1. Copy `addons/item_randomizer` to your project's `addons/` folder
2. Enable in Project Settings > Plugins

## Configuration

```gdscript
# Initialize with any items and exclusion count
var item_randomizer = ItemRandomizer.new([item1, item2, item3], 2)

# Or configure after creation
var texture_randomizer = ItemRandomizer.new()
texture_randomizer.items = [texture1, texture2, texture3]
texture_randomizer.exclusion_count = 1

# Modify item array directly
texture_randomizer.items.append(new_texture)
texture_randomizer.items.erase(old_texture)

# Shuffle items (especially useful immediately after adding/removing items)
texture_randomizer.items.shuffle()

# Even modify weights directly
var new_weights = [16, 9, 4, 1, 0]
texture_randomizer.weights = new_weights
```

The `weights` array _will_ be regenerated if the `exclusion_count` is changed, or if the size of the `items` array is not the same size as the `weights` array when a selection is made. I should probably make this more clear and well thought out, but it's fine for now.

## API

- `items: Array` - Array of items, ordered by least recently selected to most recently selected
- `weights: Array` - Array of selection weights, corresponding to each spot in `items`
- `exclusion_count: int` - Most recent items to prohibit (default: 1)
  - `0` = allow all items (still prefers less recently selected ones)
  - `1` = exclude last selected item from next selection
  - `2` = exclude last 2 selected items from next selection
  - So on and so forth until only the least recently selected item is left
    - It'll throw an error if you tell it to exclude all items from selection
- `get_random_item() -> Variant` - Returns a random item, preferring less recently selected

## Use Cases

This randomizer works with any type of item `Array` (AFAIK, only tested with `Array[Texture2D]` because that's all I needed, but I see no reason it _shouldn't_ work with other types):

- **Textures**: Randomize sprite textures!
- **Scenes?**: Different room layouts or maybe enemy types?
- **Strings?**: Random dialogue lines or flavor text if your dialogue system supports it I guess.
- **Literally anything Godot lets you put in an `Array`!**: Who's gonna stop you?! I'm not going to come to your home and pour out all your (oat)milk if you try to randomly select from an `Array[MissingResource]`!

> **Note**: For audio randomization, just use the built-in [`AudioStreamRandomizer`](https://docs.godotengine.org/en/stable/classes/class_audiostreamrandomizer.html) which can also change pitch and volume and is (more or less) what this is (more or less) inspired by.

## How It Works

The ItemRandomizer uses two arrays to prevent repetition while maintaining randomness:

1. **Items Array**: Contains your items ordered by recency (least recently used first, most recently used last)
2. **Weights Array**: Contains weights for each item position, with zeros at the end to exclude recent selections

When you call `get_random_item()`:

1. Weighted selection ([`rand_weighted`](https://docs.godotengine.org/en/latest/classes/class_randomnumbergenerator.html#class-randomnumbergenerator-method-rand-weighted)) from the `items` array. Weights for weighted selection are the `weights` array.
2. The selected item is moved to the end of the items array (marking it as most recent)
3. With the default `exclusion_count = 1`, the last item (most recent) has weight 0 and cannot be selected in the next weighted random selection

### Example Walkthrough

**Initial state:**

| Item | Weight<br/>(exclusion_count=1) | Weight<br/>(exclusion_count=2) | Probability<br/>(exclusion_count=1) | Probability<br/>(exclusion_count=2) |
|------|-----------------------------|-----------------------------|----------------------------------|----------------------------------|
| <span style="color: red">Red</span> | <span style="color: red">5</span> | <span style="color: red">4</span> | <span style="color: red">33.3%</span> | <span style="color: red">40.0%</span> |
| <span style="color: orange">Orange</span> | <span style="color: orange">4</span> | <span style="color: orange">3</span> | <span style="color: orange">26.7%</span> | <span style="color: orange">30.0%</span> |
| <span style="color: yellow">Yellow</span> | <span style="color: yellow">3</span> | <span style="color: yellow">2</span> | <span style="color: yellow">20.0%</span> | <span style="color: yellow">20.0%</span> |
| <span style="color: green">Green</span> | <span style="color: green">2</span> | <span style="color: green">1</span> | <span style="color: green">13.3%</span> | <span style="color: green">10.0%</span> |
| <span style="color: blue">Blue</span> | <span style="color: blue">1</span> | <span style="color: blue">0</span> | <span style="color: blue">6.7%</span> | <span style="color: blue">0.0%</span> |
| <span style="color: violet">Violet</span> | <span style="color: violet">0</span> | <span style="color: violet">0</span> | <span style="color: violet">0.0%</span> | <span style="color: violet">0.0%</span> |

---

**Selection 1: <span style="color: yellow">Yellow</span> selected**

| Item | Weight<br/>(exclusion_count=1) | Weight<br/>(exclusion_count=2) | Probability<br/>(exclusion_count=1) | Probability<br/>(exclusion_count=2) |
|------|-----------------------------|-----------------------------|----------------------------------|----------------------------------|
| <span style="color: red">Red</span> | <span style="color: red">5</span> | <span style="color: red">4</span> | <span style="color: red">33.3%</span> | <span style="color: red">40.0%</span> |
| <span style="color: orange">Orange</span> | <span style="color: orange">4</span> | <span style="color: orange">3</span> | <span style="color: orange">26.7%</span> | <span style="color: orange">30.0%</span> |
| <span style="color: green">Green</span> | <span style="color: green">3</span> | <span style="color: green">2</span> | <span style="color: green">20.0%</span> | <span style="color: green">20.0%</span> |
| <span style="color: blue">Blue</span> | <span style="color: blue">2</span> | <span style="color: blue">1</span> | <span style="color: blue">13.3%</span> | <span style="color: blue">10.0%</span> |
| <span style="color: violet">Violet</span> | <span style="color: violet">1</span> | <span style="color: violet">0</span> | <span style="color: violet">6.7%</span> | <span style="color: violet">0.0%</span> |
| <span style="color: yellow">Yellow</span> | <span style="color: yellow">0</span> | <span style="color: yellow">0</span> | <span style="color: yellow">0.0%</span> | <span style="color: yellow">0.0%</span> |

*Yellow moved to end and now has weight 0*

---

**Selection 2: <span style="color: red">Red</span> selected**

| Item | Weight<br/>(exclusion_count=1) | Weight<br/>(exclusion_count=2) | Probability<br/>(exclusion_count=1) | Probability<br/>(exclusion_count=2) |
|------|-----------------------------|-----------------------------|----------------------------------|----------------------------------|
| <span style="color: orange">Orange</span> | <span style="color: orange">5</span> | <span style="color: orange">4</span> | <span style="color: orange">33.3%</span> | <span style="color: orange">40.0%</span> |
| <span style="color: green">Green</span> | <span style="color: green">4</span> | <span style="color: green">3</span> | <span style="color: green">26.7%</span> | <span style="color: green">30.0%</span> |
| <span style="color: blue">Blue</span> | <span style="color: blue">3</span> | <span style="color: blue">2</span> | <span style="color: blue">20.0%</span> | <span style="color: blue">20.0%</span> |
| <span style="color: violet">Violet</span> | <span style="color: violet">2</span> | <span style="color: violet">1</span> | <span style="color: violet">13.3%</span> | <span style="color: violet">10.0%</span> |
| <span style="color: yellow">Yellow</span> | <span style="color: yellow">1</span> | <span style="color: yellow">0</span> | <span style="color: yellow">6.7%</span> | <span style="color: yellow">0.0%</span> |
| <span style="color: red">Red</span> | <span style="color: red">0</span> | <span style="color: red">0</span> | <span style="color: red">0.0%</span> | <span style="color: red">0.0%</span> |

*Red moved to end and now has weight 0*

---

**Selection 3: <span style="color: blue">Blue</span> selected**

| Item | Weight<br/>(exclusion_count=1) | Weight<br/>(exclusion_count=2) | Probability<br/>(exclusion_count=1) | Probability<br/>(exclusion_count=2) |
|------|-----------------------------|-----------------------------|----------------------------------|----------------------------------|
| <span style="color: orange">Orange</span> | <span style="color: orange">5</span> | <span style="color: orange">4</span> | <span style="color: orange">33.3%</span> | <span style="color: orange">40.0%</span> |
| <span style="color: green">Green</span> | <span style="color: green">4</span> | <span style="color: green">3</span> | <span style="color: green">26.7%</span> | <span style="color: green">30.0%</span> |
| <span style="color: violet">Violet</span> | <span style="color: violet">3</span> | <span style="color: violet">2</span> | <span style="color: violet">20.0%</span> | <span style="color: violet">20.0%</span> |
| <span style="color: yellow">Yellow</span> | <span style="color: yellow">2</span> | <span style="color: yellow">1</span> | <span style="color: yellow">13.3%</span> | <span style="color: yellow">10.0%</span> |
| <span style="color: red">Red</span> | <span style="color: red">1</span> | <span style="color: red">0</span> | <span style="color: red">6.7%</span> | <span style="color: red">0.0%</span> |
| <span style="color: blue">Blue</span> | <span style="color: blue">0</span> | <span style="color: blue">0</span> | <span style="color: blue">0.0%</span> | <span style="color: blue">0.0%</span> |

*Blue moved to end and now has weight 0*
