### ###

class WsEcho extends require './Command'
	'use strict'
	module.exports = this
	
	@help : 'echos sent messages'
	
	
	_onLogout : (resp) =>
		@_output.writeln "server resp: #{ resp }"
		@_deferred.resolve()
	
	
	_onExecute : ->
		@_autoResolve = false
		ss.rpc 'shine.echo', @_payload[0], @_onLogout

