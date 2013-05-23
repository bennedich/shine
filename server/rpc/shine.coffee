
exports.actions = (req, res, ss) ->
	
	req.use 'session'
	req.use 'auth.authenticated'
	
	echo : (message) ->
		res message
		
		###
		if message && message.length > 0
			#ss.publish.all('newMessage', message)	# Broadcast the message to everyone
		###

