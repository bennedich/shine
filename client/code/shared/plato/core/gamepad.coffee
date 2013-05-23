'use strict'
{FOUND,LOST} = require '../auxiliary/gamepadAux'

log = console.log.bind console, '[gamepad]'
nop = ->

registeredGamepads = []

getGamepads = (navigator.getGamepads or
		navigator.webkitGetGamepads or
		navigator.mozGetGamepads or nop).bind(navigator)

update = (fi, dt) ->
	gamepad = getGamepads()[0]
	registered = registeredGamepads[0]
	registeredGamepads[0] = gamepad
	if gamepad isnt registered
		log if gamepad then 'found slot 0' else 'lost slot 0'
	return gamepad

###
update = ->
	for gamepad, i in nativeGamepads
		registered = registeredGamepads[i]
		continue if gamepad is registered
		registeredGamepads[i] = gamepad
		module.exports.changed = true
		if gamepad
			@emit FOUND, i, gamepad
		else
			@emit LOST, i
	return
###

update = nop unless getGamepads()

module.exports = {update}
