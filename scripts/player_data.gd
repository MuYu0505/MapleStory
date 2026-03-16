extends Node

# 这个单例（Autoload）将作为整个游戏的全局玩家数据中心
# 只要游戏还在运行，这个节点里的数据就不会消失

# 基础属性
var stats = {
	"str": 4,
	"dex": 4,
	"int": 4,
	"luk": 4
}

# 外观索引
var hair_style_idx = 0
var hair_color_idx = 0
var skin_idx = 0

# 职业
var character_class = "新手"

# 玩家名字
var character_name = ""

# 角色等级与经验
var level = 1
var exp = 0
var max_exp = 100

# 战斗属性
var hp = 50
var max_hp = 50
var mp = 20
var max_mp = 20

# 保存到本地文件的函数 (可选，用于下次启动游戏时读取)
func save_to_file():
	var save_data = {
		"stats": stats,
		"hair_style_idx": hair_style_idx,
		"hair_color_idx": hair_color_idx,
		"skin_idx": skin_idx,
		"character_class": character_class,
		"character_name": character_name,
		"level": level,
		"exp": exp,
		"hp": hp,
		"mp": mp
	}
	var file = FileAccess.open("user://player_save.dat", FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("数据已成功持久化到本地：user://player_save.dat")

# 从本地加载的函数
func load_from_file():
	if FileAccess.file_exists("user://player_save.dat"):
		var file = FileAccess.open("user://player_save.dat", FileAccess.READ)
		var save_data = file.get_var()
		file.close()
		
		# 将读取到的数据赋值回变量
		if save_data:
			stats = save_data.get("stats", stats)
			hair_style_idx = save_data.get("hair_style_idx", 0)
			hair_color_idx = save_data.get("hair_color_idx", 0)
			skin_idx = save_data.get("skin_idx", 0)
			character_class = save_data.get("character_class", "新手")
			character_name = save_data.get("character_name", "")
			level = save_data.get("level", 1)
			exp = save_data.get("exp", 0)
			hp = save_data.get("hp", 50)
			mp = save_data.get("mp", 20)
			print("本地存档加载成功！")
