'use strict'
NotImplementedError = require '/util/NotImplementedError'
{mat4, mat3, mat2d, mat2, vec3, vec2} = require '/gl-matrix'
{X,Y,Z, X2,Y2, X3,Y3, X4,Y4,Z4} = require '../auxiliary/unitAux'
Unit = require './Unit'

class Unit2D extends Unit
	module.exports = @
	
	__right = vec3.create()
	__up = vec3.create()
	__t1mat4 = mat4.create() # intermediate storage
	
	constructor : ->
		super()
		@matrix = mat3.create()
	
	### rotations ###

	lookAt : (vector2) ->
		#mat3.rotate @matrix,
		throw new NotImplementedError
	
	rotate : (rad) ->
		mat3.rotate @matrix, @matrix, rad
	
	### translations ###

	moveTo : (v3) ->
		@matrix[X3] = v3[X]
		@matrix[Y3] = v3[Y]
	
	translate : (v3) ->
		mat3.translate @matrix, @matrix, v3
	
	right : (distance) ->
		__right[X] = distance
		mat3.translate @matrix, @matrix, __right
		
	up : (distance) ->
		__up[Y] = distance
		mat3.translate @matrix, @matrix, __up

	### aux ###

	matrix4 : (m3) ->
		matrix = m3 ? @matrix
		# {matrix} = @
		__t1mat4[0] = matrix[0]
		__t1mat4[1] = matrix[1]
		__t1mat4[4] = matrix[3]
		__t1mat4[5] = matrix[4]
		#__t1mat4[10] = 1
		__t1mat4[12] = matrix[6]
		__t1mat4[13] = matrix[7]
		#__t1mat4[15] = 1
		return __t1mat4 # WARN overwritten every invokation
