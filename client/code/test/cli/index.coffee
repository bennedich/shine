mono = require '/kaos/mono'
StateMachine = require '/kaos/StateMachine'
PromptState = require './PromptState'
Command = require './Command'


### ###

class UnknownCommand extends Command
	'use strict'
	onExecute : ->
		console.log 'UNKNOWN!!'

commands = {UnknownCommand}



class Cli
	'use strict'
	module.exports = this
	
	TITLE : 'terminal'
	
	_bash : 'shine:/ *$' # domain:location user$ commands -arg0 -arg1 sourcePath targetPath
	
	constructor : (@selector) ->
		@initStats()
		@initCore()
		@initStates()
		@loop.start()
	
	log : console.log.bind console, '[CLI]'
	
	initStats : ->
		@_stats = new Stats
		document.querySelector('#stats_bar').appendChild @_stats.domElement
		@ffiBar = document.querySelector '#ffi_bar'
		@fiBar = document.querySelector '#fi_bar'
	
	initCore : ->
		@scrn = new mono.Screen @selector, 78, 26
		@rndr = new mono.Renderer 78, 26
		@cam = new mono.Camera
		@loop = new mono.Loop
		@loop.on 'started', => @log 'started'
		@loop.on 'stopped', => @log 'stopped'
		@loop.on 'fixedUpdate', @onFixedUpdate
		@loop.on 'update', @onUpdate
		@loop.on 'draw', @onDraw
	
	initStates : ->
		@promptState = new PromptState
		@menuSM = new StateMachine
		@menuSM.changeState @promptState
	
	onFixedUpdate : (ffi) =>
		@ffiBar.textContent = ffi
		@menuSM.fixedUpdate ffi
		#@scn.traverseDeep (node) =>
		#	node.fixedUpdate ffi
	
	onUpdate : (fi, dt) =>
		@fiBar.textContent = fi
		@menuSM.update fi, dt
		@_stats.update()
		#@scn.traverseDeep (node) =>
		#	node.update fi, dt
	
	onDraw : =>
		#@scn.traverseDeep (node) =>
		#	node.draw @rndr, @cam
		@menuSM.draw @rndr, @cam
		@rndr.render @scrn
		@rndr.clearBuffer()

