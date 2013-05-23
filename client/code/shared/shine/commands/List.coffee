### ###


class List extends require './Command'
	'use strict'
	module.exports = this
	
	@help : 'lists all commands'
	
	_onExecute : ->
		for command of shine.commands
			@_output.writeln " #{command}\t:: #{ shine.commands[command].help }"

