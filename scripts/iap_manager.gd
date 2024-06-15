extends Node

# 👇 Signal is going to be emitted in two cases:
signal unlock_new_skin
# ☝️ 1. If player doesn't own the skin and they have just purchased it.
# ☝️ 2. If the player has purchased it in the past and we can learn that from querry.

var google_payment = null
# 👇 storing Product ID that you get from Play Console
var new_skin_sku = "new_player_skin"
# ☝️ sku stands for "Stock Keeping Unit". This is an old naming scheme which Godot still uses.
# Google have changed it to using products.
# 👇 New skin token
var new_skin_token = ""


func _ready() -> void:
	# 👇 The GodotGooglePlayBilling PlugIn is a singleton
	# 👇 So we check if it is there or not
	if Engine.has_singleton("GodotGooglePlayBilling"):
		# 👇 Stores the name of global singleton that is returned.
		google_payment = Engine.get_singleton("GodotGooglePlayBilling")
		# google_payment.purchase("")
		MyUtility.add_log_msg("Android IAP support is enabled.")
		
		# 👇 Emitted after we receive a response from google
		google_payment.connected.connect(_on_connected)
		# 👇 Emitted in case if there is a connection error
		google_payment.connect_error.connect(_on_connect_error)
		# 👇 Emitted in case if connection is disconnected
		google_payment.disconnected.connect(_on_disconnected)
		# 👇 To make a call across the internet, we create this signal for success case
		google_payment.sku_details_query_completed.connect(_on_sku_details_query_completed)
		# 👇 To make a call across the internet, we create this signal for failure case
		google_payment.sku_details_querry_error.connect(_on_sku_details_query_error)
		
		google_payment.purchases_updated.connect(_on_purchases_updated)
		google_payment.purchases_error.connect(_on_purchase_error)
		# 👇 Creating signal to make a call to google to acknowledge the purchase
		google_payment.purchase_acknowledged.connect(_on_purchase_acknowledged) # 👈 Purchase token (string)
		# 👇 Creating signal to hande any error encountered during purchase acknowledgement
		google_payment.purchase_acknowledgement_error.connect(_on_purchase_acknowledgement_error)
		# 👇 Creating signal to hande request the list of purchases from google
		google_payment.query_purchases_response.connect(_on_query_purchases_response)
		# 👇 FOR TESTING ONLY, to get rid of the purchase that we made in the past
		google_payment.payment.purchase_consumed.connect(_on_purchase_consumed)
		# 👇 FOR TESTING ONLY, to catch any error
		google_payment.payment.purchase_consumption_error.connect(_on_purchase_consumption_error)
		# 👇 Signal to start connection of app to google cloud service
		# 👇 Starts connection between us and google play.
		google_payment.startConnection()
	else:
		MyUtility.add_log_msg("Android IAP support is not available.")

func purchase_skin():
	if google_payment:
		var response = google_payment.purchase(new_skin_sku)
		MyUtility.add_log_msg("Purchase attempted, response " + str(response.status))
		# 👇 This is the local response status whether☝️above function call succeded OR not.
		if response.status != OK:
			MyUtility.add_log_msg("Error purchasing skin!")

# 👇 FOR TESTING ONLY
func reset_purchases():
	if google_payment:
		if !new_skin_token.is_empty():
			# 👇 It takes in the "new_skin_token" and it gets rid of the purchase that we made in the past.
			# 👇 So that we can buy again for testing and see if it can be bought again and test other end cases.
			# 👇 Make a call to google and tell that we want to consume this in-app product. We don't want to have it anymore.
			google_payment.consumePurchase(new_skin_token)
			# ☝️ And Google is gonna do that inside their servers and send a response. For which we will create signals above.

func _on_connected():
	MyUtility.add_log_msg("Connected")
	# 👇 Takes 2 input fields: [an array of strings], "string"
	# 👉 Two types of SKUs in google: 1. In app-purchase or in-app products, 2. Subscription
	# 👉 Because you can have more than one products to sell, just add sku name in the array: [sku1, sku2]
	# 👇 This will make a call across the internet to google to ask details about "new_skin_sku".
	# 👇 For which we will make 2 signals in the ready() function
	google_payment.querrySkuDetails([new_skin_sku], "inapp") # 👈 For subscription, it will use string "subs"

##### 👇👇👇 Always Look at the documentation to see what kind of arguements they accept 👇👇👇

func _on_connect_error(response_id, debug_msg):
	MyUtility.add_log_msg("Connect error, response id: " + str(response_id) + " debug msg: " + debug_msg)

func _on_disconnected():
	MyUtility.add_log_msg("Disconnected")
