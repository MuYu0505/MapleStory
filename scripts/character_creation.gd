extends Control

# 定义角色类
enum CharacterClass { WARRIOR, ARCHER, MAGICIAN, THIEF }

# 角色数据
var classes = [
	{"name": "战士", "desc": "高体力和力量，近战大师。"},
	{"name": "弓箭手", "desc": "高敏捷，远程狙击。"},
	{"name": "魔法师", "desc": "高智力，使用神秘魔法。"},
	{"name": "飞侠", "desc": "高运气和敏捷，潜行刺客。"}
]

var current_class_idx = 0
var stats = {"str": 4, "dex": 4, "int": 4, "luk": 4}

# 节点引用
@onready var class_label = $VBoxContainer/ClassSelection/VBoxContainer/ClassName
@onready var desc_label = $VBoxContainer/ClassSelection/VBoxContainer/ClassDesc
@onready var preview_rect = $VBoxContainer/CharacterPreview
@onready var str_val = $VBoxContainer/Stats/STR/Value
@onready var dex_val = $VBoxContainer/Stats/DEX/Value
@onready var int_val = $VBoxContainer/Stats/INT/Value
@onready var luk_val = $VBoxContainer/Stats/LUK/Value
@onready var dice_button = $VBoxContainer/DiceButton
@onready var start_button = $VBoxContainer/StartButton

func _ready():
	randomize()
	update_ui()
	roll_stats() # 初始随机一次
	start_button.pressed.connect(_on_start_button_pressed)

# 点击开始游戏
func _on_start_button_pressed():
	print("开始游戏！当前角色：", classes[current_class_idx]["name"], " 属性：", stats)
	# 之后可以在这里切换到游戏主场景

# 切换职业：上一个
func _on_prev_class_pressed():
	current_class_idx = (current_class_idx - 1 + classes.size()) % classes.size()
	update_ui()

# 切换职业：下一个
func _on_next_class_pressed():
	current_class_idx = (current_class_idx + 1) % classes.size()
	update_ui()

# 点击骰子随机属性
func _on_dice_button_pressed():
	roll_stats()

# 核心算法：随机分配25点属性，每项最小4点
func roll_stats():
	# 初始每项4点，共16点，还剩9点可自由分配
	var points_to_assign = 25 - 16
	stats = {"str": 4, "dex": 4, "int": 4, "luk": 4}
	
	var keys = stats.keys()
	while points_to_assign > 0:
		var random_key = keys[randi() % keys.size()]
		# 每项上限12 (模拟冒险岛初期的极端或平衡分配)
		if stats[random_key] < 12:
			stats[random_key] += 1
			points_to_assign -= 1
	
	update_ui()

# 更新UI显示
func update_ui():
	var c = classes[current_class_idx]
	if class_label: class_label.text = c["name"]
	if desc_label: desc_label.text = c["desc"]
	
	if str_val: str_val.text = str(stats["str"])
	if dex_val: dex_val.text = str(stats["dex"])
	if int_val: int_val.text = str(stats["int"])
	if luk_val: luk_val.text = str(stats["luk"])
