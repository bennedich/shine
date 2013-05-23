### ###

class WsExit extends require './Command'
	'use strict'
	module.exports = this
	
	@help : 'remote connect close session'
	
	
	_onLogout : =>
		@_output.writeln 'logged out'
		@_deferred.resolve()
	
	
	_onExecute : ->
		@_autoResolve = false
		ss.rpc 'auth.logout', @_onLogout

