'use strict'
EventEmitter = require '/util/EventEmitter'
Prng = require '/util/Prng'
PerlinNoise = require '/util/PerlinNoise'
Key = require '/util/key'
Keyb = require '/kaos/io/keyboard'
glm = require '/gl-matrix'
plato = require '/plato'
gamepad = plato.gamepad

HeightMap = require './HeightMap'
VoxelGrid = require './VoxelGrid'
PhysicsWorld = require './PhysicsWorld'
PhysicsBall = require './PhysicsBall'

{INTERVAL, STARTED, STOPPED, FIXED_UPDATE, UPDATE, DRAW} = plato.loopAux
{X,Y,Z, X2,Y2, X3,Y3, X4,Y4,Z4} = plato.unitAux
{RED,GREEN} = plato.colorAux
{mat4, mat3, mat2d, mat2, vec3, vec2, quat} = glm

log = console.log.bind console, '[spacecore]'
err = console.error.bind console, '[spacecore]'

ε = 0.16

class Spacecore
	module.exports = @
	
	constructor : (@selector) ->
		@fixedUpdate = @fixedUpdate.bind @
		@update = @update.bind @
		@draw = @draw.bind @
		
		# config stats env
		@initAssets()
		@initStats()
		@initCore()
		@initScene()
		@start()
	
	initAssets : ->
		#
	
	initStats : ->
		# TODO turns out stats are fucking up GC
		#@stats = new Stats
		#@stats.domElement.style.position = 'absolute'
		#@stats.domElement.style.zIndex = 1e4
		#document.querySelector('#statsBar').appendChild @stats.domElement
		@fpsBar = document.querySelector('#fpsBar .val')
		@ffiBar = document.querySelector('#ffiBar .val')
		@fiBar = document.querySelector('#fiBar .val')
	
	initCore : ->
		@gamepad0 = null
		
		@rndr = new plato.Renderer @selector
		#@scn = new plato.Scene
		#physics world ??
		@loop = new plato.Loop
		@loop.on STARTED, -> log 'started'
		@loop.on STOPPED, -> log 'stopped'
		@loop.on FIXED_UPDATE, @fixedUpdate
		@loop.on UPDATE, @update
		@loop.on DRAW, @draw
	
	initScene : ->
		{gl} = @rndr
		@cam = new plato.Camera 1, 1.6, 1e-3, 1e6
		@cam.matrix[Z4] = 10
		#@heightMap = new HeightMap gl
		#@voxelGrid = new VoxelGrid gl
		#@initPhysWorld()
		@initSatWorld()
	
	initPhysWorld : ->
		{gl} = @rndr
		p = new Prng 'spacecore'
		@physWorld = new PhysicsWorld
		@physWorld.add new PhysicsBall gl,0,-0.5,1e5
		for i in [0...3e2]
			x = 5e-3 * (5e2 - p.random() * 1e3 | 0)
			y = 2e-3 * (5e2 - p.random() * 1e3 | 0)
			
			x += 3.5 * if x>0 then 1 else -1
			y += 3.5 * if y>0 then 1 else -1
			
			m = 0.4 + 0.75*p.random()
			m = 400 * Math.pow m,4
			
			@physWorld.add new PhysicsBall gl,x,y,m
	
	initSatWorld : ->
		@satWorld = new SatWorld @rndr.gl
	
	start : ->
		@loop.start()
	
	smoothstep : (t) ->
		return t*t*(3-2*t)
	
	fixedUpdate : (ffi) ->
		# physics updates
		
		#if ffi < 240
		#	@cam.matrix[Z4] = 4 + 10*@smoothstep ffi/240
		
		@fixedUpdateKeyboard()
		@fixedUpdateGamePad @gamepad0

		@cam.fixedUpdate ffi

		#@heightMap.fixedUpdate ffi
		#@voxelGrid.fixedUpdate ffi
		#@physWorld.fixedUpdate ffi
		@satWorld.fixedUpdate ffi
	
	
	fixedUpdateKeyboard : ->
		{cam} = @
		a = 0.05
		d = 0.1
		
		if Keyb[Key.SHIFT]
			d *= 10
		
		if Keyb[Key.UP]
			@cam.pitch +a
		if Keyb[Key.DOWN]
			@cam.pitch -a
		if Keyb[Key.LEFT]
			@cam.yaw +a
		if Keyb[Key.RIGHT]
			@cam.yaw -a
		if Keyb[Key.Q]
			@cam.roll +a
		if Keyb[Key.E]
			@cam.roll -a
		
		if Keyb[Key.W]
			@cam.forward +d
		if Keyb[Key.S]
			@cam.forward -d
		if Keyb[Key.A]
			@cam.right -d
		if Keyb[Key.D]
			@cam.right +d
		if Keyb[Key.F]
			@cam.up -d
		if Keyb[Key.R]
			@cam.up +d
	
	# axis (analog -1 -> 1)
	# 0/1 lx/ly
	# 2/3 rx/ry
	
	# buttons
	# 0-5 a,b,x,y,lb,rb
	# 6/7 lt/rt (analog -1 -> 1)
	# 8/9 select/start
	# 10/11 l/r thumbs
	# 12-15 dpad u/d/l/r
	# 16 meta
	fixedUpdateGamePad : (gamepad) ->
		return unless gamepad
		{axes,buttons} = gamepad
		a = 0.04 / (1-ε)
		d = 0.1 / (1-ε)
		[lx,ly,rx,ry] = axes
		[lb,rb,lt,rt] = buttons[4..7]
		
		if ε < Math.abs lx
			@cam.right d * (lx - ε*lx/Math.abs lx)
		if ε < Math.abs ly
			@cam.up d * -(ly - ε*ly/Math.abs ly)
		if ε < Math.abs lt
			@cam.forward d * -(lt-ε)
		if ε < Math.abs rt
			@cam.forward d * (rt-ε)
		
		if ε < Math.abs rx
			@cam.yaw a * -(rx - ε*rx/Math.abs rx)
		if ε < Math.abs ry
			@cam.pitch a * -(ry - ε*ry/Math.abs ry)
		if ε < Math.abs lb
			@cam.roll a * lb
		if ε < Math.abs rb
			@cam.roll a * -rb
	
	update : (fi, dt) ->
		@gamepad0 = gamepad.update fi, dt
		#@stats.update()
		@cam.update fi, dt
		#@heightMap.update fi, dt
		#@voxelGrid.update fi, dt
		# movement update
		
		#@physWorld.update fi, dt
		return
	
	draw : ->
		{rndr, cam} = @
		mLoop = @loop
		
		# calc viewprojection matrix from cam
		
		# stats
		#@ffiBar.textContent = mLoop.fixedFrameIndex
		#@fiBar.textContent = mLoop.frameIndex
		unless mLoop.fixedFrameIndex % 6
			@fpsBar.textContent = mLoop.fps | 0
			
		rndr.preRender cam
		
		#@heightMap.draw rndr, cam
		#@voxelGrid.draw rndr, cam
		#@physWorld.draw rndr, cam
		@satWorld.draw rndr, cam
		
		rndr.postRender()
		return



