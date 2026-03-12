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

# 核心算法：遵循冒险岛经典规则
# 四项属性之和固定为 25，每项属性最低为 4
func roll_stats():
	var total_points = 25
	var min_stat = 4
	
	# 1. 先给每项属性分配基础值 4
	stats = {"str": min_stat, "dex": min_stat, "int": min_stat, "luk": min_stat}
	
	# 2. 计算剩余可分配点数 (25 - 4*4 = 9)
	var remaining_points = total_points - (min_stat * 4)
	
	# 3. 随机分配剩余点数
	var keys = stats.keys()
	while remaining_points > 0:
		var random_key = keys[randi() % keys.size()]
		# 冒险岛初期单项属性通常不会超过 12-13，这里设置一个合理的上限
		if stats[random_key] < 13:
			stats[random_key] += 1
			remaining_points -= 1
	
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
