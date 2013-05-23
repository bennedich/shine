'use strict'
Process = require './Process'


class WebSocket extends Process
	module.exports = this
	
	init : ->
		console.log @options.parent
	
	update : (timestamp) ->
		
	stdin : ->
		console.log 'WS!'
	exit : ->
