### ###

class Clear extends require './Command'
	'use strict'
	module.exports = this
	
	@help : 'helptext'
	
	_onExecute : ->
		@_output.clear()



