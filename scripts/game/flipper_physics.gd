extends AnimatableBody2D

@export var rest_angle := 30.0
@export var active_angle := -30.0
@export var flip_speed := 2100.0
@export var flipper_length := 250.0
@export var side := 1

var is_active := false
var current_angle := 0.0
var angular_velocity := 0.0
var ball_ref: RigidBody2D = null

func _ready():
    current_angle = rest_angle
    rotation_degrees = current_angle

func setup(ball: RigidBody2D):
    ball_ref = ball

func set_active(value: bool):
    is_active = value

func _physics_process(delta):
    var target = active_angle if is_active else rest_angle
    var diff = target - current_angle
    
    var accel = flip_speed * 3.0 if is_active else flip_speed * 0.8
    angular_velocity = move_toward(angular_velocity, sign(diff) * flip_speed, accel * delta)
    
    current_angle += angular_velocity * delta
    
    if (is_active and current_angle <= active_angle) or (not is_active and current_angle >= rest_angle):
        current_angle = target
        angular_velocity = 0
    
    rotation_degrees = current_angle
    _transfer_momentum()

func _transfer_momentum():
    if ball_ref == null or not is_instance_valid(ball_ref):
        return
    if not is_active or angular_velocity >= 0:
        return
    
    var to_ball = ball_ref.global_position - global_position
    var flipper_dir = Vector2.RIGHT.rotated(rotation)
    var proj = to_ball.dot(flipper_dir)
    
    if proj < 10 or proj > flipper_length + 20:
        return
    
    var contact_point = global_position + flipper_dir * proj
    var dist = ball_ref.global_position.distance_to(contact_point)
    if dist > 28:
        return
    
    var rad_per_sec = deg_to_rad(angular_velocity)
    var linear_speed = abs(rad_per_sec) * proj
    var hit_dir = flipper_dir.rotated(PI/2 * sign(angular_velocity))
    
    var impulse_strength = linear_speed * ball_ref.mass * 0.65
    ball_ref.apply_central_impulse(hit_dir * impulse_strength)
