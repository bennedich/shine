### ###

class Cli extends util.Widget
	'use strict'
	module.exports = this
	
	{Key} = require '/util'
	InputField = require './InputField'
	InputHandler = require './InputHandler'
	OutputHandler = require './OutputHandler'
	
	@TITLE = 'terminal'
	
	_bash : 'shine:/ *$' # domain:location user$ commands -arg0 -arg1 sourcePath targetPath
	
	
	constructor : (@selector) ->
		super
		
		@_container = document.createElement 'pre'
		@_container.classList.add 'cli'
		@_el.lastChild.appendChild @_container
		
		@_selection = window.getSelection()
		#@_bash = BASH
		
		@_output = new OutputHandler()
		@_output.on 'update', @_onOutputUpdate
		@_container.appendChild @_output._el
		@_output.write @_bash
		
		@_input = new InputField()
		#@_input.on 'update', @_onInputUpdate
		@_container.appendChild @_input._el
		
		@_inputHandler = new InputHandler()
		@_inputHandler.bind this
	
	
	bindListeners : ->
		@_container.addEventListener 'mouseup', @_onMouseUp
		@_container.addEventListener 'paste', @_input.onPaste
		@_container.addEventListener 'cut', @_input.onCut
		@_container.addEventListener 'keydown', @_onKeyDown
		@_input._el.contentEditable = true
	
	
	unbindListeners : ->
		@_input._el.contentEditable = false
		@_container.removeEventListener 'keydown', @_onKeyDown
		@_container.removeEventListener 'cut', @_input.onCut
		@_container.removeEventListener 'paste', @_input.onPaste
		@_container.removeEventListener 'mouseup', @_onMouseUp
	
	
	_onOutputUpdate : =>
		# scroll to bottom
		@_container.scrollTop = @_container.scrollHeight
	
	
	_onInputUpdate : (el) =>
		#@_container.appendChild el
	
	
	_onMouseUp : (evt) =>
		#console.log 'mouseup', evt.target
		evt.preventDefault()
		return if @_input.hasSelection()
		switch evt.target
			when @_input._el  then @_input.refreshCaret()
			when @_output._el then @_input.setCaretToStart()
			else @_input.setCaretToEnd()
		@_input.focus true
	
	
	_onKeyDown : (evt) =>
		#console.log 'keydown', evt.keyCode, evt.target
		return if evt.ctrlKey or evt.metaKey
		@_input.focus()
		if evt.keyCode is Key.ENTER
			@_processInput evt
	
	
	_processInput : (evt) ->
		evt.preventDefault()
		commandstr = @_input.read()
		@_output.append @_input.pop()#_el
		@_output.writeln()
		
		unless commandstr
			@_onProceed()
			return
		
		command = shine.createCommand @_inputHandler, @_output, commandstr
		promise = command.execute()
		promise.fin @_onProceed
			
	
	_onProceed : =>
		@_output.write "#{ @_bash }"
		@_container.appendChild @_input._el
		@_input.focus()
	
	
	focus : ->
		@_container.focus()
		@_input.focus()


