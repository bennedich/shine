
module.exports = do ->
	'use strict'
	
	
	commands =
		ls	: require './commands/Ls'
		list	: require './commands/List'
		clear	: require './commands/Clear'
		screen	: require './commands/Screen'
		ws 	: require './commands/Ws'
		exit	: require './commands/WsExit'
		echo	: require './commands/WsEcho'
	
		
	Nop = require './commands/Nop'	
	
	
	createCommand = (input, output, commandstr) ->
		if commandstr.length is 0
			return new Nop input, output
	
		payload = commandstr.split /\s/
		command = payload.shift()
	
		unless command of commands
			return new Nop input, output
	
		return new commands[command] input, output, payload
	
	
	shine =
		commands	: commands
		createCommand	: createCommand
		Cli 		: require './core/Cli'
	
	
	return shine
