
exports.actions = (req, res, ss) ->
	
	req.use 'session'
	
	env : ->
		res ss.env
