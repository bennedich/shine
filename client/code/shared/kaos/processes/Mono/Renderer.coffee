### buffer is a Uint16Array
###

'use strict'

char = 
	ENTER : String.fromCharCode 13
	SPACE : String.fromCharCode 160
	BLOCK : String.fromCharCode 9608


class Renderer
	module.exports = this
	
	constructor : (@w, @h) ->
		@_wideGrid = false
		@size = @w * @h
		@buffer = new Uint16Array @size
		@clearBuffer()
		#cursor data
		@x = 0
		@y = 0
	
	#_cursor_offset : ->
	#	return @w * @y + @x
	
	clearBuffer : (chr=char.SPACE) ->
		buffer = @buffer
		i = @size
		c = chr.charCodeAt 0
		buffer[i] = c while i--
		return
	
	drawBuffer : (buffer, x, y) ->
		# TODO
	###
	drawAscii : (str, w, h, x, y) ->
		buffer = @buffer
		_w = @w
		_h = @h
		
		return if x > _w
		return if x < -w
		return if y >= _h
		return if y <= -h
		
		i = 0
		s = w * h
		off_x = x
		off_y = y * _w
		
		for i in [0...s] by 1
			off_x = x + i - off_y
		
		for _y in [0...h] by 1
			continue unless 0 <= (y + _y) < _h
			continue if 
			off_y = (y + _y) * _w
			for _x in [0...w] by 1
				off_x = x + _x
				continue unless 0 < off_x <= _w
				buffer[off_x + off_y] = str.charCodeAt i
				++i
			++i
		return
	###
	drawText : (str, x, y) ->
		w = str.length
		h = 1
		_w = @w
		_h = @h
		return if x > _w
		return if x < -w
		return if y >= _h
		return if y <= -h
		buffer = @buffer
		off_i = x + y * _w
		for i in [0...str.length] by 1
			++x
			continue if x <= 0
			break if x > _w
			buffer[off_i + i] = str.charCodeAt i
		return
	###
	drawText : (str, x, y) ->
		buffer = @buffer
		_w = @w
		_h = @h
		return unless 0 <= y < _h
		off_y = y * _w
		for i in [0...str.length] by 1
			off_x = x + i
			continue unless 0 <= off_x < _w
			buffer[off_x + off_y] = str.charCodeAt i
		return
	###
	render : (screen) ->
		screen.render @buffer
