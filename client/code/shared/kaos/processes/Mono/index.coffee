'use strict'
Process = require '../Process'

Screen = require './Screen'
Renderer = require './Renderer'
Node = require './Node'


class Mono extends Process
	module.exports = this
	
	init : ->
		@screen = new Screen '#ascii', 78, 26
		@renderer = new Renderer 78, 26
		
	update : (timestamp) ->
		@renderer.render @screen
		@renderer.clearBuffer()
	
	exit : ->
	
	stdin : (msg, x, y) ->
		@renderer.drawText msg, x, y
