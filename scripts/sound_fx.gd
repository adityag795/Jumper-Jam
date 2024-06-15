extends Node

# 👇 Creating a dictionary of sounds
var sounds = {
	"Click" : load("res://assets/sound/Click.wav"),
	"Fall" : load("res://assets/sound/Fall.wav"),
	"Jump" : load("res://assets/sound/Jump.wav")
}

# 👇 Returns all the children of "SoundFX" Node as an array
@onready var sound_players = get_children()
# ☝️ This is an array of all the "AudioStreamPlayers" 
# ☝️ that we have in the scene

func play(sound_name):
	# 👇 Getting the sound from the dictionary
	var sound_to_play = sounds[sound_name]
	# 👇 Looping over and checking if there is any AudioStreamPlayer
	# 👇 currently available to play sound or not.
	for sound_player in sound_players:
		# 👇 If soundplayer is not playing (checkbox under "AudioStreamPlayer")
		if !sound_player.playing:
			# 👇 Setting the "Stream" to "sound_to_play" under 
			# 👇 "AudioStreamPlayer" in the inspector.
			sound_player.stream = sound_to_play
			sound_player.play()
			# 👇 Don't keep looping.
			return
	# 👇 This will be called only if we don't return in the above for loop
	print("Too many sounds playing at once, not enough sound players")
	# To solve this ☝️, Duplicate and add more Sound players
	# under the "SoundFX" Node
