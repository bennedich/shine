'use strict'
createShader = require './createShader'
{WHITE,BLACK} = require '../auxiliary/colorAux'

log = console.log.bind console, '[rndr]'


class Renderer
	module.exports = @
	
	constructor : (@selector) ->
		@onCanvasResize = @onCanvasResize.bind @
		@initDom()
		@initGL()
	
	initDom : ->
		@cvs = document.querySelector @selector
		#@cvs.style.backgroundColor = '#000'
		@gl = @cvs.getContext 'experimental-webgl'
		@onCanvasResize()
		window.addEventListener 'resize', @onCanvasResize
	
	initGL : ->
		gl = @gl
		gl.clearColor.apply gl, WHITE
		gl.colorMask true,true,true,true
		gl.clearColor 0,0,0,0
		gl.clearDepth 1
		
		# culling
		gl.enable gl.CULL_FACE
		gl.cullFace gl.BACK
		gl.frontFace gl.CCW

		# depth
		gl.enable gl.DEPTH_TEST
		gl.depthFunc gl.LEQUAL #gl.LESS gl.GREATER
		gl.depthMask true

		# fragment blending
		gl.enable gl.BLEND
		gl.blendFunc gl.SRC_ALPHA, gl.ONE_MINUS_SOURCE_ALPHA

		# texture
		gl.pixelStorei gl.UNPACK_FLIP_Y_WEBGL, true
		
		log 'vendor:', gl.getParameter gl.VENDOR
		log 'renderer:', gl.getParameter gl.RENDERER
		log 'version:', gl.getParameter gl.VERSION
		log 'GLSL version:', gl.getParameter gl.SHADING_LANGUAGE_VERSION
	
	setSize : ->
		@w = @cvs.width = @cvs.parentElement.clientWidth # TODO clientWidth ?? clientRect ??
		@h = @cvs.height = @cvs.parentElement.clientHeight
	
	onCanvasResize : ->
		log 'resize'
		@setSize()
		@aspect = @w / @h
		@w2 = @w / 2
		@h2 = @h / 2
		@gl.viewport 0, 0, @w, @h
		@canvasResized = true
	
	setShader : (shaderHandle) ->
		@shader = createShader @gl, shaderHandle # TODO shader uids should be stored in objects to be drawn and actually created by the renderer when needed
		@gl.useProgram @shader.program
		return @shader
	
	preRender : (cam) ->
		# TODO
		@cam = cam
		@gl.clear @gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT
		return
	
	postRender : ->
		# TODO
		if @canvasResized
			@canvasResized = false
			@cam.setAspectRatio @aspect
		return	



