'use strict'
Command = require './Command'

class Help extends Command
	module.exports = this
	
	execute : ->
		#@kaos.spawnProcess 'ripley', @options
		console.log process.pid, process.constructor.name for process in @kaos.processes()
