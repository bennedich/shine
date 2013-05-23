
BOX = 0
TRI = 1
CIR = 2

class SatWorld
	#module.exports = @
	
	# intermediate storage
	__t1vec2 = vec2.create()
	__t1mat2d = mat2d.create()

	constructor : (gl) ->
		@world = []
		@world_n = 0
		
		@points = [
			new SatPoint gl, -1.7, -1
			new SatPoint gl, -1.9, -1.5
			new SatPoint gl, -2.1, -1.2
			new SatPoint gl, -1.9, -0.8
			new SatPoint gl, -2.2, -1.5
		]
		
		@planet = new plato.Unit2D
		@planet.add new SatBox gl, 0.2, 0.6, 2, 2
		@planet.up 1
		@planet.right 1
		@planet.rotate -0.2
		
		@textElement = document.createElement 'p'
	
	add : (unit) ->
		@world.push unit
		++@world_n
		return unit
	
	fixedUpdate : (ffi) ->
		{world, world_n} = @
		
		@planet.rotate 0.03

		# broad phase
		# narrow phase
		
		###
		for i in [0...world_n] by 1
			unit = world[i]
			x = unit.matrix[X4]
			y = unit.matrix[Y4]
			nextX = unit.nextX
			nextY = unit.nextY
		###
		
		#n0 = world[0]
		#n1 = world[1]
		
		# direction from n0 -> n1
		#dx = n1.matrix[X4] - n0.matrix[X4]
		#dy = n1.matrix[Y4] - n0.matrix[Y4]
		
		# 
		# iterate over object with most projection vectors
		# cache every 
		
		
		# calculate projection vectors from n0
		#b0 = n0.body
		#b0.
		
		
		
		# project n1 axes onto n0 axes
		#b1 = n1.body
		
		### ###
		# after broad phase a planet object has been pinpointed
		# calculate inverse world matrix of planet
		{planet} = @
		planetWorldMatrix = planet.matrix
		planetInverseWorldMatrix = mat2d.invert __t1mat2d, planetWorldMatrix
		planetX = planetWorldMatrix[X2]
		planetY = planetWorldMatrix[Y2]
		
		# iterate over all active collision points (ships?)
		for point in @points
			# transform ship into planet space (multiply ship world pos by planet inverse world matrix)
			pointWorldMatrix = point.matrix
			pointWorldMatrix[X2] += 0.01

			__t1vec2[X] = pointWorldMatrix[X2]
			__t1vec2[Y] = pointWorldMatrix[Y2]
			pointPlanetPosition = vec2.transformMat2d __t1vec2, __t1vec2, planetInverseWorldMatrix
			pX = pointPlanetPosition[X]
			pY = pointPlanetPosition[Y]
			
			# do some smart intersection calculation so we end up with a box/boxes or similar collision primitives
			box = planet.units[0]
			bX = box.matrix[X2]
			bY = box.matrix[Y2]
			
			dX = pX - bX
			signX = if dX < 0 then -1 else 1
			penetrationX = box.w2 - signX * dX

			dY = pY - bY
			signY = if dY < 0 then -1 else 1
			penetrationY = box.h2 - signY * dY

			if penetrationX > 0 and penetrationY > 0
				if penetrationX < penetrationY
					#console.log "INTERSECT X"
					__t1vec2[X] = signX * penetrationX
					__t1vec2[Y] = 0
				else
					#console.log "INTERSECT Y"
					__t1vec2[X] = 0
					__t1vec2[Y] = signY * penetrationY
				vec2.transformMat2 __t1vec2, __t1vec2, planetWorldMatrix
				pointWorldMatrix[X2] += __t1vec2[X]
				pointWorldMatrix[Y2] += __t1vec2[Y]

#			# TODO rotate applied position
#			if penetrationX < penetrationY and box.w2 < Math.abs penetrationX
#				#pointWorldMatrix[X4] += penetrationX
#			else if box.h2 < Math.abs penetrationY
#				#pointWorldMatrix[Y4] += penetrationY
		
		# after broad phase a planet object has been pinpointed
		# calculate inverse world matrix of planet
		# transform ship into planet space (multiply ship world pos by planet inverse world matrix)
		# do some smart intersection calculation
		# continue unless intersection
		# solve intersections
		# apply resulting forces

		for box in @planet.units
			box.fixedUpdate ffi

	draw : (rndr, cam) ->
		for box in @planet.units
			box.draw rndr, cam
		for point in @points
			point.draw rndr, cam


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

		modelMatrix = @matrix4 mat2d.mul __t1mat2d, @matrix, @parent.matrix

		gl.uniformMatrix4fv shader.pMat, false, cam.perspective
		gl.uniformMatrix4fv shader.vMat, false, cam.view
		gl.uniformMatrix4fv shader.mMat, false, modelMatrix
		gl.uniform4fv shader.mClr, RED
		#gl.uniform1f shader.mSize, @h * rndr.h * cam.perspective[0]
		buffer.bind()
		buffer.bufferSubData()
		gl.drawArrays gl.TRIANGLE_STRIP, 0, 4


class SatPoint extends plato.Unit2D
	constructor : (gl, x, y) ->
		super()
		@right x
		@up y
		
		@shaderHandle = 'point_square'
		shader = plato.createShader gl, @shaderHandle
		gl.useProgram shader.program
		@buffer = new plato.Buffer gl, gl.ARRAY_BUFFER, gl.STREAM_DRAW, gl.FLOAT, shader.vert, 3, 1
	
	fixedUpdate : (ffi) ->
		#{matrix} = @
		#@lastX = matrix[X4]
		#@lastY = matrix[Y4]
		#@matrix[X4] = @nextX
		#@matrix[Y4] = @nextY
	
	draw : (rndr, cam) ->
		{buffer} = @
		{gl} = rndr
		shader = rndr.setShader @shaderHandle
		gl.uniformMatrix4fv shader.pMat, false, cam.perspective
		gl.uniformMatrix4fv shader.vMat, false, cam.view
		gl.uniformMatrix4fv shader.mMat, false, @matrix4()
		gl.uniform4fv shader.mClr, GREEN
		gl.uniform1f shader.mSize, 0.1 * rndr.h
		buffer.bind()
		buffer.bufferSubData()
		gl.drawArrays gl.POINTS, 0, 1


class SatTri extends plato.Unit3D
	constructor : ->
