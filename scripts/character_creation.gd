extends Control

# 定义角色样貌索引
var hair_idx = 0
var face_idx = 0
var skin_idx = 0

# 样貌数据 (之后你可以把素材路径放在这里)
var hairs = [null, null, null] # 先放空位，你可以填入 Texture2D
var faces = [null, null, null]
var skins = [Color.WHITE, Color.BISQUE, Color.SANDY_BROWN] # 肤色可以直接用颜色调制

var stats = {"str": 4, "dex": 4, "int": 4, "luk": 4}

# 节点引用
@onready var class_label = $VBoxContainer/ClassSelection/VBoxContainer/ClassName
@onready var desc_label = $VBoxContainer/ClassSelection/VBoxContainer/ClassDesc
# 样貌预览节点 (之后我们会把这些节点加到场景里)
@onready var skin_preview = $VBoxContainer/CharacterPreview/Skin
@onready var hair_preview = $VBoxContainer/CharacterPreview/Hair
@onready var face_preview = $VBoxContainer/CharacterPreview/Face

@onready var str_val = $VBoxContainer/Stats/STR/Value
@onready var dex_val = $VBoxContainer/Stats/DEX/Value
@onready var int_val = $VBoxContainer/Stats/INT/Value
@onready var luk_val = $VBoxContainer/Stats/LUK/Value
@onready var dice_button = $VBoxContainer/DiceButton
@onready var start_button = $VBoxContainer/StartButton

# 样貌控制按钮引用
@onready var next_hair_btn = $VBoxContainer/AppearanceControls/HairControl/NextHair
@onready var next_face_btn = $VBoxContainer/AppearanceControls/FaceControl/NextFace
@onready var next_skin_btn = $VBoxContainer/AppearanceControls/SkinControl/NextSkin

func _ready():
	randomize()
	# 初始设为“新手”
	if class_label: class_label.text = "新手 (Beginner)"
	if desc_label: desc_label.text = "初出茅庐的冒险者。达到10级后可转职。"
	
	roll_stats() # 初始随机属性
	randomize_appearance() # 初始随机样貌
	
	# 按钮信号连接
	start_button.pressed.connect(_on_start_button_pressed)
	dice_button.pressed.connect(_on_dice_button_pressed)
	next_hair_btn.pressed.connect(_on_next_hair_pressed)
	next_face_btn.pressed.connect(_on_next_face_pressed)
	next_skin_btn.pressed.connect(_on_next_skin_pressed)

# 点击开始游戏
func _on_start_button_pressed():
	print("开始游戏！属性：", stats, " 样貌索引：", [hair_idx, face_idx, skin_idx])
	# 之后可以在这里切换到游戏主场景

# 随机样貌
func randomize_appearance():
	hair_idx = randi() % hairs.size()
	face_idx = randi() % faces.size()
	skin_idx = randi() % skins.size()
	update_appearance_ui()

# 切换样貌的函数 (你可以绑定到 UI 按钮上)
func _on_next_hair_pressed():
	hair_idx = (hair_idx + 1) % hairs.size()
	update_appearance_ui()

func _on_next_face_pressed():
	face_idx = (face_idx + 1) % faces.size()
	update_appearance_ui()

func _on_next_skin_pressed():
	skin_idx = (skin_idx + 1) % skins.size()
	update_appearance_ui()

# 更新样貌显示
func update_appearance_ui():
	if hair_preview: hair_preview.texture = hairs[hair_idx]
	if face_preview: face_preview.texture = faces[face_idx]
	if skin_preview: 
		# 肤色可以通过改变 TextureRect 的 modulate 颜色来实现
		skin_preview.modulate = skins[skin_idx]

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
