'use strict'

# WARN: textures' widths and heights must be a power of two number of pixels

class Texture
	module.exports = @

	constructor : (gl, image, textureRegister) ->
		@texture = gl.createTexture()
		gl.activeTexture textureRegister
		gl.bindTexture gl.TEXTURE_2D, @texture
		gl.texImage2D gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image
		gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST
		gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST
		gl.generateMipmap gl.TEXTURE_2D
		gl.bindTexture gl.TEXTURE_2D, null
