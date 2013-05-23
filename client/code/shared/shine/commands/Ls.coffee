### ###

class Ls extends require './Command'
	'use strict'
	module.exports = this
	
	@help : 'helptext'
	
	_onExecute : ->
		@_output.writeln 'LS LSL LS'
