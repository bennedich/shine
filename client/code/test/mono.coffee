###
Usage
	...
###

EventEmitter = require './EventEmitter'

class Screen
	css :
		boxSizing		: 'content-box'
		border			: '1px solid #444'
		padding			: '4px 6px'
		fontFamily		: '"Droid Sans Mono", "Courier New", Courier, monospace'
		fontSize		: '12px'
		lineHeight		: '13px' # 14px for wide grid
		letterSpacing		: '0px' # 1px for wide grid
		whiteSpace		: 'pre'
		wordWrap		: 'break-word'
		userSelect		: 'none'
		webkitUserSelect	: 'none'
		mozUserSelect		: 'none'
		msUserSelect		: 'none'
	
	constructor : (@selector, @w, @h) ->
		charWidth = parseInt(@css.fontSize) / 1.714 + parseInt(@css.letterSpacing)
		@domElement = document.querySelector @selector
		@domElement.style[prop] = val for prop, val of @css
		@domElement.style.width = "#{ charWidth * @w }px"
		@domElement.addEventListener 'contextmenu', (e) -> e.preventDefault()
		#TODO handle event resize for rescaling buffer and recalcing w/h
	
	render : (buffer) ->
		@domElement.innerHTML = String.fromCharCode.apply null, buffer
		return


class Renderer
	'use strict'
	
	char :
		BREAK : String.fromCharCode '13'
		SPACE : String.fromCharCode '160'
		BLOCK : String.fromCharCode '9608'
	
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
	
	clearBuffer : (char=@char.SPACE) ->
		buffer = @buffer
		i = @size
		c = char.charCodeAt 0
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


class Loop extends EventEmitter
	'use strict'
	
	INTERVAL : 1000 / 60
	
	requestAnimationFrame : (
		window.requestAnimationFrame		or
		window.webkitRequestAnimationFrame	or
		window.mozRequestAnimationFrame		or
		window.msRequestAnimationFrame		or
		window.oRequestAnimationFrame
		).bind window
	
	constructor : ->
		super()
		@callback = null
		@delta = 0
		@timestamp = 0
		@timeBuffer = 0
		@frameIndex = 0
		@fixedFrameIndex = 0
	
	toggle : -> @start() or @stop()
	
	start : ->
		return false if @callback isnt null
		@callback = @requestAnimationFrame
		@callback @_start
		return true
	
	_start : (timestamp) =>
		@timestamp = timestamp
		@callback @_update
		@emit 'started'
		return
	
	stop : ->
		stopping = @callback isnt @_stop
		@callback = @_stop if stopping
		return stopping
	
	_stop : =>
		@callback = null
		@emit 'stopped'
		return
	
	_update : (timestamp) =>
		@frameIndex = @callback @_update
		@delta = timestamp - @timestamp
		@timestamp = timestamp
		@timeBuffer += @delta
		
		while @timeBuffer > @INTERVAL
			@timeBuffer -= @INTERVAL
			++@fixedFrameIndex
			@emit 'fixedUpdate', @fixedFrameIndex
		
		@emit 'update', @frameIndex, @delta
		@emit 'draw'
		return


class Node
	'use strict'
	
	__uid = 0
	
	constructor : (@x=0, @y=0) ->
		@uid = ++__uid
		@parent = null
		@nodes = {}

	add : (node) ->
		unless node.parent is null
			node.parent.remove node
		@nodes[node.uid] = node
		node.parent = this
		return node

	remove : (node) ->
		return null unless @nodes.hasOwnProperty node.uid
		delete @nodes[node.uid]
		node.parent = null
		return node
	
	translate : (x, y) ->
		@x += x
		@y += y
		return
	
	fixedUpdate : (fixedFrameIndex) ->
	update : (frameIndex, deltaTime) ->
	draw : (renderer, camera) ->


class Scene extends Node
	'use strict'
	
	traverseDeep : (callback) ->
		@_traverseDeep callback, @nodes
		return
	
	_traverseDeep : (callback, nodes) ->
		for uid, node of nodes
			callback node
			@_traverseDeep callback, node.nodes
		return


class Camera extends Node
	'use strict'


class Text extends Node
	'use strict'
	
	constructor : (@str='', x, y) ->
		super x, y
	
	draw : (rndr, cam) ->
		rndr.drawText @str, @x-cam.x, @y-cam.y


class Image extends Node
	'use strict'
	
	constructor : (@asciiBitmap, @w, @h) ->
		super()
	
	draw : (rndr, cam) ->
		rndr.drawAscii @asciiBitmap, @w, @h, @x-cam.x, @y-cam.y



module.exports = {Screen, Renderer, Scene, Camera, Loop, Node, Text, Image}


