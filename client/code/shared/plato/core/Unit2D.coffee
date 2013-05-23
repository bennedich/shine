'use strict'
NotImplementedError = require '/util/NotImplementedError'
{mat4, mat3, mat2d, vec2} = require '/gl-matrix'
{X,Y,Z, X2,Y2, X3,Y3, X4,Y4,Z4} = require '../auxiliary/unitAux'
Unit = require './Unit'

class Unit2D extends Unit
	module.exports = @
	
	__right = vec2.create()
	__up = vec2.create()
	__t1mat4 = mat4.create() # intermediate storage
	
	constructor : ->
		super()
		@matrix = mat2d.create()
	
	### rotations ###

	lookAt : (vector2) ->
		#mat3.rotate @matrix,
		throw new NotImplementedError
	
	rotate : (rad) ->
		mat2d.rotate @matrix, @matrix, rad
	
	### translations ###

	moveTo : (v2) ->
		@matrix[X2] = v2[X]
		@matrix[Y2] = v2[Y]
	
	translate : (v2) ->
		mat2d.translate @matrix, @matrix, v2
	
	right : (distance) ->
		__right[X] = distance
		mat2d.translate @matrix, @matrix, __right
		
	up : (distance) ->
		__up[Y] = distance
		mat2d.translate @matrix, @matrix, __up

	### aux ###

	matrix4 : (m2d) ->
		matrix = m2d ? @matrix
		# {matrix} = @
		__t1mat4[0] = matrix[0]
		__t1mat4[1] = matrix[1]
		__t1mat4[4] = matrix[2]
		__t1mat4[5] = matrix[3]
		__t1mat4[12] = matrix[4]
		__t1mat4[13] = matrix[5]
		return __t1mat4 # WARN overwritten every invokation
