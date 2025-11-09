class_name ShopMenu
extends CanvasLayer

@onready var total_coins_lbl: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TotalCoinsLbl



func _ready() -> void:
    hide()
    EconomyManager.coins_changed.connect(_update_total_coins)
    _update_total_coins(EconomyManager.get_coins())
    
func _update_total_coins(coins: int):
    total_coins_lbl.text =  "Total Coins: " + str(coins)
    
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("open_shop"):
        toggle_open()
            
func toggle_open():
    if visible:
        close()
    else:
        open()

func open():
    get_tree().paused = true
    show()
    
func close():
    get_tree().paused = false 
    hide()
    


func _on_close_pressed() -> void:
    close()
