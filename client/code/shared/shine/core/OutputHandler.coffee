### ###

class OutputHandler extends require('/util').EventEmitter
	'use strict'
	module.exports = this
	
	
	constructor : ->
		super()
		@_el = document.createElement 'span'
	
	
	enterFullscreen : ->
		@_el.parentElement.webkitRequestFullscreen()
	
	
	exitFullscreen : ->
		document.webkitCancelFullScreen()
	
	
	toggleFullscreen : ->
		if document.webkitIsFullScreen then @exitFullscreen() else @enterFullscreen()
	
	
	clear : ->
		@_el.innerHTML = ''
	
	
	write : (str) ->
		@append document.createTextNode str
	
	
	writeln : (str) ->
		@write "#{ str ? '' }\n"
	
	
	append : (node) ->
		@_el.appendChild node
		@emit 'update'



