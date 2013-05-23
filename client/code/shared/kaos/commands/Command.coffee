### a command builds the state of the process it fires	
###
'use strict'

class Command
	module.exports = this
	
	constructor : (@kaos, @parent, @options) ->
		#TODO build settings from options
	execute : ->
