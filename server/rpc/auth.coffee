
exports.actions = (req, res, ss) ->
	
	req.use 'session'
	
	authenticate : (user, pass) ->
		userid = if user is 'marco' and pass is 'polo' then 1 else 0

		if userid
			req.session.setUserId userid
			res true
		else
			res false
	
	logout : ->
		req.session.setUserId null
		res()
