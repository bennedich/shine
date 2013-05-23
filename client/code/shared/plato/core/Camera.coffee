'use strict'
{mat4} = require '/gl-matrix'
Unit3D = require './Unit3D'
{RIGHT_X, UP_X, FORWARD_X, POS_X, POS_Y, POS_Z} = require '../auxiliary/unitAux'

log = console.log.bind console, '[cam]'

class Camera extends Unit3D
	module.exports = @
	
	constructor : (@fovy, @aspect, @near, @far) ->
		super()
		@view = mat4.create()
		@perspective = mat4.create()
		@refreshView()
		@refreshPerspective()
	
	refreshView : ->
		mat4.invert @view, @matrix
	
	refreshPerspective : ->
		mat4.perspective @perspective, @fovy, @aspect, @near, @far
	
	setAspectRatio : (aspect) ->
		log 'aspect updated'
		@aspect = aspect
		@refreshPerspective()
	
	fixedUpdate : (ffi) ->
		#@matrix[POS_Z] = 1.2 - Math.abs(ffi%60 - 30)/30
	
	update : (fi, dt) ->
		@refreshView()
