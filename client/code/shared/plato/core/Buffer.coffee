'use strict'

### Typical usage:
	bufferTarget	:: gl.ARRAY_BUFFER
	usage		:: gl.STATIC_DRAW
	attribIndex	:: shader.vert
	itemSize	:: 3 for vec3s
	datatype	:: gl.FLOAT
###
class Buffer
	module.exports = @
	
	constructor : (@gl, @bufferTarget, @usage, @datatype, @attribIndex, @itemSize, @itemCount) ->
		@glBuffer = gl.createBuffer()
		@buffer = new Float32Array @itemSize * @itemCount
		gl.bindBuffer @bufferTarget, @glBuffer
		gl.bufferData @bufferTarget, @buffer, @usage
		gl.enableVertexAttribArray @attribIndex
		gl.vertexAttribPointer @attribIndex, @itemSize, @datatype, false, 0, 0 # TODO this line not needed? It changes which buffer object should currently be drawn, it should always be done after gl.bindBuffer

	bind : ->
		@gl.bindBuffer @bufferTarget, @glBuffer
		@gl.vertexAttribPointer @attribIndex, @itemSize, @datatype, false, 0, 0

	bufferSubData : (offset=0) ->
		@gl.bufferSubData @bufferTarget, offset, @buffer

