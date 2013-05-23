class Error
	'use strict'
	module.exports = @
	
	constructor : (msg) ->
		err = window.Error msg
		err.name = @constructor.name
		return err
