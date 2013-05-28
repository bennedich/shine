plato = require '/plato'
glm = require '/gl-matrix'

class PhysCar2D extends plato.Unit2D
	module.exports = @

	constructor : (gl, image) ->
		super()

		@shaderHandle = 'texture2d'
		shader = plato.createShader gl, @shaderHandle
		gl.useProgram shader.program
		
		w2 = image.width / 2 / 200
		h2 = image.height / 2 / 200

		@texture = new plato.Texture gl, image, gl.TEXTURE0

		@textureBuffer = new plato.Buffer gl, gl.ARRAY_BUFFER, gl.STATIC_DRAW, gl.FLOAT, shader.texture_coords, 2, 4
		@setVert @textureBuffer.buffer, 0, 0, 0
		@setVert @textureBuffer.buffer, 1, 1, 0
		@setVert @textureBuffer.buffer, 2, 0, 1
		@setVert @textureBuffer.buffer, 3, 1, 1
		@textureBuffer.bufferSubData()

		@vertBuffer = new plato.Buffer gl, gl.ARRAY_BUFFER, gl.STATIC_DRAW, gl.FLOAT, shader.vert, 2, 4
		@setVert @vertBuffer.buffer, 0, -w2, -h2
		@setVert @vertBuffer.buffer, 1, w2, -h2
		@setVert @vertBuffer.buffer, 2, -w2,  h2
		@setVert @vertBuffer.buffer, 3, w2,  h2
		@vertBuffer.bufferSubData()

	setVert : (buffer, i, x, y) ->
		i *= 2
		buffer[i] = x
		buffer[i+1] = y

	draw : (rndr, cam) ->
		{textureBuffer, vertBuffer} = @
		{gl} = rndr
		shader = rndr.setShader @shaderHandle	

		gl.uniformMatrix4fv shader.pMat, false, cam.perspective
		gl.uniformMatrix4fv shader.vMat, false, cam.view
		gl.uniformMatrix4fv shader.mMat, false, @matrix4()

		gl.activeTexture gl.TEXTURE0
		gl.bindTexture gl.TEXTURE_2D, @texture.texture
		gl.uniform1i shader.texture_sampler, 0
		
		#textureBuffer.bind()
		#textureBuffer.bufferSubData()

		vertBuffer.bind()
		gl.drawArrays gl.TRIANGLE_STRIP, 0, 4

	acc : (t) ->
		@up 0.05

	dec : (t) ->
		@up -0.05

	turn : (t) ->
		@rotate t * 0.05
