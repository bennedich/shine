'use strict'
plato = require '/plato'

{RIGHT_X, UP_X, FORWARD_X, POS_X, POS_Y, POS_Z} = plato.unitAux
{RED} = plato.colorAux

log = console.log.bind console, '[physball]'

DENSITY = 1e4 #5.514e3 # kg/m^3

getDiameter = (mass) ->
	return 2 * Math.pow (DENSITY*4/3*Math.PI/mass), -1/3


class Ball extends plato.Unit3D
	module.exports = @
	
	constructor : (gl,x,y,mass) ->
		super()
		
		@right x
		@up y
		
		@lastX = @matrix[POS_X] - y * 2.5e-3 #+ x * 1e-4
		@lastY = @matrix[POS_Y] + x * 2.5e-3 #+ y * 1e-4
		
		@nextX = @matrix[POS_X]
		@nextY = @matrix[POS_Y]
		@vX = 0
		@vY = 0
		
		@shaderHandle = 'point_square'
		shader = plato.createShader gl, @shaderHandle
		gl.useProgram shader.program
		@dotBuffer = new plato.Buffer gl, gl.ARRAY_BUFFER, gl.STREAM_DRAW, gl.FLOAT, shader.vert, 3, 1
		@mass = mass
		@size = getDiameter mass
		
		log x|0,y|0,@size
	
	fixedUpdate : (ffi) ->
		{matrix} = @
		@lastX = matrix[POS_X]
		@lastY = matrix[POS_Y]
		@matrix[POS_X] = @nextX
		@matrix[POS_Y] = @nextY
	
	update : (fi, dt) ->
		{matrix, dotBuffer} = @
		dotBuffer[0] = matrix[POS_X]
		dotBuffer[1] = matrix[POS_Y]
		dotBuffer[2] = matrix[POS_Z]
	
	draw : (rndr, cam) ->
		{dotBuffer} = @
		{gl} = rndr
		shader = rndr.setShader @shaderHandle
		gl.uniformMatrix4fv shader.pMat, false, cam.perspective
		gl.uniformMatrix4fv shader.vMat, false, cam.view
		gl.uniformMatrix4fv shader.mMat, false, @matrix
		gl.uniform4fv shader.mClr, RED
		gl.uniform1f shader.mSize, @size * rndr.h
		dotBuffer.bind()
		dotBuffer.bufferSubData()
		gl.drawArrays gl.POINTS, 0, 1
