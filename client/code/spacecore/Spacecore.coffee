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

class SatBox extends plato.Unit2D
	__t1mat2d = mat2d.create() # intermediate storage
	__t1mat4 = mat4.create() # intermediate storage

	constructor : (gl, x, y, @w, @h) ->
		super()
		@w2 = 0.5 * @w
		@h2 = 0.5 * @h
		@right x
		@up y
		
		@shaderHandle = 'passthru'
		shader = plato.createShader gl, @shaderHandle
		gl.useProgram shader.program
		@buffer = new plato.Buffer gl, gl.ARRAY_BUFFER, gl.STREAM_DRAW, gl.FLOAT, shader.vert, 3, 4
		@addVert 0, -@w2, -@h2
		@addVert 1,  @w2, -@h2
		@addVert 2, -@w2,  @h2
		@addVert 3,  @w2,  @h2

	addVert : (i,x,y) ->
		i *= 3
		@buffer.buffer[i] = x
		@buffer.buffer[i+1] = y
		@buffer.buffer[i+2] = -0.1
	
	fixedUpdate : (ffi) ->
		# {matrix} = @
		#@rotate 0.01
		#@lastX = matrix[X4]
		#@lastY = matrix[Y4]
		#@matrix[X4] = @nextX
		#@matrix[Y4] = @nextY

	draw : (rndr, cam) ->
		{buffer} = @
		{gl} = rndr
		shader = rndr.setShader @shaderHandle

		if @parent?
			modelMatrix = mat2d.mul __t1mat2d, @matrix, @parent.matrix
		else
			modelMatrix = @matrix

		gl.uniformMatrix4fv shader.pMat, false, cam.perspective
		gl.uniformMatrix4fv shader.vMat, false, cam.view
		gl.uniformMatrix4fv shader.mMat, false, @matrix4 modelMatrix
		gl.uniform4fv shader.mClr, RED
		#gl.uniform1f shader.mSize, @h * rndr.h * cam.perspective[0]
		buffer.bind()
		buffer.bufferSubData()
		gl.drawArrays gl.TRIANGLE_STRIP, 0, 4

class SkyBox2D extends plato.Unit2D
	constructor : (gl, image) ->
		super()

		@rawW = image.width
		@rawH = image.height
		@rawAspect = @rawW / @rawH

		@w = 1.6
		@h = 1
		@w2 = 0.8
		@h2 = 0.5

		@shaderHandle = 'skybox2d'
		shader = plato.createShader gl, @shaderHandle
		gl.useProgram shader.program
		
		@texture = new plato.Texture gl, image

		@textureBuffer = new plato.Buffer gl, gl.ARRAY_BUFFER, gl.STATIC_DRAW, gl.FLOAT, shader.texture_coords, 2, 4
		@setVert @textureBuffer.buffer, 0, 0, 0
		@setVert @textureBuffer.buffer, 1, 1, 0
		@setVert @textureBuffer.buffer, 2, 0, 1
		@setVert @textureBuffer.buffer, 3, 1, 1
		@textureBuffer.bufferSubData()
		@vertBuffer = new plato.Buffer gl, gl.ARRAY_BUFFER, gl.STATIC_DRAW, gl.FLOAT, shader.vert, 2, 4

	setVert : (buffer, i, x, y) ->
		i *= 2
		buffer[i] = x
		buffer[i+1] = y

	draw : (rndr, cam) ->
		{textureBuffer, vertBuffer} = @
		{gl} = rndr
		shader = rndr.setShader @shaderHandle
		
		if rndr.canvasResized
			w2 = Math.max 1, @rawAspect / rndr.aspect
			h2 = Math.max 1, rndr.aspect / @rawAspect
			@setVert @vertBuffer.buffer, 0, -w2, -h2
			@setVert @vertBuffer.buffer, 1,  w2, -h2
			@setVert @vertBuffer.buffer, 2, -w2,  h2
			@setVert @vertBuffer.buffer, 3,  w2,  h2
			vertBuffer.bind()
			@vertBuffer.bufferSubData()

		# TODO should be able to use more than TEXTURE0
		gl.activeTexture gl.TEXTURE0
		gl.bindTexture gl.TEXTURE_2D, @texture.texture
		gl.uniform1i shader.texture_skybox, 0
		
		#textureBuffer.bind()
		#textureBuffer.bufferSubData()

		vertBuffer.bind()
		gl.drawArrays gl.TRIANGLE_STRIP, 0, 4

class Fudge
	constructor : (gl, image) ->
		@shaderHandle = 'passthru'
		shader = plato.createShader gl, @shaderHandle
		gl.useProgram shader.program


class Spacecore
	module.exports = @
	
	constructor : (@selector) ->
		@fixedUpdate = @fixedUpdate.bind @
		@update = @update.bind @
		@draw = @draw.bind @
		
		# config stats env
		@initAssets()
	
	initAssets : ->
		#
		@i = new Image
		@i.onload = =>
			@initStats()
			@initCore()
			@initScene()
			@start()
		@i.src = '/images/my_little_pony_night_sky_base_by_theblackyofthedark.jpg'
	
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
		@voxelGrid = new VoxelGrid gl
		#@initPhysWorld()
		#@initSatWorld()
		@skybox = new SkyBox2D gl, @i
		#@satbox = new SatBox gl, 0.2, 0.6, 2, 2

	
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
		@voxelGrid.fixedUpdate ffi
		#@physWorld.fixedUpdate ffi
		#@satWorld.fixedUpdate ffi
	
	
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
		@voxelGrid.update fi, dt
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
		@voxelGrid.draw rndr, cam
		#@physWorld.draw rndr, cam
		#@satWorld.draw rndr, cam
		@skybox.draw rndr, cam
		#@satbox.draw rndr, cam
		
		rndr.postRender()
		return



