### KickAss OS
###

'use strict'

###
SpaceCore
Lets get this jerry-rigged mofo airborne!

when fighting you can either choose superviolence and destroy your opponent
or you can land and board their ship and turn it into a sidescroller fight
where there's an attacking and defending side "pirate" style.

Time and physics in the background will act as normal so if you are close to a planet well then...


Background
In late january I picked up an old project where I had tried to create a CLI
in the browser environment. The project never got very far but this time
around I got some quick results, although I wasn't very satisfied with the
solution. It utilized the HTML contentEditable feature and relied on a bunch
of hacks to achieve a sleek UI. Unfortunately it imposed lots of technical
restrictions, such as freely animating fragments of the screen.

So, last weekend (march 8th) I finally picked it up again and this time around
wrote a simple ASCII renderer continously updating the GUI. This proved to
work like a charm by storing the framebuffer as a Uint16Array and writing it
as a string to an absolutely positioned HTML element (thus minimizing browser
reflow). I consequently realized I needed some sort of command and process
management system and this is most easily contained in a minimalistic OS. I
spent the evenings of the following week piecing loose thoughts together until
I reached a crossing point of sleep deprivation versus effiency. Once I
noticed it was about to take a toll on my day job I took a pause until this
weekend (march 15th).

So, friday 15th I was doing some late night lazy haxxing in the kitchen with
my roomie Stefan when we sparked up a conversation about the OS. We discussed
naming it something ending in -OS and finally settled on Kaos; KickAss OS.


2013-03-17
After laundring my dirty clothes in the shared laundring area and tracing down
a bug in one of my recent projects I reached the point of booting up a
jerry-rigged first version of KickAss OS. It ran! The monster was alive! I
managed to piece together a crude command and process pipeline with access to
an exposed API to the KAOS kernel. The next step is to learn more about
stdin/out and piping to get interprocess communication running. That way I can
hook up the terminal process to the keyboard IO device and also write to the
renderer process hooked up to the screen IO device. Now I'm gonna kick back
and watch the oldest torrent on PB; Revolution OS - a documentary about Linux.


2013-03-19
Took a day off from evening hax yesterday. Went sport climbing instead then
practised some GTA IV motorcycle driving for a couple of hours before hitting
the sack. This evening I focused on getting pipes working and it was a pretty
quick insertion. For the first time I got something visible on the screen!
Ripley (the CLI) sent the first message to mono (the renderer/screen
api). The message was a blinking "RIPLEY SAYS HI". Next step is to implement
a more thoroughly working Ripley with keyboard listener.

Two new processes got finished tonight; `Keyboard` and `Stats`. Also one new
command; `Help`. Basic command evaluation implemented between Ripley and the
Kaos API. Next up is websocket connection process and ascii animations!

This is quickly becoming my greatest coding endeavor yet!

exec project_icarus


###

step = require './step'
key = require '../io/key'
keyboard = require '../io/keyboard'
commands = require '../commands'
processes = require '../processes'

# spawn process
# interupt process
# terminate process


module.exports = -> new Kaos


class Kaos
	constructor : ->
		@commandQueue = []
		@processList = []
		
		# inherit the base command and process objects
		# these new objects can be filled with user commands and
		# processes without polluting the shared ones
		@commands = Object.create commands
		@processes = Object.create processes

		# the part of kaos exposed to commands and processes
		@api =
			step : step
			key : key
			keyboard : keyboard
			enqueueCommand : @enqueueCommand.bind @
			spawnProcess : @spawnProcess.bind @
			processes : @listProcesses.bind @
			availableCommands : @availableCommands.bind @
			availableProcesses : @availableProcesses.bind @
			pipe : @pipe.bind @
			getProcess : @getProcess.bind @
			#process creation and control
			#process triggers
			#io port interface, control
			#pipes
			#file and directory operations
			#threads (web workers) creation, control, cleanup
			#timer
			#signals
			#memory?
		
		# the boot process, read this from a bootscript?
		#	init hardware such as keyboard, mouse, joystick
		#	init visual display (mono renderer)
		#	load current disk (root device)
		#	mount file system
		#	add kernel to system and start it
		#	first process is init
		#	init starts up terminal
		#	set up network etc
		
		step.bind @update.bind @
		step.start()
		
		@spawnProcess 'boot', {init: true}
	
	update : (timestamp) ->
		commandQueue = @commandQueue
		api = @api
		
		command.execute() while command = commandQueue.shift()
		process.update timestamp for process in @processList
	
	#registerCommand : (command) ->
		### add your own commands ###
	
	createCommand : (commandstring, parent) ->
		# TODO switch to a command object pool eventually
		if commandstring.length is 0
			return new commands.unknown @api, parent
		
		options = commandstring.split /\s/
		commandname = options.shift()
		
		unless commandname of @commands
			return new commands.unknown @api, parent
	
		return new commands[commandname] @api, parent, options
	
	enqueueCommand : (commandstring, parent) ->
		command = @createCommand commandstring, parent
		@commandQueue.push command
		return
	
	spawnProcess : (processname, options) ->
		console.log 'spawn process', processname
		# TODO switch to a process object pool eventually
		process = new @processes[processname] @api, options
		@processList.push process
		return process unless options
		if options.feeder
			@pipe options.feeder, process
		if options.feedee
			@pipe process, options.feedee
		if options.init
			process.init()
		return process
	
	listProcesses : ->
		process for process in @processList
	
	availableCommands : ->
		k for k,v of @commands
	
	availableProcesses : ->
		k for k,v of @processes
	
	getProcess : (pid) ->
		for process in @processList
			return process if process.pid is pid
		return
	
	endProcess : (pid) ->
		
	
	pipe : (feeder, feedee) ->
		feeder.stdout = feedee.stdin
	
	reboot : ->
	
	shutdown : ->
