class Widget
	'use strict'
	module.exports = this
	
	@TITLE = 'widget'
	
	
	constructor : (@selector) ->
		@_el = document.querySelector @selector
		@_el.innerHTML = ss.tmpl['widget-main'].render title:@constructor.TITLE
		
		@_header = @_el.firstChild
		@_body = @_el.lastChild
		
		@_fullHeight = parseInt getComputedStyle(@_el).height, 10
		@_headerHeight = parseInt getComputedStyle(@_header).height, 10
		@_bodyHeight = @_fullHeight - @_headerHeight
		@_body.style.height = "#{ @_bodyHeight }px"
		
		#@_el.draggable = true
		#@_el.addEventListener 'dragstart', @ondragstart
		#@_el.addEventListener 'dragend', @ondragend
		#@_el.addEventListener 'dragover', @ondrag
		#@_el.addEventListener 'drop', @ondrop
		
		@_header.addEventListener 'mousedown', @_ondragstart
		@_offsetX = 0
		@_offsetY = 0
		
		@onresize()
	
	
	_ondragstart : (evt) =>
		evt.preventDefault()
		#console.log 'start'
		r = @_el.getBoundingClientRect()
		@_offsetX = evt.clientX - r.left
		@_offsetY = evt.clientY - r.top
		window.addEventListener 'mouseup', @_ondragend
		window.addEventListener 'mousemove', @_ondrag
	
	
	_ondrag : (evt) =>
		#console.log 'drag'
		@_el.style.left = "#{ evt.clientX - @_offsetX + 150 }px"
		@_el.style.top = "#{ evt.clientY - @_offsetY + 100 }px"
	
	
	_ondragend : (evt) =>
		#console.log 'end'
		window.removeEventListener 'mousemove', @_ondrag
		window.removeEventListener 'mouseup', @_ondragend
	
	
	###
	ondragstart : (evt) =>
		unless @_dragging
			evt.preventDefault()
		console.log 'dragstart'#, evt
		#document.addEventListener 'mouseup', @ondragend
	
	ondragend : (evt) =>
		console.log 'dragend'
	
	ondrop : (evt) =>
		console.log 'drop'
	
	ondragover : (evt) =>
		console.log 'dragend'
	###	
	
	
	onresize : (evt) ->
		@_el.style.marginTop = "-#{ parseInt(@_el.style.height, 10) / 2 }px"
		@_el.style.marginLeft = "-#{ parseInt(@_el.style.width, 10) / 2 }px"

