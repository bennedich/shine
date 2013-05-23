### ###

class InputHandler extends require('/util').EventEmitter
	'use strict'
	module.exports = this
	
	NOP =
		bindListeners : ->
		unbindListeners : ->
	
	
	_current : NOP
	_previous : NOP
	
	
	bind : (listener) ->
		return if listener is @_current
		@_previous = @_current
		@_current = listener
		@_previous.unbindListeners()
		@_current.bindListeners()
	
	
	unbind : (bindPrevious = true) ->
		if bindPrevious
			@bind @_previous
		else
			@bind NOP



