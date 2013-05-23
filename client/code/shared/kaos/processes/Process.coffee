'use strict'

class Process
	module.exports = this
	__pid = 0
	
	constructor : (@kaos, @options) ->
		@pid = ++__pid
		#@dependencies = []
		@stdin = @stdin.bind @
		# stdin
		# stdout
		# stderr
		
		# other processes depends on this one? dependency list?
		
	init : ->
	update : (timestamp) ->
	exit : ->
	
	
	stdin : -> # this should be defined in subclasses
	stdout : -> # this will be overwritten by another instance's stdin
