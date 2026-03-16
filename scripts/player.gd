extends CharacterBody2D

# 玩家移动控制脚本 
# 包含：重力、跳跃、水平移动、外观同步

# --- 配置参数 ---
@export var speed = 300.0          # 走路速度
@export var jump_velocity = -500.0  # 跳跃力度
@export var acceleration = 1500.0  # 加速度 (起步感)
@export var friction = 1000.0      # 摩擦力 (刹车感)

# 获取重力设定 (使用项目默认重力)
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# 节点引用
@onready var skin_sprite = $Skin
@onready var hair_sprite = $Hair
@onready var anim_player = $AnimationPlayer

# 方向记录 (1 为右, -1 为左)
var face_direction = 1

# 纹理资源列表 (与创建界面逻辑一致)
var skin_textures = []
var hair_styles = {} # { "style_name": [texture_v00, texture_v01, ...] }
var hair_style_names = []

func _ready():
	# 1. 加载所有可用素材 (为了能根据索引找到对应的纹理)
	load_all_assets()
	
	# 2. 从 PlayerData 同步玩家选择的外观
	sync_appearance()
	
	# 3. 设置摄像机平滑
	if has_node("Camera2D"):
		var camera = $Camera2D
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = 5.0
				
func _physics_process(delta):
	# 应用重力
	if not is_on_floor():
		velocity.y += gravity * delta

	# 处理跳跃
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# 获取水平输入方向 (-1, 0, 1)
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# 处理移动、摩擦力与动画
	if direction:
		# 有输入：加速
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		# 转向处理
		if direction > 0:
			face_direction = 1
		elif direction < 0:
			face_direction = -1
		
		# 播放走路动画
		if is_on_floor():
			play_animation("walk")
	else:
		# 无输入：摩擦力减速
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		# 播放待机动画
		if is_on_floor():
			play_animation("idle")

	# 处理跳跃/掉落动画
	if not is_on_floor():
		if velocity.y < -50: # 向上冲刺阶段
			play_animation("jump")
		elif velocity.y > 50: # 明显下落阶段
			play_animation("fall")
	
	move_and_slide()

# 统一播放动画逻辑 (同步皮肤和发型，并根据方向选择动画名)
func play_animation(anim_base_name: String):
	var anim_name = anim_base_name
	if face_direction == 1:
		anim_name += "_right"
	else:
		anim_name += "_left"
		
	# 如果当前动画正在播放且就是目标动画，则不做操作 (防止重启非循环动画)
	if anim_player.current_animation == anim_name and anim_player.is_playing():
		return
		
	# 如果是非循环动画（如 jump）且已经播放到了最后，也不要重复触发
	if anim_player.current_animation == anim_name and not anim_player.is_playing():
		# 只有循环动画且未处于循环状态时才重启
		var anim = anim_player.get_animation(anim_name)
		if anim.loop_mode != Animation.LOOP_NONE:
			anim_player.play(anim_name)
		return
		
	# 切换新动画：直接播放，不进行混合 (防止重影)
	# 强制使用 0 混合时间，这对像素游戏至关重要
	# print("Play Anim: ", anim_name, " Dir: ", face_direction, " VelY: ", velocity.y)
	anim_player.play(anim_name, 0)

# 同步外观逻辑
func sync_appearance():
	var player_data = get_node_or_null("/root/PlayerData")
	if not player_data:
		printerr("错误：PlayerData 单例未找到！请在项目设置中添加。")
		return
	
	# 同步肤色
	if skin_textures.size() > player_data.skin_idx:
		skin_sprite.texture = skin_textures[player_data.skin_idx]
		setup_sprite_region(skin_sprite)
	
	# 同步发型
	if player_data.hair_style_idx < hair_style_names.size():
		var style_name = hair_style_names[player_data.hair_style_idx]
		var color_textures = hair_styles[style_name]
		if player_data.hair_color_idx < color_textures.size():
			hair_sprite.texture = color_textures[player_data.hair_color_idx]
			setup_sprite_region(hair_sprite)

# 设置 Sprite 的帧显示 (8x8 宫格，每帧 64x64，Nearest 过滤)
func setup_sprite_region(sprite: Sprite2D):
	sprite.region_enabled = false
	sprite.hframes = 8
	sprite.vframes = 8
	sprite.frame = 16 # 默认为侧面待机
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2(3, 3) 
	sprite.position = Vector2(0, -96) # 向上偏移，确保脚踩在 (0,0)

# 加载素材逻辑 (复用 character_creation.gd 的逻辑)
func load_all_assets():
	# 加载肤色
	var skin_path = "res://assets/skin/"
	var dir = DirAccess.open(skin_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".png"):
				skin_textures.append(load(skin_path + file_name))
			file_name = dir.get_next()
	skin_textures.sort_custom(func(a, b): return a.resource_path < b.resource_path)
	
	# 加载发型
	var hair_path = "res://assets/hair/"
	dir = DirAccess.open(hair_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".png"):
				var parts = file_name.split("_")
				if parts.size() >= 5:
					var style = parts[4]
					var texture = load(hair_path + file_name)
					if not hair_styles.has(style):
						hair_styles[style] = []
						hair_style_names.append(style)
					hair_styles[style].append(texture)
			file_name = dir.get_next()
		
		hair_style_names.sort()
		for style in hair_styles:
			hair_styles[style].sort_custom(func(a, b): return a.resource_path < b.resource_path)
