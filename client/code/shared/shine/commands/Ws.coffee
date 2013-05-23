### ###

class Ws extends require './Command'
	'use strict'
	module.exports = this
	
	InputField = require '../core/InputField'
	
	
	@help : 'remote connect'
	
	constructor : ->
		super
		@_user = null
		@_pass = null
	
	
	bindListeners : ->
		@_container.addEventListener 'keydown', @_onKeyDown
	
		
	unbindListeners : ->
		@_container.removeEventListener 'keydown', @_onKeyDown
	
	
	_onKeyDown : (evt) =>
		return unless evt.keyCode is util.Key.ENTER
		evt.preventDefault()
		
		if evt.target is @_userField._el and @_user is null
			@_userField._el.contentEditable = false
			@_user = @_userField.read()
			console.log "user #{ @_user }"
			
			@_passField._el.style.color = 'transparent'
			@_passField._el.contentEditable = true
			
			@_container.appendChild document.createTextNode '\npass:'
			@_container.appendChild @_passField._el
			
			@_passField.focus()
		
		if evt.target is @_passField._el
			@_passField._el.contentEditable = false
			@_pass = @_passField.read()
			@_passField.resetInput()
			console.log "pass #{ @_pass }"
			ss.rpc 'auth.authenticate', @_user, @_pass, @_onAuth
	
	
	_onAuth : (success) =>
		if success
			@_output.writeln 'Welcome to SHINE'
		else
			@_output.writeln 'Login rejected'
		@_deferred.resolve()
		@_input.unbind()
	
	
	_onExecute : ->
		@_autoResolve = false
		
		@_container = document.createElement 'div'
		@_output.append @_container
		
		@_userField = new InputField()
		@_passField = new InputField()
		
		@_userField._el.contentEditable = true
		@_container.appendChild document.createTextNode 'user:'
		@_container.appendChild @_userField._el
		
		@_input.bind this
		@_userField.focus()
		



