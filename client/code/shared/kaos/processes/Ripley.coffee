### Read-Ingest-Print-Loop eeeh...yawn
###
'use strict'
Process = require './Process'
Key = require '../io/key'
Node = require './Mono/Node'

char =
	EMPTY : String.fromCharCode 0
	ENTER : String.fromCharCode 13
	SPACE : String.fromCharCode 160
	BLOCK : String.fromCharCode 9608


class Ripley extends Process
	module.exports = this
	
	init : ->
		@x = 0
		@y = 0
		
		@domain = 'local'
		@location = '/'
		@user = '*'
		
		@input = ''
		@previousInput = ''
		
		@cursor = char.BLOCK
		@cursorX = 0
		@cursorY = 0
		
		@blinkOffset = 0
		@blinkInterval = 60
		@blinkIntervalHidden = 30
		
		@ffi = 0
		@fi = 0
		
		@history = []
		@prompt = ''
		@promptDirty = false
		@updatePrompt()
	
	exit : ->
	
	stdin : (payload) ->
		@onChar payload if payload.charBufferN > 0
		@onKey payload if payload.keyBufferN > 0
	
	onChar : (payload) ->
		n = payload.charBufferN
		@resetCursorBlink()
		chr = String.fromCharCode.apply(null, payload.charBuffer).substr 0, n
		@input = @insert @input, chr, @cursorX
		@cursorX += n
	
	onKey : (payload) ->
		n = payload.keyBufferN
		@resetCursorBlink()
		for i in [0...n] by 1
			switch payload.keyBuffer[i]
				when Key.LEFT
					--@cursorX if @cursorX > 0
				when Key.RIGHT
					++@cursorX if @cursorX < @input.length
				when Key.UP, Key.DOWN
					input = @input
					@input = @previousInput
					@previousInput = input
					@cursorX = @input.length
				when Key.BACKSPACE
					break if @cursorX < 1
					@input = @remove @input, @cursorX-1
					--@cursorX
				when Key.DEL
					break if @cursorX > @input.length-1
					@input = @remove @input, @cursorX
				when Key.ENTER
					#console.log @pid, 'Ripley', 'EVAL', @input
					@kaos.enqueueCommand @input, @
					@cursorX -= @input.length
					@previousInput = @input
					@cursorY += 1
					@history.push "#{ @prompt }#{ @input }"
					@input = ''
		return
	
	update : (timestamp) ->
		++@fi
		
		@updatePrompt() if @promptDirty
		
		blinkPosition = @fi + @blinkOffset
		if blinkPosition % @blinkInterval < @blinkIntervalHidden
			@cursor = char.BLOCK
		else 
			@cursor = char.EMPTY
		
		if @cursor and @input
			input = @replace @input, @cursor, @cursorX
			str = "#{ @prompt }#{ input }"
		else if @cursor
			str = "#{ @prompt }#{ @cursor }"
		else if @input
			str = "#{ @prompt }#{ @input }"
		else
			str = @prompt
		
		for node, i in @history
			@stdout node, 0, i
		
		@stdout str, 0, @cursorY
		
	
	# custom methods
	
	resetCursorBlink : ->
		@cursor = char.BLOCK
		@blinkOffset = -@fi # TODO should be @ffi
	
	insert : (str, chr, pos) ->
		return "#{ str.substr 0,pos }#{ chr }#{ str.substr pos }"
	
	replace : (str, chr, pos) ->
		return "#{ str.substr 0,pos }#{ chr }#{ str.substr pos+1 }"
	
	remove : (str, pos) ->
		return "#{ str.substr 0,pos }#{ str.substr pos+1 }"
	
	updatePrompt : ->
		@prompt = "#{ @domain }:#{ @location } #{ @user }$ "





