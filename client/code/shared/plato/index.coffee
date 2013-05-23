'use strict'

CORE = './core/'
AUX = './auxiliary/'

r = (path, lib) ->
	return require "./#{path}/#{lib}"

module.exports =
	# INLINE
	DEG2RAD : Math.PI / 180
	RAD2DEG : 180 / Math.PI
	
	# CORE
	Loop		: r CORE, 'Loop'
	Renderer	: r CORE, 'Renderer'
	Unit		: r CORE, 'Unit'
	Unit2D		: r CORE, 'Unit2D'
	Unit3D		: r CORE, 'Unit3D'
	Camera		: r CORE, 'Camera'
	Shader		: r CORE, 'Shader'
	Buffer		: r CORE, 'Buffer'
	createShader	: r CORE, 'createShader'
	gamepad		: r CORE, 'gamepad'
	
	# AUX
	loopAux		: r AUX, 'loopAux'
	unitAux		: r AUX, 'unitAux'
	colorAux	: r AUX, 'colorAux'
	gamepadAux	: r AUX, 'gamepadAux'
