'use strict'
Process = require './Process'

class Boot extends Process
	module.exports = this
	
	init : ->
		keyb = @kaos.spawnProcess 'keyboard', {init: true}
		mono = @kaos.spawnProcess 'mono', {init: true}
		ripl = @kaos.spawnProcess 'ripley', {feeder: keyb, feedee: mono, init: true}
		stats = @kaos.spawnProcess 'stats', {init: true}
	
	update : (timestamp) ->
		
	exit : ->
		#destroy all processes
