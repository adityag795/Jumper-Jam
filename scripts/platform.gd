extends Area2D

# Now this 👇 keyword can be used in other scripts as well to check if an object is a platform or not
class_name Platform

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.velocity.y > 0:
			body.jump()
