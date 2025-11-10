extends Node

func save_game() -> void:
    var save = SaveData.new()
    save.coins = EconomyManager.get_coins()
    save.current_painting_name = GridManager.current_painting_data.painting_name
    save.slime_count = SlimeManager.slimes.size()
    save.upgrade_levels = UpgradeManager.upgrade_levels
    ResourceSaver.save(save, "user://" + save.current_painting_name + ".tres")

func load_game() -> SaveData:
    var save: SaveData = ResourceLoader.load("user://test.tres", "SaveData")
    return save
    
    
    
    
