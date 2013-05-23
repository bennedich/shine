State = require './State'

nopState = new State


class StateMachine
	'use strict'
	module.exports = this
	
	_currentState : nopState
	_previousState : nopState
	
	changeState : (state) ->
		@_currentState.leave() if @_currentState
		@_previousState = @_currentState
		@_currentState = state
		@_currentState.enter @
	
	revertState : ->
		@changeState @_previousState
	
	fixedUpdate : (ffi) ->
		@_currentState.fixedUpdate ffi
	
	update : (fi, dt) ->
		@_currentState.update fi, dt
	
	draw : (rndr, cam) ->
		@_currentState.draw rndr, cam
