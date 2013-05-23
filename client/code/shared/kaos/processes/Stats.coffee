'use strict'
Process = require './Process'

class Stats extends Process
	module.exports = this
	
	init : ->
		@fi = 0
		@dom = document.querySelector '#fi_bar'
	
	update : (timestamp) ->
		++@fi
		@dom.textContent = @fi
	exit : ->
		
