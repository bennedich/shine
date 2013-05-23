### ###

class Command
	'use strict'
	module.exports = this
	
	constructor : (@_input, @_output, @_payload) ->
		@_autoResolve = true
		@_deferred = null
	
	execute : ->
		@_deferred = util.defer()
		
		util.delay( 0 ).then =>
			@_onExecute()
			@_deferred.resolve() if @_autoResolve
		
		return @_deferred.promise
	
	_onExecute : ->
		#@output.write document.createTextNode "\n* #{ @payload } *"
