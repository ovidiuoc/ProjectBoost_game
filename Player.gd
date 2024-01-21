extends RigidBody3D

## Vertical force applied
@export_range(750.0, 3000.0) var thrust: float = 1000.0
@export var torque: float = 100.0

var is_transitioning : bool = false

@onready var crash_sound : AudioStreamPlayer = $ExplosionAudio
@onready var win_sound : AudioStreamPlayer = $SuccessAudio
@onready var rocket_sound : AudioStreamPlayer3D = $RocketAudio
@onready var booster_particles : GPUParticles3D = $BoosterParticles
@onready var right_booster_particles : GPUParticles3D = $RightBoosterParticles
@onready var left_booster_particles : GPUParticles3D = $LeftBoosterParticles
@onready var explosion_particles : GPUParticles3D = $ExplosionParticles
@onready var success_particles : GPUParticles3D = $SuccessParticles

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust)
		booster_particles.emitting = true
		if rocket_sound.playing == false:
			rocket_sound.play()
	else:
		booster_particles.emitting = false
		if rocket_sound.playing == true:
			rocket_sound.stop()
		
	
	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0.0,0.0,torque * delta))
		right_booster_particles.emitting = true
	else:
		right_booster_particles.emitting = false
		

	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0.0,0.0,-torque * delta))
		left_booster_particles.emitting = true
	else:
		left_booster_particles.emitting = false
		
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _on_body_entered(body: Node) -> void:
	if is_transitioning == false:
		if "Goal" in body.get_groups():
			win_sequence(body.file_path)
		if "Hazard" in body.get_groups():
			crash_sequence()
		
func crash_sequence() -> void:
	print("You crashed! Game over !")
	explosion_particles.emitting = true
	set_process(false)
	crash_sound.play()
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().reload_current_scene)
	
func win_sequence(next_level_file : String) -> void:
	print("You win!")
	success_particles.emitting = true
	win_sound.play()
	is_transitioning = true
	set_process(false)
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_file))
