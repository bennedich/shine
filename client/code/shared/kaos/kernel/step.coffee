### global requestAnimationFrame parallelizer
###
'use strict'

requestAnimationFrame =
	window.requestAnimationFrame		or
	window.webkitRequestAnimationFrame	or
	window.mozRequestAnimationFrame		or
	window.msRequestAnimationFrame		or
	window.oRequestAnimationFrame

cancelAnimationFrame =
	window.cancelAnimationFrame		or
	window.webkitCancelAnimationFrame	or
	window.mozCancelAnimationFrame		or
	window.msCancelAnimationFrame		or
	window.oCancelAnimationFrame

requestId = null
listeners = []

INTERVAL = 1000 / 60

bind = (listener) ->
	listeners.push listener
	return

unbind = (listener) ->
	i = listeners.indexOf listener
	listeners.splice i, 1 unless i < 0
	return

# true==start :: false::stop
toggle = -> start() or stop() and false

start = ->
	return false unless requestId is null
	requestId = requestAnimationFrame keyframe
	return true

stop = ->
	return false if requestId is null
	cancelAnimationFrame requestId
	requestId = null
	return true

keyframe = (timestamp) ->
	requestId = requestAnimationFrame keyframe
	listener timestamp for listener in listeners

module.exports = {INTERVAL, bind, unbind, toggle, start, stop}
