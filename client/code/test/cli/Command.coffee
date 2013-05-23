###
###

defer = require '/util/defer'
delay = require '/util/delay'


class Process
	'use strict'
	module.exports = this
	
	is_locking : false
	is_alive : true
	
	###
	execute : ->
		@_deferred = defer()
		delay(0).then =>
			@onExecute()
			@_deferred.resolve() if @_autoResolve
		@promise = @_deferred.promise
		return
	###
	
	execute : ->
		delay(0).then =>
			@onExecute()
			@onDone()
		return
	
	onExecute : ->
		#@output.write document.createTextNode "\n* #{ @payload } *"
	
	onDone : ->
	
	fixedUpdate : (ffi) ->
	update : (fi, dt) ->
	draw : (rndr, cam) ->