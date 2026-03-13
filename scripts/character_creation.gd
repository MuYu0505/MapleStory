extends Control

# 定义角色样貌索引
var hair_style_idx = 0
var hair_color_idx = 0
var skin_idx = 0

# 样貌数据
var hair_styles = {} # 格式: {"style_name": [texture_v00, texture_v01, ...]}
var hair_style_names = [] # 存储款式名称，方便索引
# 肤色图片数组 (11 种肤色)
var skin_textures = []

# 裁剪设置 (根据你的图片素材调整)
var sprite_width = 64  # 单个小人的宽度
var sprite_height = 64 # 单个小人的高度

var stats = {"str": 4, "dex": 4, "int": 4, "luk": 4}

# 节点引用
@onready var class_label = $VBoxContainer/ClassSelection/ClassName
@onready var desc_label = $VBoxContainer/ClassSelection/ClassDesc
# 样貌预览节点 (已改为 Sprite2D)
@onready var skin_preview: Sprite2D = $VBoxContainer/CharacterPreview/Skin
@onready var hair_preview: Sprite2D = $VBoxContainer/CharacterPreview/Hair

@onready var str_val = $VBoxContainer/Stats/STR/Value
@onready var dex_val = $VBoxContainer/Stats/DEX/Value
@onready var int_val = $VBoxContainer/Stats/INT/Value
@onready var luk_val = $VBoxContainer/Stats/LUK/Value
@onready var dice_button = $VBoxContainer/DiceButton
@onready var start_button = $VBoxContainer/StartButton

# 样貌控制按钮引用
@onready var next_style_btn = $VBoxContainer/AppearanceControls/HairControl/NextHair
@onready var next_color_btn = $VBoxContainer/AppearanceControls/HatControl/NextHat
@onready var next_skin_btn = $VBoxContainer/AppearanceControls/SkinControl/NextSkin

func _ready():
	randomize()
	
	# 加载 11 种肤色图片
	for i in range(11):
		var path = "res://assets/skin/skin_" + str(i) + ".png"
		skin_textures.append(load(path))
	
	# 分类加载发型素材
	load_hair_assets()
	
	# 初始设为“新手”
	if class_label: class_label.text = "新手 (Beginner)"
	if desc_label: desc_label.text = "初出茅庐的冒险者。达到10级后可转职。"
	
	roll_stats() # 初始随机属性
	randomize_appearance() # 初始随机样貌
	
	# 按钮信号连接
	start_button.pressed.connect(_on_start_button_pressed)
	dice_button.pressed.connect(_on_dice_button_pressed)
	next_style_btn.pressed.connect(_on_next_style_pressed)
	next_color_btn.pressed.connect(_on_next_color_pressed)
	next_skin_btn.pressed.connect(_on_next_skin_pressed)

# 核心逻辑：自动分类加载发型
func load_hair_assets():
	var path = "res://assets/hair/"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".png"):
				# 解析文件名，例如: char_a_p1_4har_bob1_v00.png
				# 我们需要提取款式(bob1)
				var parts = file_name.split("_")
				if parts.size() >= 5:
					var style = parts[4] # bob1 或 dap1
					var texture = load(path + file_name)
					
					if not hair_styles.has(style):
						hair_styles[style] = []
						hair_style_names.append(style)
					
					hair_styles[style].append(texture)
			file_name = dir.get_next()
	
	# 对每个款式的颜色进行排序，确保 v00, v01 顺序正确
	for style in hair_styles:
		hair_styles[style].sort_custom(func(a, b): return a.resource_path < b.resource_path)

# 随机样貌
func randomize_appearance():
	if hair_style_names.size() > 0:
		hair_style_idx = randi() % hair_style_names.size()
		var current_style = hair_style_names[hair_style_idx]
		hair_color_idx = randi() % hair_styles[current_style].size()
		
	if skin_textures.size() > 0: 
		skin_idx = randi() % skin_textures.size()
	
	update_appearance_ui()

# 切换发型款式
func _on_next_style_pressed():
	if hair_style_names.size() > 0:
		hair_style_idx = (hair_style_idx + 1) % hair_style_names.size()
		# 切换款式时，重置颜色索引，防止溢出
		var current_style = hair_style_names[hair_style_idx]
		hair_color_idx = hair_color_idx % hair_styles[current_style].size()
		update_appearance_ui()

# 切换发型颜色
func _on_next_color_pressed():
	if hair_style_names.size() > 0:
		var current_style = hair_style_names[hair_style_idx]
		hair_color_idx = (hair_color_idx + 1) % hair_styles[current_style].size()
		update_appearance_ui()

func _on_next_skin_pressed():
	if skin_textures.size() > 0:
		skin_idx = (skin_idx + 1) % skin_textures.size()
		update_appearance_ui()

# 更新样貌显示
func update_appearance_ui():
	# 设置发型预览 (款式 + 颜色)
	if hair_preview and hair_style_names.size() > 0:
		var current_style = hair_style_names[hair_style_idx]
		var textures = hair_styles[current_style]
		hair_preview.texture = textures[hair_color_idx]
		hair_preview.region_enabled = true
		hair_preview.region_rect = Rect2(0, 0, sprite_width, sprite_height)
		
	# 设置肤色预览
	if skin_preview and skin_textures.size() > 0: 
		skin_preview.texture = skin_textures[skin_idx]
		skin_preview.region_enabled = true
		skin_preview.region_rect = Rect2(0, 0, sprite_width, sprite_height)

# 点击开始游戏
func _on_start_button_pressed():
	var current_style = "无"
	if hair_style_names.size() > 0:
		current_style = hair_style_names[hair_style_idx]
	print("开始游戏！属性：", stats, " 样貌：款式-", current_style, " 颜色索引-", hair_color_idx, " 肤色索引-", skin_idx)
	# 之后可以在这里切换到游戏主场景

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
		# 冒险岛初期单项属性通常不会超过 13 点
		if stats[random_key] < 13:
			stats[random_key] += 1
			remaining_points -= 1
	
	update_ui()

# 更新属性 UI 显示
func update_ui():
	if str_val: str_val.text = str(stats["str"])
	if dex_val: dex_val.text = str(stats["dex"])
	if int_val: int_val.text = str(stats["int"])
	if luk_val: luk_val.text = str(stats["luk"])
