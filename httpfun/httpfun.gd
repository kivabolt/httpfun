extends Node

var username=""
var best_score=0;
var elapsed=0;
var fields="";

func _ready():
	# GET ONLY GAME_STATE'S CURRENT SCORE (after game is played, NOT HIGHSCORE + TIME SAVED TO FILE)
	best_score = get_node("/root/game_state").mail_score
	elapsed = get_node("/root/game_state").user_time_completed
	var minutes = int(elapsed) / 60
	var seconds = int(elapsed) % 60
	#calculate milliseconds and multiply by 1000 for display
	var milliseconds = elapsed - int(elapsed)
	var milliseconds_display = milliseconds * 10
	
	var str_elapsed = "%01dm %02d.%01ds" % [minutes, seconds, milliseconds_display]
	get_node("hud/score").set_text("Stuff Collected: " + str(best_score))
	get_node("hud/time").set_text("Time: " + str_elapsed)
	
	#hiding upload messages
	get_node("hud/uploadStatus").set_opacity(0)
	
	print("Starting GET REQUEST")
	getRequest()
	pass

func getRequest():
	var err=0
	var http = HTTPClient.new() # Create the Client
	
	# Connect to host/port
	var err=http.connect("http://meehak.com",80)
	assert(err==OK) # Make sure connection was OK
	
	# Wait until resolved and connected
	while( http.get_status()==HTTPClient.STATUS_CONNECTING or http.get_status()==HTTPClient.STATUS_RESOLVING):
		http.poll()
		print("Connecting..")
		OS.delay_msec(500)
	
	assert( http.get_status() == HTTPClient.STATUS_CONNECTED ) # Could not connect
	
	# Some headers
	var headers=["User-Agent: Pirulo/1.0 (Godot)","Accept: */*"]


	var url="/squared.php"
	#var HEADERS = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(fields.length())]
	#err = http.request(HTTPClient.METHOD_GET, url, headers)
	err = http.request(HTTPClient.METHOD_GET, url, headers)
	
	
	assert( err == OK ) # Make sure all is OK
	
	while (http.get_status() == HTTPClient.STATUS_REQUESTING):
	  # Keep polling until the request is going on
		http.poll()
		print("Requesting..")
		OS.delay_msec(500)
	
	assert( http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED ) # Make sure request finished well.
	
	print("response? ",http.has_response()) # Site might not have a response.
	
	if (http.has_response()):
	# If there is a response..
		var headers = http.get_response_headers_as_dictionary() # Get response headers
		print("code: ",http.get_response_code()) # Show response code
		print("**headers:\\n",headers) # Show headers
	
	# Getting the HTTP Body
	if (http.is_response_chunked()):
	# Does it use chunks?
		print("Response is Chunked!")
	else:
	# Or just plain Content-Length
		var bl = http.get_response_body_length()
		print("Response Length: ",bl)
	
	  # This method works for both anyway
	
	var rb = RawArray() # Array that will hold the data
	
	while(http.get_status()==HTTPClient.STATUS_BODY):
	# While there is body left to be read
		http.poll()
		var chunk = http.read_response_body_chunk() # Get a chunk
		if (chunk.size()==0):
		# Got nothing, wait for buffers to fill a bit
			OS.delay_usec(1000)
		else:
			rb = rb + chunk # Append to read buffer
	  # Done!
	print("bytes got: ",rb.size())
	var text = rb.get_string_from_ascii()
	print("********DATA ACQUIRED : ",text)
	#get_node("hud/uploadStatus").set_text("Upload Complete! Thanks for Playing! ")


func createStringFields():
	fields ="username=" + username + "&highscore=" + str(best_score) + "&gametime=" + str(elapsed)
	print("Creating FIELDS string")
	print(fields)
	fields = ""
	print("Trying to connect ")


func uploadScore():
	print("Starting POST request")
	# create the string fields to be sent
	createStringFields()
	var err=0
	var http = HTTPClient.new() # Create the Client
	
	var err = http.connect("www.meehak.com",80) # Connect to host/port
	assert(err==OK) # Make sure connection was OK
	
	# Wait until resolved and connected
	while( http.get_status()==HTTPClient.STATUS_CONNECTING or http.get_status()==HTTPClient.STATUS_RESOLVING):
		http.poll()
		print("Connecting..")
		OS.delay_msec(500)
	
	assert( http.get_status() == HTTPClient.STATUS_CONNECTED ) # Could not connect
	
	#query_string_from_dict not working for some reason
	#err = http.request(HTTPClient.METHOD_GET,"/ChangeLog-5.php",headers) # Request a page from the site (this one was chunked..)
	#var fields = {"varname" : "5"}
	#var queryString = HTTPClient.query_string_from_dict(fields)
	
	var url="/uploadUserResult.php"
	var HEADERS = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(fields.length())]
	var err = http.request(HTTPClient.METHOD_POST, url, HEADERS, fields)

	assert( err == OK ) # Make sure all is OK
	
	while (http.get_status() == HTTPClient.STATUS_REQUESTING):
	  # Keep polling until the request is going on
		http.poll()
		print("Requesting..")
		OS.delay_msec(500)
	
	assert( http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED ) # Make sure request finished well.
	
	print("response? ",http.has_response()) # Site might not have a response.
	
	if (http.has_response()):
	# If there is a response..
		var headers = http.get_response_headers_as_dictionary() # Get response headers
		print("code: ",http.get_response_code()) # Show response code
		print("**headers:\\n",headers) # Show headers
	
	# Getting the HTTP Body
	if (http.is_response_chunked()):
	# Does it use chunks?
		print("Response is Chunked!")
	else:
	# Or just plain Content-Length
		var bl = http.get_response_body_length()
		print("Response Length: ",bl)
	
	  # This method works for both anyway
	
	var rb = RawArray() # Array that will hold the data
	
	while(http.get_status()==HTTPClient.STATUS_BODY):
	# While there is body left to be read
		http.poll()
		var chunk = http.read_response_body_chunk() # Get a chunk
		if (chunk.size()==0):
		# Got nothing, wait for buffers to fill a bit
			OS.delay_usec(1000)
		else:
			rb = rb + chunk # Append to read buffer
	  # Done!
	print("bytes got: ",rb.size())
	
	var text = rb.get_string_from_ascii()
	print("********DATA ACQUIRED: ",text)
	get_node("hud/upload_animation").play("upload_successful")
	



func _on_usernameConfirm_pressed():
	username=get_node("hud/username_label/usernameInput").get_text()
	print("Saving username " + username)
	# animation to hide username_label+children then display upload Status
	get_node("hud/upload_animation").play("username_entered")
	# Hide username input, show upload/connect button
	"""
	get_node("hud/username_label").set_opacity(0)
	get_node("hud/usernameInput").set_opacity(0)
	get_node("hud/usernameConfirm").set_opacity(0)
	"""
	print("Upload pressed")
	#show uploadStatus message
	get_node("hud/uploadStatus").set_opacity(1)

	##### timeout to allow uploadStatus to show #####
	var t = Timer.new()
	t.set_wait_time(2)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	
	## upload the score
	uploadScore()
	
	pass # replace with function body

func _on_get_pressed():
	getRequest()

