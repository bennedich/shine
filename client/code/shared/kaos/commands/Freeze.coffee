'use strict'
Command = require './Command'

class Freeze extends Command
	module.exports = this
	
	execute : ->
		@kaos.step.stop()