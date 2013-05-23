window.ss = require 'socketstream'
Spacecore = require '/Spacecore'


key = {}
key[k] = i for k, i in ['SERVER', 'CLIENT', 'ENV']
lock = (false for _ of key)
log = console.log.bind console, '[env]'


ss.server.on 'disconnect', ->
	console.log 'Connection down :-('

ss.server.on 'reconnect', ->
	console.log 'Connection back up :-)'

ss.server.on 'ready', ->
	log 'server ready'
	init key.SERVER
	ss.rpc 'ss.env', (env) ->
		ss.env = env
		init key.ENV

window.addEventListener 'load', ->
	log 'client ready'
	init key.CLIENT



init = (key) ->
	lock[key] = true
	return unless (lock.every (key) -> key)
	log 'env inited'
	log 'loading scripts'
	
	window.debug = document.querySelector '#debug_output'
	window.s = new Spacecore '#main'

###
Devlog 2013

Mar 31
------
Implemented basic gamepad support.

Apr 1
-----
During my US visit (came back yesterday) I got a height map up and running in
WebGL and also a 2D voxel grid with basic meshing. Today was last day of easter
and I pieced together a crude mesh smoothing algorithm for the voxel meshing.
The next goal is to turn grids into chunks and scale them based on camera
distance.

One concern is the sudden freezes. They are most likely caused by the GC. It's
likely we create a lot of glm vectors and also (not to forget!) strings. A
vector cache would be a good idea.

Below are some thoughts so far all concerning VoxelGrid.coffee:

- Send a vec4 instead of vec3 for verts where last value represents texture index
  this way we can give surfaces and quads different looks by switching textures
  also, z-values can be removed since z will ALWAYS be 0

- Turn grid into chunks
- At an early stage scale chunks into lower poly versions when camera goes far away
  (Camera goes far away as speed increases)
- Somehow we need to assert that not more than a certain amount of verts are being drawn
- Simplify drawing of filled chunks as just a single quad
- Create a cached/predefined buffer with just one quad representing the filled chunks
  this cached buffer can be shared between different voxelgrids, just be aware of perhaps different colors n'stuff

- The chunks should only contain data about removed points
- The chunks are only recalculated when changed

- How to calculate collisions with chunks?
- Do chunks have to overlap?

- Also; water at a base radius?
- Shine around voxel grids (atmosphere)?
- Parallax background? Procedurally rendered?

###


