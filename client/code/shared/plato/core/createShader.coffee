'use strict'
Shader = require './Shader'

shaderCache = {}

module.exports = (gl, name) ->
	unless shaderCache.hasOwnProperty name
		shaderCache[name] = new Shader gl, name
	return shaderCache[name]
