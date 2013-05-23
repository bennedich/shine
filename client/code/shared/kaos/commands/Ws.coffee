'use strict'
Command = require './Command'

class Ws extends Command
	module.exports = this
	
	execute : ->
		# TODO möp! stdin/out funkar inte, måste ha tillgång till själva instanserna, inte bara metoderna
		@kaos.spawnProcess 'websocket',
			init: true,
			parent: @parent,
			feeder: @parent.stdout,
			feedee: @parent.stdin,
