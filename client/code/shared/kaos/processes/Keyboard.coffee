'use strict'
Process = require './Process'

BUFFER_SIZE = 4


class Keyboard extends Process
	module.exports = this
	
	init : ->
		@onChar = @onChar.bind @
		@onKey = @onKey.bind @
		
		@charBuffer = new Uint16Array BUFFER_SIZE
		@keyBuffer = new Uint16Array BUFFER_SIZE
		
		@payload =
			charBuffer : @charBuffer
			keyBuffer : @keyBuffer
			charBufferN : 0
			keyBufferN : 0
		
		@kaos.keyboard.on 'char', @onChar
		@kaos.keyboard.on 'key', @onKey
	
	onChar : (charCode) ->
		if @payload.charBufferN >= BUFFER_SIZE
			console.warn @pid, 'Keyb', 'char buffer overflow'
			return
		@charBuffer[@payload.charBufferN] = charCode
		++@payload.charBufferN
	
	onKey : (keyCode) ->
		if @payload.keyBufferN >= BUFFER_SIZE
			console.warn @pid, 'Keyb', 'key buffer overflow'
			return
		@keyBuffer[@payload.keyBufferN] = keyCode
		++@payload.keyBufferN
	
	update : (timestamp) ->
		@stdout @payload
		@payload.charBufferN = 0
		@payload.keyBufferN = 0
	
	exit : ->
