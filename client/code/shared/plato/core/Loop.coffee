'use strict'
step = require '/kaos/kernel/step'
EventEmitter = require '/util/EventEmitter'

{INTERVAL, MAX_DELTA, STARTED, STOPPED, FIXED_UPDATE, UPDATE, DRAW} = require '../auxiliary/loopAux'

log = console.log.bind console, '[loop]'
warn = console.warn.bind console, '[loop]'

###
HIDDEN = null
VISIBILITY_CHANGE = null

if document.hidden isnt undefined
	HIDDEN = 'hidden'
	VISIBILITY_CHANGE = 'visibilitychange'
if document.webkitHidden isnt undefined
	HIDDEN = 'webkitHidden'
	VISIBILITY_CHANGE = 'webkitvisibilitychange'
else if document.mozHidden isnt undefined
	HIDDEN = 'mozHidden'
	VISIBILITY_CHANGE = 'mozvisibilitychange'

document.addEventListener VISIBILITY_CHANGE, @onvisibilitychange

onvisibilitychange : (e) ->
	if document[HIDDEN]
		log 'hidden'
		@wasAlive = true
		@stop()
	else
		log 'visible'
		if @wasAlive
			@start()
		@wasAlive = false

###


class Loop extends EventEmitter
	module.exports = @
	
	constructor : ->
		super()
		@isAlive = false
		@wasAlive = false
		
		@onstep = @onstep.bind @
		@onblur = @onblur.bind @
		@onfocus = @onfocus.bind @
		
		@fixedFrameIndex = 0
		@frameIndex = 0
		@delta = 0
		@timestamp = 0
		@stopTimestamp = 0
		@timeBuffer = 0
		@fps = 0
		
		window.addEventListener 'blur', @onblur
		window.addEventListener 'focus', @onfocus
		
	start : ->
		@isAlive = true
		if @stopTimestamp > 0
			@timestamp += Date.now() - @stopTimestamp - INTERVAL
		step.bind @onstep
		step.start()
		@emit STARTED
		return
	
	stop : ->
		@isAlive = false
		@stopTimestamp = Date.now()
		step.unbind @onstep
		@emit STOPPED
		return
	
	onstep : (timestamp) ->
		@delta = timestamp - @timestamp
		if @delta > MAX_DELTA
			warn (@delta - MAX_DELTA | 0), 'ms frameskip'
			@delta = MAX_DELTA
		@timestamp = timestamp
		@fps = 1000 / @delta
		@timeBuffer += @delta
		while @timeBuffer >= INTERVAL
			@timeBuffer -= INTERVAL
			++@fixedFrameIndex
			@emit FIXED_UPDATE, @fixedFrameIndex
		++@frameIndex
		@emit UPDATE, @frameIndex, @delta
		@emit DRAW
		return
	
	onblur : (e) ->
		@wasAlive = true
		@stop()
	
	onfocus : (e) ->
		@start() if @wasAlive
		@wasAlive = false



