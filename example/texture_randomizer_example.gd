extends Control

@onready var texture_display: TextureRect = $VBox/TextureDisplay
@onready var info_label: Label = $VBox/InfoLabel
@onready var button: Button = $VBox/GetTextureButton
@onready var avoid_count_spinbox: SpinBox = $VBox/AvoidCountContainer/AvoidCountSpinBox

var texture_randomizer: ItemRandomizer
var colored_textures: Array[Texture2D] = []
var exclusion_count: int = 2

func _ready():
    create_demo_textures()
    texture_randomizer = ItemRandomizer.new(colored_textures, exclusion_count)
    avoid_count_spinbox.min_value = 0
    avoid_count_spinbox.max_value = colored_textures.size() - exclusion_count
    avoid_count_spinbox.value = texture_randomizer.exclusion_count
    avoid_count_spinbox.value_changed.connect(_on_avoid_count_changed)
    button.pressed.connect(_on_get_texture_pressed)
    var initial_texture = texture_randomizer.get_random_item()
    texture_display.texture = initial_texture
    update_display()

func create_demo_textures():
    var colors = [Color.RED, Color.ORANGE, Color.YELLOW, Color.GREEN, Color.BLUE, Color.VIOLET]
    var texture_names = ["Red", "Orange", "Yellow", "Green", "Blue", "Violet"]
    for i in colors.size():
        var image = Image.create(64, 64, false, Image.FORMAT_RGB8)
        image.fill(colors[i])
        var texture = ImageTexture.new()
        texture.set_image(image)
        texture.set_meta("color_name", texture_names[i])
        colored_textures.append(texture)

func _on_get_texture_pressed():
    var selected_texture = texture_randomizer.get_random_item()
    texture_display.texture = selected_texture
    update_display()

func _on_avoid_count_changed(value: float):
    texture_randomizer.exclusion_count = int(value)
    update_display()

func update_display():
    var current_texture_name = ""
    if texture_display.texture and texture_display.texture.has_meta("color_name"):
        current_texture_name = texture_display.texture.get_meta("color_name")
    var texture_order = []
    for texture in texture_randomizer.items:
        if texture.has_meta("color_name"):
            texture_order.append(texture.get_meta("color_name"))
    var total_weight = 0
    for weight in texture_randomizer.weights:
        total_weight += weight
    var probabilities = []
    for weight in texture_randomizer.weights:
        if total_weight > 0:
            var probability = float(weight) / float(total_weight) * 100.0
            probabilities.append("%.1f%%" % probability)
        else:
            probabilities.append("0.0%")
    var info_text = ""
    if current_texture_name != "":
        info_text += "Selected: %s\n\n" % current_texture_name
    info_text += "Current order (least → most recent):\n%s\n\n" % " → ".join(texture_order)
    info_text += "Weights: %s\n" % str(texture_randomizer.weights)
    info_text += "Probabilities: [%s]\n\n" % ", ".join(probabilities)
    print(probabilities)
    info_text += "exclusion_count: %d\n" % texture_randomizer.exclusion_count
    var selectable_count = colored_textures.size() - texture_randomizer.exclusion_count
    if selectable_count <= 0:
        info_text += "(No textures can be selected! Reduce exclusion_count)"
    else:
        info_text += "(Last %d textures cannot be selected)" % texture_randomizer.exclusion_count
    info_label.text = info_text
