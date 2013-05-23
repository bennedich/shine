'use strict'
Process = require './Process'

BUFFER_SIZE = 1024


class Keyboard extends Process
	module.exports = this
	
	init : ->
		char_buffer = new Uint16Array BUFFER_SIZE
		key_buffer = new Uint16Array BUFFER_SIZE
		
		char_buffer_n = 0
		key_buffer_n = 0
		
		payload = {char_buffer, key_buffer}
		
		@api.keyboard.on 'char', (charCode) ->
			char_buffer[char_buffer_n] = charCode
			++char_buffer_n
		
		@api.keyboard.on 'key', (keyCode) ->
			key_buffer[key_buffer_n] = keyCode
			++key_buffer_n
		
		@update = (timestamp) ->
			payload.char_buffer_n = char_buffer_n
			payload.key_buffer_n = key_buffer_n
			char_buffer_n = 0
			key_buffer_n = 0
			@stdout payload
	
	exit : ->
		#destroy all processes
