'use strict'
plato = require '/plato'

{RIGHT_X, UP_X, FORWARD_X, POS_X, POS_Y, POS_Z} = plato.unitAux
{INTERVAL} = plato.loopAux

TIME_MODIFIER = 1e6
G = 6.674e-11
SQUARED_INTERVAL = INTERVAL * INTERVAL * 1e-6
GRAV_MOD = G * SQUARED_INTERVAL * TIME_MODIFIER

Y = new Float32Array 1
I = new Int32Array Y.buffer

class PhysicsWorld
	module.exports = @
	
	constructor : ->
		@world = []
		@world_n = 0
		
	add : (unit) ->
		@world.push unit
		++@world_n
		return unit
	
	fixedUpdate : (ffi) ->
		{world, world_n} = @
		
		_y = Y
		_i = I
		
		for i in [0...world_n] by 1
			unit = world[i]
			x = unit.matrix[POS_X]
			y = unit.matrix[POS_Y]
			nextX = unit.nextX
			nextY = unit.nextY
			mass = unit.mass
			massModifier = mass * GRAV_MOD
			
			#individual forces such as acceleration have alreadly been applied outside this class
			#inherent velocity and forces such as inertia and gravity are applied here
			
			### INERTIA ###
			
			nextX += x - unit.lastX
			nextY += y - unit.lastY
			
			
			### GRAVITY ###
			
			for j in [i+1...world_n] by 1
				next = world[j]
				# distance vector from unit -> next
				dx = next.matrix[POS_X] - x
				dy = next.matrix[POS_Y] - y
				squaredDistance = dx*dx + dy*dy
			
				continue if squaredDistance < 2e-2
			
				#inverseDistance = 1 / Math.sqrt squaredDistance
				# instead do 'fast inverse sqrt'
				_y[0] = squaredDistance
				_i[0] = 0x5f3759df - (_i[0] >> 1)
				inverseDistance = _y[0]
				inverseDistance = inverseDistance * (1.5 - 0.5 * squaredDistance*inverseDistance*inverseDistance)
				
				#normalize dx,dy to convey only direction from unit -> previous
				dx *= inverseDistance
				dy *= inverseDistance
			
				#force = G * unit.mass * otherunit.mass / squareDistance
				unitS = next.mass * GRAV_MOD / squaredDistance
				nextS = massModifier / squaredDistance
				
				nextX += unitS * dx
				nextY += unitS * dy
				next.nextX += nextS * -dx
				next.nextY += nextS * -dy
			
			unit.nextX = nextX
			unit.nextY = nextY
			unit.fixedUpdate ffi
			#
			#check for collisions with all forthcoming units
			#react to collision
			#register collision on other object
			#
			#broad phase
			#narrow phase
			#actual collision
			
			
		
	
	update : (fi, dt) ->
		{world} = @
		for unit in world
			unit.update fi, dt
	
	draw : (rndr, cam) ->
		{world} = @
		for unit in world
			unit.draw rndr, cam


