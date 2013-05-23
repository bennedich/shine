'use strict'

class Unit
	module.exports = @
	
	__uid = 0

	constructor : ->
		@uid = ++__uid
		@parent = null
		@units = []
	
	### scene ###

	add : (unit) ->
		unless unit.parent is null
			unit.parent.remove unit
		@units.push unit
		unit.parent = @
		return unit

	remove : (unit) ->
		i = @units.indexOf unit
		return null if i < 0
		@units.splice i, 1
		unit.parent = null

	### loop ###

	fixedUpdate : (ffi) ->
	update : (fi, dt) ->
	draw : (rndr, cam) ->
