'use strict'
Command = require './Command'

class Unknown extends Command
	module.exports = this
	
	execute : ->
		console.log 'Unknown'
		#@parent.stdin {charBufferN:3, charBuffer:[83,79,83]}