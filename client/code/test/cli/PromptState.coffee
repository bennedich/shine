State = require '/kaos/State'
Keyboard = require '/kaos/Keyboard'
Key = require '/kaos/Key'
Command = require './Command'


class UnknownCommand extends Command
	'use strict'
	onExecute : ->
		console.log 'UNKNOWN!!'

commands = {UnknownCommand}




class PromptState extends State
	'use strict'
	module.exports = this
	
	char :
		EMPTY : ''
		SPACE : String.fromCharCode '160'
		BLOCK : String.fromCharCode '9608'
	
	constructor : ->
		@processes = []
	
	enter : (@menuSM) ->
		@x = 0
		@y = 0
		@domain = 'local'
		@location = '/'
		@user = '*'
		@updatePrompt()
		@input = ''
		@cursor = @char.BLOCK
		@cursorX = 0
		@cursorY = 0
		@blinkSpeed = 30
		@blinkOffset = 0
		@ffi = 0
		Keyboard.on 'char', @onChar
		Keyboard.on 'key', @onKey
	
	leave : ->
		Keyboard.off 'char', @onChar
		Keyboard.off 'key', @onKey
	
	
	onChar : (char, charCode) =>
		@_resetCursorBlink()
		@input = @_insert @input, char, @cursorX
		++@cursorX
	
	onKey : (key) =>
		@_resetCursorBlink()
		switch key
			when Key.LEFT
				--@cursorX if @cursorX > 0
			when Key.RIGHT
				++@cursorX if @cursorX < @input.length
			when Key.UP then
			when Key.DOWN then
			when Key.BACKSPACE
				break if @cursorX < 1
				@input = @_remove @input, @cursorX-1
				--@cursorX
			when Key.DEL
				break if @cursorX > @input.length-1
				@input = @_remove @input, @cursorX
			when Key.ENTER then @evaluate()
				
					
	evaluate : ->
		@lockInput()
		command = @createCommand()
		process = command.execute()
		@processes.push process
		if process.is_locking
			process.promise.fin @onProceed
		else
			@onProceed()
	
	onProceed : =>
		@unlockInput()
	
	createCommand : ->
		unless @input.length
			return new UnknownCommand
		payload = @input.split /\s/
		keyword = payload.shift()
		unless keyword of commands
			return new UnknownCommand
		Command = commands[keyword]
		return new Command @rndr
	
	unlockInput : ->
		@is_locked = false
		Keyboard.on 'char', @onChar
		Keyboard.on 'key', @onKey
	
	lockInput : ->
		@is_locked = true
		Keyboard.off 'char', @onChar
		Keyboard.off 'key', @onKey
	
	_resetCursorBlink : ->
		@cursor = @char.BLOCK
		@blinkOffset = -@ffi
	
	_insert : (str, char, pos) ->
		return "#{ str.substr 0,pos }#{ char }#{ str.substr pos }"
	
	_replace : (str, char, pos) ->
		return "#{ str.substr 0,pos }#{ char }#{ str.substr pos+1 }"
	
	_remove : (str, pos) ->
		return "#{ str.substr 0,pos }#{ str.substr pos+1 }"
	
	fixedUpdate : (ffi) ->
		@ffi = ffi
		for process in @processes
			process.fixedUpdate(ffi)
		blinkPosition = @ffi + @blinkOffset
		return if blinkPosition % @blinkSpeed
		@cursor = if @cursor then @char.EMPTY else @char.BLOCK
	
	update : (fi, dt) ->
		for process, i in @processes
			if process.is_alive
				process.update fi, dt
			else
				@processes.splice i, 1
		return if @is_locked
		@updatePrompt()
		if @cursor and @input
			x = @cursorX
			input = @input.substr(0, x) + @cursor + @input.substr(x+1)
			@str = "#{ @prompt }#{ input }"
		else if @cursor
			@str = "#{ @prompt }#{ @cursor }"
		else if @input
			@str = "#{ @prompt }#{ @input }"
		else
			@str = @prompt
	
	updatePrompt : ->
		@prompt = "#{ @domain }:#{ @location } #{ @user }$ "
	
	draw : (rndr, cam) ->
		for process in @processes
			continue if process.is_hidden
			process.draw rndr, cam
		rndr.drawText @str, @x-cam.x, @y-cam.y

