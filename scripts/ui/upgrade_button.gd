class_name UpgradeButton
extends PanelContainer

@export var upgrade_type: UpgradeManager.UPGRADE_TYPE
@onready var effect_lbl: Label = $MarginContainer/VBoxContainer/HBoxContainer2/EffectLbl
@onready var upgrade_details_lbl: Label = $MarginContainer/VBoxContainer/HBoxContainer/UpgradeDetailsLbl
@onready var cost_lbl: Label = $MarginContainer/VBoxContainer/HBoxContainer/CostLbl
@onready var upgrade_btn: Button = $MarginContainer/VBoxContainer/HBoxContainer2/UpgradeBtn

func _ready() -> void:
    _update_ui(upgrade_type, UpgradeManager.get_upgrade_level(upgrade_type))
    UpgradeManager.upgrade_purchased.connect(_update_ui)
    EconomyManager.coins_changed.connect(func(_new: int): _update_ui(upgrade_type, UpgradeManager.get_upgrade_level(upgrade_type)))
    
func _update_ui(type: UpgradeManager.UPGRADE_TYPE, new_lvl: int):
    if type != upgrade_type:
        return
    
    if new_lvl == UpgradeManager.get_upgrade_max_level(type):
        upgrade_btn.disabled = true
        upgrade_btn.text = "MAX"
        
    var cur_effect = UpgradeManager.get_upgrade_effect(upgrade_type, new_lvl)
    var next_effect = UpgradeManager.get_upgrade_effect(upgrade_type, new_lvl + 1)
    var change = next_effect - cur_effect
    effect_lbl.text = str(cur_effect) + " -> " + str(next_effect) + " (+" + str(change) + ")" 
    upgrade_details_lbl.text = UpgradeManager.get_upgrade_name(upgrade_type) + "[Lvl " + str(UpgradeManager.get_upgrade_level(upgrade_type)) + "/" + str(UpgradeManager.get_upgrade_max_level(upgrade_type)) + "]"
    var cost = UpgradeManager.get_cost_for_current(upgrade_type)
    if cost > EconomyManager.get_coins():
        upgrade_btn.disabled = true
    else:
        upgrade_btn.disabled = false
        
    cost_lbl.text = str(UpgradeManager.get_cost_for_current(upgrade_type))


func _upgrade_pressed():
    UpgradeManager.purchase_upgrade(upgrade_type)
