


class InputField
	'use strict'
	module.exports = this
	
	{Key} = require '/util'
	
	# completely empty nodes cannot be focused so add some ballast payload
	EMPTY_CARET : ' '
	CARET_START : 1 # EMPTY_CARET.length
	
	
	constructor : ->
		@_el = document.createElement 'span'
		@_selection = window.getSelection()
		@_caret = @CARET_START
		@_field = null
		@resetInput()
		
		@_el.addEventListener 'keydown', @_onKeyDown
	
	
	focus : (enforced = false) ->
		#console.log 'focus', @_caret, @_selection.focusNode
		return if @_selection.focusNode is @_field and not enforced
		range = document.createRange()
		range.setStart @_field, @_caret
		range.collapse true
		@_selection.removeAllRanges()
		@_selection.addRange range
		#console.log 'focus', @_caret, @_selection.focusNode
	
	
	read : ->
		return @_field.textContent.substr @CARET_START
	
	
	pop : ->
		field = @_el.firstChild
		@resetInput()
		return field
	
	
	setCaret : (offset) ->
		offset = Math.max @CARET_START, offset
		#console.log 'set caret', offset
		@_caret = offset
	
	
	offsetCaret : (offset) ->
		@_caret += offset
	
	
	setCaretToStart : ->
		#console.log 'setcarettostart'
		@setCaret @CARET_START
	
	
	setCaretToEnd : ->
		@setCaret @_field.textContent.length
	
	
	refreshCaret : ->
		#console.log 'refresh caret', @_selection.focusNode is @_field, @_selection.focusOffset
		return if @_selection.focusNode isnt @_field
		@setCaret @_selection.focusOffset
	
	
	resetInput : ->
		if @_el.firstChild
			@_el.removeChild @_field
		@setCaretToStart()
		@_field = document.createTextNode @EMPTY_CARET
		@_el.appendChild @_field
	
	
	hasSelection : ->
		return true if @_selection.anchorNode isnt @_selection.focusNode
		return true if @_selection.focusOffset - @_selection.anchorOffset isnt 0
		return false
	
	
	onPaste : (evt) =>
		#console.log 'paste', evt
		evt.preventDefault()
		
		return if @_selection.anchorNode isnt @_field
		return if @_selection.focusNode isnt @_field
		return if @_selection.anchorOffset < @CARET_START
		return if @_selection.focusOffset < @CARET_START
		
		unless evt.clipboardData
			console.warn 'no browser support for clipboardData'
			return
		
		clipboardData = evt.clipboardData.getData 'text/plain' # window.clipboardData.getData 'text'
		range = @_selection.getRangeAt 0
		range.deleteContents()
		@refreshCaret()
		@_field.insertData @_caret, clipboardData
		@offsetCaret clipboardData.length
		@focus true
	
	
	onCut : (evt) =>
		#console.log 'cut'
		if @_selection.anchorNode isnt @_field or @_selection.focusNode isnt @_field
			evt.preventDefault()
	
	
	_onKeyDown : (evt) =>
		#console.log 'keydown', evt.keyCode, evt.target
		return if evt.ctrlKey or evt.metaKey
		@refreshCaret()
		switch evt.keyCode
			when Key.UP        then @_previousInput evt
			when Key.DOWN      then @_nextInput evt
			when Key.LEFT      then @_stopCaretMoveLeft evt
			when Key.BACKSPACE then @_stopCaretMoveLeft evt
	
	
	_previousInput : (evt) ->
		evt.preventDefault()


	_nextInput : (evt) ->
		evt.preventDefault()


	_stopCaretMoveLeft : (evt) ->
		evt.preventDefault() if @_caret is @CARET_START





