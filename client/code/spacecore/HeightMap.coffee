'use strict'

plato = require '/plato'
PerlinNoise = require '/util/PerlinNoise'
glm = require '/gl-matrix'

log = console.log.bind console, '[heightmap]'

LIGHT_AMBIENT = glm.vec3.fromValues .09, .06, .04
LIGHT_DIFFUSE = glm.vec3.fromValues .7, .4, .2
LIGHT_DIRECTION = glm.vec3.fromValues 0.3, .3, .1

class HeightMap extends plato.Unit3D
	module.exports = @
	
	constructor : (gl) ->
		super()

		@perlin = new PerlinNoise 'spacecore'

		@w = 32
		@h = 32

		positionSize = 3
		normalSize = 3
		@maxItemsN = 3 * 2 * (@w+2) * @h
		@itemsN = 0
		@shaderHandle = 'blinn_phong'
		shader = plato.createShader gl, @shaderHandle
		gl.useProgram shader.program
		@positionsBuffer = new plato.Buffer gl, gl.ARRAY_BUFFER, gl.STREAM_DRAW, gl.FLOAT, shader.vert, positionSize, @maxItemsN
		@normalsBuffer = new plato.Buffer gl, gl.ARRAY_BUFFER, gl.STREAM_DRAW, gl.FLOAT, shader.norm, normalSize, @maxItemsN
		@initValues()

	initValues : ->
		{h, w} = @
		i = 0
		for y in [0...h] by 1
			for x in [0...w+1] by 1
				@vert i++, x, y, @heightAt x,y
				@vert i++, x, y+1, @heightAt x,y+1
				#@vert i++, x, y+1, @heightAt x,y+1
				#@vert i++, x, y, @heightAt x,y
			@vert i++, w, y+1, @heightAt w,y+1
			@vert i++, 0, y+1, @heightAt 0,y+1
			#@vert i++, w, y, @heightAt w,y
			#@vert i++, 0, y+2, @heightAt 0,y+2
		@itemsN = i
		log @itemsN, @maxItemsN

	vert : (i,x,y,z) ->
		@normal i,x,y,z
		i *= 3
		@positionsBuffer.buffer[i++] = x
		@positionsBuffer.buffer[i++] = y
		@positionsBuffer.buffer[i++] = z

	normal : (i,x,y,z) ->
		# TODO manage edge cases
		#return if x is 0
		#return if y is 0
		#return if x is @w
		#return if y is @h
		i *= 3
		@normalsBuffer.buffer[i++] = (@heightAt(x-1,y) - @heightAt(x+1,y))/2
		@normalsBuffer.buffer[i++] = (@heightAt(x,y-1) - @heightAt(x,y+1))/2
		@normalsBuffer.buffer[i++] = 1

	heightAt : (x, y) ->
		#i = 3 * 2 * (x + (@w+2) * y) + 2
		p = 0.09
		q = 6
		return q * @perlin.noise2d p*x, p*y

	fixedUpdate : (ffi) ->
		#@positionsBuffer.buffer[2] = Math.abs(ffi%60 - 30)/30 - 1.5

	update : (fi, dt) ->
		#window.FI = fi

	draw : (rndr, cam) ->
		gl = rndr.gl
		shader = rndr.setShader @shaderHandle

		gl.uniform3fv shader.l_ambient, LIGHT_AMBIENT
		gl.uniform3fv shader.l_diffuse, LIGHT_DIFFUSE
		gl.uniform3fv shader.l_position, LIGHT_DIRECTION

		gl.uniformMatrix4fv shader.pMat, false, cam.perspective
		gl.uniformMatrix4fv shader.vMat, false, cam.view
		gl.uniformMatrix4fv shader.mMat, false, @matrix

		# TODO only do this if any part of the data has changed
		@positionsBuffer.bind()
		@positionsBuffer.bufferSubData()

		@normalsBuffer.bind()
		@normalsBuffer.bufferSubData()

		gl.drawArrays gl.TRIANGLE_STRIP, 0, @itemsN
		#gl.drawArrays gl.POINTS, 0, @itemsN
