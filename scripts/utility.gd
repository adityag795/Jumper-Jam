extends Node

# 👇 To print debug messgaes on "Debug" node
func add_log_msg(log_str: String):
	# 👇 This will return "ConsoleLog" node from the "screens" scene
	var console = get_tree().get_first_node_in_group("debug_console")
	if console:
		# 👇 Finding a node of name "LogLabel"
		var log_label = console.find_child("LogLabel")
		# 👇 if found and not NULL
		if log_label:
			# 👇 If the text is not empty 
			if !log_label.text.is_empty():
				# 👇 Only then, add a new line
				log_label.text += "\n"
			# 👇 Appending the message passed to this function to the log_label's text
			log_label.text += log_str
