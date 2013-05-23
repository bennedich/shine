### ###

class Nop extends require './Command'
	'use strict'
	module.exports = this
	
	_onExecute : ->
		@_output.writeln 'command not found'
