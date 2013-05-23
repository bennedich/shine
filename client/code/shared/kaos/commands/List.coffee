'use strict'
Command = require './Command'

class List extends Command
	module.exports = this
	
	execute : ->
		switch @options[0]
			when 'commands'
				console.log c for c in @kaos.availableCommands()
			when 'processes'
				console.log p for p in @kaos.availableProcesses()
		#@kaos.spawnProcess 'ripley', @options
		#console.log p.pid, p.constructor.name for p in @kaos.processes()
