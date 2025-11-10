class_name Hud
extends CanvasLayer

@onready var coins_lbl: Label = %CoinsLbl
@onready var painting_progress: ProgressBar = %PaintingProgress
@onready var painting_name: Label = %PaintingName
@onready var buy_slime_btn: Button = %BuySlimeBtn
@onready var open_shop_btn: Button = %OpenShopBtn

@export var shop_menu: ShopMenu

func _ready() -> void:
    GridManager.painting_loaded.connect(setup)
    EconomyManager.coins_changed.connect(_on_coins_changed)
    GridManager.cell_painted.connect(_on_cell_painted)
    SlimeManager.slime_purchased.connect(_on_slime_purchased)
   

func setup(_painting: Painting):
    coins_lbl.text = str(EconomyManager.get_coins())
    painting_progress.value = 0
    painting_progress.max_value = GridManager.cells.size()
    painting_name.text = GridManager.current_painting_data.painting_name
    _update_buy_button()

func _update_buy_button():
    var slime_cost = SlimeManager.calculate_slime_cost()
    if slime_cost > EconomyManager.get_coins():
        buy_slime_btn.disabled = true
    else:
        buy_slime_btn.disabled = false
    buy_slime_btn.text = "Buy Slime (" + str(slime_cost) + " coins)"

func _on_coins_changed(new: int):
    coins_lbl.text = str(new)
    _update_buy_button()

func _on_cell_painted(_position: Vector2i, _color: Color):
    painting_progress.value = GridManager.get_painted_count()

func _on_slime_purchased(_slime: Slime):
    pass


func _on_buy_slime_btn_pressed() -> void:
    SlimeManager.purchase_slime()
    


func _on_open_shop_btn_pressed() -> void:
    if shop_menu:
        shop_menu.toggle_open()


func _on_save_btn_pressed() -> void:
    SaveManager.save_game()
