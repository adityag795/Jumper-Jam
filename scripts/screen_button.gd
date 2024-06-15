extends TextureButton
class_name ScreenButton

# 👇 The signal takes in a button as a parameter
signal clicked(button)

func _on_pressed() -> void:
	# 👇 Passing "screen_button scene" object to the clicked signal.
	clicked.emit(self)
	# ☝️ "self" is a keyword to refer to the object to which the script is attached to.
