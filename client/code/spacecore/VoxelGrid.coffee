'use strict'

plato = require '/plato'
PerlinNoise = require '/util/PerlinNoise'
glm = require '/gl-matrix'

log = console.log.bind console, '[voxelgrid]'

COLOR_TERRAIN = glm.vec4.fromValues 0.3,0.2,0.05,1.0

SPACE = 0
MATTER = 1

VOID = 0
QUAD = 1
TRI_SW = 2
TRI_SE = 3
TRI_NW = 4
TRI_NE = 5

# lookup table for speeding up cell pattern calculations
mask2pattern = [
	VOID
	TRI_SW
	TRI_SE
	QUAD
	TRI_NW
	QUAD
	QUAD
	QUAD
	TRI_NE
	QUAD
	QUAD
	QUAD
	QUAD
	QUAD
	QUAD
	QUAD
]


class VoxelGrid extends plato.Unit3D
	module.exports = @
	
	constructor : (gl) ->
		super()
		
		@w = 128
		@h = 128
		
		@right -@w/2
		@up -@h/2
		@forward @w
		
		@perlin = new PerlinNoise 'spacecore'
		
		@grid = new Uint8Array (@w+1) * (@h+1)
		
		@maxPointVertsN = (@w+1) * (@h+1)
		@maxMeshVertsN = 3 * 2 * (@w) * (@h)
		
		@gridItemsN = 0
		@zeroItemsN = 0
		@meshItemsN = 0
		
		@shaderHandle = 'passthru'
		shader = plato.createShader gl, @shaderHandle
		gl.useProgram shader.program
		@gridBuffer = new plato.Buffer gl, gl.ARRAY_BUFFER, gl.STREAM_DRAW, gl.FLOAT, shader.vert, 3, @maxPointVertsN
		@zeroBuffer = new plato.Buffer gl, gl.ARRAY_BUFFER, gl.STREAM_DRAW, gl.FLOAT, shader.vert, 3, @maxPointVertsN
		@meshBuffer = new plato.Buffer gl, gl.ARRAY_BUFFER, gl.STREAM_DRAW, gl.FLOAT, shader.vert, 3, @maxMeshVertsN
		@initGrid()
		@initZero()
		@initMesh()
		@zeroBuffer.bind()
		@zeroBuffer.bufferSubData()
		@meshBuffer.bind()
		@meshBuffer.bufferSubData()
	
	initGrid : ->
		# build voxel grid
		{grid,h,w} = @
		i = 0
		for y in [0...h+1] by 1
			for x in [0...w+1] by 1
				m = @materialAt x,y
				grid[i] = m
				if m is MATTER
					@initGridCell i++,x,y
		@gridItemsN = i
		log 'grid', @gridItemsN, @maxPointVertsN
	
	initGridCell : (i,x,y) ->
		i *= 3
		@gridBuffer.buffer[i++] = x
		@gridBuffer.buffer[i++] = y
		@gridBuffer.buffer[i++] = 0.1
	
	initZero : ->
		# build zero crossing point grid
		{grid,h,w} = @
		i = 0
		for y in [0...h] by 1
			for x in [0...w] by 1
				i = @initZeroCell i,x,y
		@zeroItemsN = i
		log 'zero', @zeroItemsN, @maxPointVertsN
	
	initZeroCell : (i,x,y) ->
		return i unless @isZeroCrossing x,y
		j = i * 3
		@zeroBuffer.buffer[j++] = x + 0.5
		@zeroBuffer.buffer[j++] = y + 0.5
		@zeroBuffer.buffer[j++] = 0.1
		return i+1
	
	initMesh : ->
		# build mesh cells
		{grid,h,w} = @
		i = 0
		for y in [0...h] by 1
			for x in [0...w] by 1
				i = @initMeshCell i,x,y
		@meshItemsN = i
		log 'mesh', @meshItemsN, @maxMeshVertsN, @meshBuffer
		
	initMeshCell : (i,x,y) ->
		mask = 0
		mask += 1 if @materialAt x,y
		mask += 2 if @materialAt x+1,y
		mask += 4 if @materialAt x,y+1
		mask += 8 if @materialAt x+1,y+1
		pattern = mask2pattern[mask]
		switch pattern
			when QUAD
				@vert i++,x,y
				@vert i++,x+1,y
				@vert i++,x,y+1
				
				@vert i++,x,y+1
				@vert i++,x+1,y
				@vert i++,x+1,y+1
			when TRI_SW
				@vert i++,x,y
				@vert i++,x+1,y
				@vert i++,x,y+1
			when TRI_SE
				@vert i++,x+1,y+1
				@vert i++,x,y
				@vert i++,x+1,y
			when TRI_NW
				@vert i++,x,y+1
				@vert i++,x,y
				@vert i++,x+1,y+1
			when TRI_NE
				@vert i++,x,y+1
				@vert i++,x+1,y
				@vert i++,x+1,y+1
		return i
	
	vert : (i,x,y) ->
		i *= 3
		@meshBuffer.buffer[i++] = x
		@meshBuffer.buffer[i++] = y
		@meshBuffer.buffer[i++] = 0
	
	# TODO place this somewhere appropriate
	dd = 8
	mm = 0.1
	
	materialAt : (x,y) ->
		# TODO lots to optimize
		r1 = 60
		r2 = r1 + 4
		x += dd * @perlin.noise2d mm*x, mm*y
		y += dd * @perlin.noise2d mm*y, mm*x
		return if (x-r2)*(x-r2) + (y-r2)*(y-r2) < r1*r1 then MATTER else SPACE
	
	isZeroCrossing : (x,y) ->
		v0 = @materialAt x,y
		return true if v0 isnt @materialAt x+1, y
		return true if v0 isnt @materialAt x, y+1
		return true if v0 isnt @materialAt x+1, y+1
		return false
	
	draw : (rndr, cam) ->
		{gl} = rndr
		shader = rndr.setShader @shaderHandle
		
		gl.uniformMatrix4fv shader.pMat, false, cam.perspective
		gl.uniformMatrix4fv shader.vMat, false, cam.view
		gl.uniformMatrix4fv shader.mMat, false, @matrix
		
		###
		# TODO only do this if any part of the data has changed
		@gridBuffer.bind()
		@gridBuffer.bufferSubData()
		gl.uniformMatrix4fv shader.pMat, false, cam.perspective
		gl.uniformMatrix4fv shader.vMat, false, cam.view
		gl.uniformMatrix4fv shader.mMat, false, @matrix
		gl.uniform4fv shader.mClr, glm.vec4.fromValues 1,1,1,1
		gl.drawArrays gl.POINTS, 0, @gridItemsN
		###
		
		###
		@zeroBuffer.bind()
		#@zeroBuffer.bufferSubData()
		gl.uniform4fv shader.mClr, glm.vec4.fromValues 1,0,0,1
		gl.drawArrays gl.POINTS, 0, @zeroItemsN
		###
		
		#
		# TODO send a vec4 instead of vec3 for verts where last value represents texture index
		# this way we can give surfaces and quads different looks by switching textures
		# also, z-values can be removed since z will ALWAYS be 0
		#
		# Turn grid into chunks
		# At an early stage scale chunks into lower poly versions when camera goes far away
		# (Camera goes far away as speed increases)
		# Somehow we need to assert that not more than a certain amount of verts are being drawn
		# Simplify drawing of filled chunks as just a single quad
		# create a cached/predefined buffer with just one quad representing the filled chunks
		# this cached buffer can be shared between different voxelgrids, just be aware of perhaps different colors n'stuff
		#
		# The chunks should only contain data about removed points
		# The chunks are only recalculated when changed
		#
		# How to calculate collisions with chunks?
		# Do chunks have to overlap?
		#
		# Also; water at a base radius?
		# Shine around voxel grids (atmosphere)?
		# Parallax background?
		#
		
		@meshBuffer.bind()
		#@meshBuffer.bufferSubData()
		gl.uniform4fv shader.mClr, COLOR_TERRAIN
		gl.drawArrays gl.TRIANGLES, 0, @meshItemsN