# 👇 Ask google at the start of the game about the previous
# 👇 purchases we made.
func _on_sku_details_query_completed(skus):
	MyUtility.add_log_msg("Sku details query completed")
	# 👇 Since there can be multiple products, we create a loop
	for sku in skus:
		MyUtility.add_log_msg("Sku:")
		MyUtility.add_log_msg(str(sku))
		# ☝️ Each one of these SKUs that we have in the array are going to be a dictionary
		# ☝️ and it is going to contain information about the in-app product.
	# 👇 "querryPurchases" is going to ask google what are the purchases 
	# 👇 that have been made? Googlw will share a list of all the prchases that have been made.
	google_payment.querryPurchases("inapp")

func _on_sku_details_query_error(response_id, error_message, skus):
	MyUtility.add_log_msg("Sku querry error, response id: " + str(response_id) + 
	", message: " + str(error_message) + ", skus: " + str(skus))

func _on_purchases_updated(purchases):
	# ☝️ For now, this array contains a single item that can be purchased. Hence, no need of "for" loop.
	# 👉 In case you are expecting multiple purchases, you should definitely create a loop for these.
	if purchases.size() > 0: # 👈 Checking the size of the array to know if there is an item present OR not
		var purchase = purchases[0]
		#  This ☝ ️is a dictionary.It will contain information that has to do with the purchases.
		var purchase_sku = purchase["skus"][0] # 👈 The "skus" here is an array filled with "skus".
		# ☝️This here should be equal to var new_skin_sku. We try to get its first element.
		# ☝️️We need to check if it is equal to the one we have or not.
		# ☝️If you have multiple in-app products, you should definitely check this.
		MyUtility.add_log_msg("Purchased item with sku: " + purchase_sku)
		if purchase_sku == new_skin_sku:
			new_skin_token = purchase.purchase_token # 👈 This token is generated by google and it signifies all purchase. It represents the purchase. It is unique to us.
			# 👇 Now we need to acknowledge the purchase. If we don't, google will refund player's money
			google_payment.acknowledgePurchase(purchase.purchase_token)
		
func _on_purchase_error(response_id, error_message):
	MyUtility.add_log_msg("Purchase error, response id: " 
	+ str(response_id) + " error msg: " + error_message)

func _on_purchase_acknowledged(purchase_token):
	MyUtility.add_log_msg("Purchase acknowledged successfully!")
	# 👇 Works in this case because there is only single in-app product
	if !new_skin_token.is_empty():
		# 👇 new_skin_token stored in line 100 == purchase_token sent by google
		if new_skin_token == purchase_token:
			MyUtility.add_log_msg("Unlocking new skin.")
			# 👇 Called when item is purchased for the first time
			unlock_new_skin.emit()
		# 👉 If there are more than one product purchases, 
		# 👉 you will create similar "if" cases for them as above☝️

func _on_purchase_acknowledgement_error(response_id, error_message, purchase_token):
	MyUtility.add_log_msg("Purchase acknowledgement error, response id: " + str(response_id) + 
	", message: " + str(error_message) + ", token: " + str(purchase_token))

func _on_query_purchases_response(querry_result):# 👈 "querry_result" should have an array of dictionar. It itself is not an array of dictionary.
	# 👇 The querry_result will have a status.This will be checked first.
	if querry_result.status == OK:
		MyUtility.add_log_msg("QUerry purchases was successful.")
		# 👇 Proceeding to get the array of dictionary from this result
		var purchases = querry_result.purchases 
		# ☝️ "purchases" is an array filled with dictionaries that have 
		# ☝️ information about each purchase we made.
		MyUtility.add_log_msg("purchases") # 👈 Printing it to just ahve a look at it.
		var purchase = purchases[0]
		# ☝️ this will have a key called "skus". 
		var purchase_sku = purchase["skus"][0] # 👈 purchase dictionar is going to be the same
		if new_skin_sku == purchase_sku:
			# 👇 Getting token outside of the ourchase and saving it here
			new_skin_token = purchase.purchase_token
			# 👇 We are going to check if this purchase has been acknowledged OR not
			if !purchase.is_acknowledges:
				google_payment.acknowledgePurchase(purchase.purchase_token)
			else:
				unlock_new_skin.emit()
				MyUtility.add_log_msg("Unlocking new skin because it was purchased previously.")
	else:
		MyUtility.add_log_msg("Querry purchases failed")

# 👇 FOR TESTING ONLY
func _on_purchase_consumed(purchase_token):
	MyUtility.add_log_msg("Purchases consumed successfully!")

# 👇 FOR TESTING ONLY
func _on_purchase_consumption_error(response_id, error_message, purchase_token):
	MyUtility.add_log_msg("Purchase consumption acknowledgement error, response id: " + str(response_id) + 
	", message: " + str(error_message) + ", token: " + str(purchase_token))
