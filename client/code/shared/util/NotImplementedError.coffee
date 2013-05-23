class NotImplementedError extends require './Error'
	'use strict'
	module.exports = @

	constructor : ->
		return super 'Not implemented. Trying to invoke a function not yet implemented.'
