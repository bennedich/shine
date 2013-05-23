'use strict'
Unit = require './Unit'

log = console.log.bind console, '[scene]'

class Scene extends Unit
	module.exports = @
	
	#constructor : ->

	traverseDeep : (callback) ->
		@_traverseDeep callback, @units

	_traverseDeep : (callback, units) ->
		for uid, unit of units
			callback unit
			@_traverseDeep callback, unit.units
