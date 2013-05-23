###
Preferably used in conjunction with Key.coffee

Keyboard
if Keyb[ Key.SPACE ]
	do stuff
###
'use strict'

Key = require '/util/key'
EventEmitter = require '/util/EventEmitter'

nonChar = {}
nonChar[key] = true for key in [Key.BACKSPACE, Key.TAB, Key.ENTER,
	Key.SHIFT, Key.CTRL, Key.ALT, Key.PAUSE, Key.CAPS,
	Key.ESC, Key.PG_UP, Key.PG_DOWN, Key.END, Key.HOME,
	Key.LEFT, Key.UP, Key.RIGHT, Key.DOWN, Key.INS,
	Key.DEL, Key.META, Key.R_WIN, Key.R_META, Key.SELECT,
	Key.F1, Key.F2, Key.F3, Key.F4, Key.F5, Key.F6,
	Key.F7, Key.F8, Key.F9, Key.F10, Key.F11, Key.F12,
	Key.NUM, Key.SCROLL]

class Keyboard extends EventEmitter
	constructor : ->
		super()
		@keypress = @keypress.bind @
		@keydown = @keydown.bind @
		@keyup = @keyup.bind @
		window.addEventListener 'keypress', @keypress
		window.addEventListener 'keydown', @keydown
		window.addEventListener 'keyup', @keyup
	
	keypress : (evt) ->
		@emit 'char', evt.charCode
	
	keydown : (evt) ->
		@[evt.keyCode] = true
		return unless nonChar[evt.keyCode]
		evt.preventDefault()
		@emit 'key', evt.keyCode
	
	keyup : (evt) ->
		@[evt.keyCode] = false

# global instance of Keyboard
module.exports = new Keyboard
