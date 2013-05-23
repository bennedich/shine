'use strict'
NotImplementedError = require '/util/NotImplementedError'
{mat4, vec3, quat} = require '/gl-matrix'
{X,Y,Z, X4,Y4,Z4} = require '../auxiliary/unitAux'
Unit = require './Unit'

class Unit3D extends Unit
	module.exports = @

	__right = vec3.create()
	__up = vec3.create()
	__forward = vec3.create()
	
	constructor : ->
		super()
		@matrix = mat4.create()
	
	### rotations ###

	lookAt : (vector3) ->
		#mat4.lookAt @matrix,
		throw new NotImplementedError
	
	rotate : (rad, axis) ->
		mat4.rotate @matrix, @matrix, rad, axis
	
	yaw : (rad) ->
		mat4.rotateY @matrix, @matrix, rad
	
	pitch : (rad) ->
		mat4.rotateX @matrix, @matrix, rad 
	
	roll : (rad) ->
		mat4.rotateZ @matrix, @matrix, rad
	
	### translations ###

	moveTo : (v3) ->
		@matrix[X4] = v3[X]
		@matrix[X4] = v3[Y]
		@matrix[X4] = v3[Z]
	
	translate : (v3) ->
		mat4.translate @matrix, @matrix, v3
		
	right : (distance) ->
		__right[X] = distance
		mat4.translate @matrix, @matrix, __right
		
	up : (distance) ->
		__up[Y] = distance
		mat4.translate @matrix, @matrix, __up
	
	forward : (distance) ->
		__forward[Z] = -distance
		mat4.translate @matrix, @matrix, __forward
