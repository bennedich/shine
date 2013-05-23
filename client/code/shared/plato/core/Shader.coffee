'use strict'

SHADER_SELECTOR_SUFFIX_VERT = '_vert'
SHADER_SELECTOR_SUFFIX_FRAG = '_frag'

log = console.log.bind console, '[shdr]'
err = console.error.bind console, '[shdr]'

class Shader
	module.exports = @
	
	constructor : (@gl, @name) ->
		@program = @gl.createProgram()
		@compileShader "##{ @name }#{ SHADER_SELECTOR_SUFFIX_VERT }", @gl.VERTEX_SHADER
		@compileShader "##{ @name }#{ SHADER_SELECTOR_SUFFIX_FRAG }", @gl.FRAGMENT_SHADER
		@linkProgram()
		@bindUniforms()
		@bindAttributes()
	
	compileShader : (selector, shaderType) ->
		shader = @gl.createShader shaderType
		src = document.querySelector(selector).textContent
		@gl.shaderSource shader, src
		@gl.compileShader shader
		unless @gl.getShaderParameter shader, @gl.COMPILE_STATUS
			err 'SHADER CREATION FAILED', shaderType, selector, @gl.getShaderInfoLog shader
		@gl.attachShader @program, shader
		@gl.deleteShader shader
		return
	
	linkProgram : ->
		@gl.linkProgram @program
		unless @gl.getProgramParameter @program, @gl.LINK_STATUS
			err 'PROGRAM LINK FAILED', @selector, @gl.getProgramInfoLog @program
		@gl.validateProgram @program # TODO is this available in webgl?
		unless @gl.getProgramParameter @program, @gl.VALIDATE_STATUS
			err 'PROGRAM VALIDATION FAILED', @selector, @gl.getProgramInfoLog @program
		return
	
	bindUniforms : ->
		n = @gl.getProgramParameter @program, @gl.ACTIVE_UNIFORMS
		for i in [0...n] by 1
			uniform = @gl.getActiveUniform @program, i
			@[uniform.name] = @gl.getUniformLocation @program, uniform.name
		return
	
	bindAttributes : ->
		n = @gl.getProgramParameter @program, @gl.ACTIVE_ATTRIBUTES
		for i in [0...n] by 1
			attrib = @gl.getActiveAttrib @program, i
			@[attrib.name] = @gl.getAttribLocation @program, attrib.name
		return
