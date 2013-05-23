### buffer is a Uint16Array
###

'use strict'

css =
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


class Screen
	module.exports = this
	
	constructor : (@selector, @w, @h) ->
		charWidth = parseInt(css.fontSize) / 1.714 + parseInt(css.letterSpacing)
		@domElement = document.querySelector @selector
		@domElement.style[prop] = val for prop, val of css
		@domElement.style.width = "#{ charWidth * @w }px"
		@domElement.addEventListener 'contextmenu', (e) -> e.preventDefault()
		#TODO handle event resize for rescaling buffer and recalcing w/h
	
	render : (buffer) ->
		@domElement.innerHTML = String.fromCharCode.apply null, buffer
		return
