createCommand : ->
	unless @prompt.input.length
		return new UnknownCommand
	payload = @prompt.input.split /\s/
	keyword = payload.shift()
	unless keyword of commands
		return new UnknownCommand
	return new commands[keyword] @rndr, @keyb




State = require '/util/State'
Keyboard = require '/util/Keyboard'
Key = require '/util/Key'

class CommandState
	'use strict'
	module.exports = this
	
	constructor : (input) ->
	
	enter : (@menuSM) ->
		Keyboard.on 'char', @onChar
		Keyboard.on 'key', @onKey
		
		
	leave : ->
		Keyboard.off 'char', @onChar
		Keyboard.off 'key', @onKey
	
	
	onChar : (char, charCode) ->
	
	onKey : (key) ->