'use strict'

Prng = require './Prng'

grad = (arrays) ->
	new Int8Array array for array in arrays

grad3 = grad [
	# 2*12 edges
	[ 0, 1, 1 ]
	[ 0, 1,-1 ]
	[ 0,-1, 1 ]
	[ 0,-1,-1 ]
	[ 1, 0, 1 ]
	[ 1, 0,-1 ]
	[-1, 0, 1 ]
	[-1, 0,-1 ]
	[ 1, 1, 0 ]
	[ 1,-1, 0 ]
	[-1, 1, 0 ]
	[-1,-1, 0 ]
	
	[ 0, 1, 1 ]
	[ 0, 1,-1 ]
	[ 0,-1, 1 ]
	[ 0,-1,-1 ]
	[ 1, 0, 1 ]
	[ 1, 0,-1 ]
	[-1, 0, 1 ]
	[-1, 0,-1 ]
	[ 1, 1, 0 ]
	[ 1,-1, 0 ]
	[-1, 1, 0 ]
	[-1,-1, 0 ]
	
	# 8 corners
	[ 1, 1, 1 ]
	[ 1, 1,-1 ]
	[ 1,-1, 1 ]
	[-1, 1, 1 ]
	[ 1,-1,-1 ]
	[-1, 1,-1 ]
	[-1,-1, 1 ]
	[-1,-1,-1 ]
]

class PerlinNoise
	module.exports = @
	
	constructor : (@seed) ->
		@permutations = new Uint8Array 512
		@prng = new Prng @seed
		
		# build sorted permutation array
		i = 256; while i--
			@permutations[i] = i
		
		# shuffle permuation array fisher-yates style
		# simultaineously copy first half to second half
		i = 256; while --i
			j = @prng.random() * (i+1) | 0 # truncation
			k = @permutations[i]
			@permutations[i] = @permutations[i+256] = @permutations[j]
			@permutations[j] = @permutations[j+256] = k
	
	noise1d : (x) ->
		p = @permutations
		ix = x | 0
		dx = x - ix
		ix &= 255
		fx = (3-2*dx)*dx*dx
		g0 = 1 - p[ix] / 127.5
		g1 = 1 - p[ix+1] / 127.5
		n0 = g0*dx
		n1 = g1*(dx-1)
		return n0 + fx*(n1-n0)
	
	noise2d : (x,y) ->
		p = @permutations
		
		# truncate, extract integer parts (gradient positions)
		ix = x | 0
		iy = y | 0
		
		# extract decimal part
		dx = x - ix
		dy = y - iy
		
		# limit values to int range [, 255]
		ix &= 255
		iy &= 255
		
		# blend decimal parts
		fx = (3-2*dx)*dx*dx
		fy = (3-2*dy)*dy*dy
		
		# get all adjacent gradient vectors
		g00 = grad3[ p[ix   + p[iy]]   & 31 ]
		g01 = grad3[ p[ix   + p[iy+1]] & 31 ]
		g10 = grad3[ p[ix+1 + p[iy]]   & 31 ]
		g11 = grad3[ p[ix+1 + p[iy+1]] & 31 ]
		
		# dot product, calc noise from each adjacent gradient
		n00 = g00[0]*dx     + g00[1]*dy
		n01 = g01[0]*dx     + g01[1]*(dy-1)
		n10 = g10[0]*(dx-1) + g10[1]*dy
		n11 = g11[0]*(dx-1) + g11[1]*(dy-1)
		
		# 2d lerp, bilinear interpolate noise from all adjacent gradients
		nx0 = n00 + fx*(n10-n00)
		nx1 = n01 + fx*(n11-n01)
		return nx0 + fy*(nx1-nx0)
	
	noise3d : (x,y,z) ->
		p = @permutations
		
		# truncate, extract integer parts (gradient positions)
		ix = x | 0
		iy = y | 0
		iz = z | 0
		
		# extract decimal part
		dx = x - ix
		dy = y - iy
		dz = z - iz
		dx1 = dx - 1
		dy1 = dy - 1
		dz1 = dz - 1
		
		# limit values to int range [, 255]
		ix &= 255
		iy &= 255
		iz &= 255
		ix1 = ix + 1
		iy1 = iy + 1
		iz1 = iz + 1
		
		# blend decimal parts
		fx = (3-2*dx)*dx*dx
		fy = (3-2*dy)*dy*dy
		fz = (3-2*dz)*dz*dz
		
		# get all adjacent gradient vectors
		g000 = grad3[p[ix  + p[iy  + p[iz]]]  & 31]
		g001 = grad3[p[ix  + p[iy  + p[iz1]]] & 31]
		g010 = grad3[p[ix  + p[iy1 + p[iz]]]  & 31]
		g100 = grad3[p[ix1 + p[iy  + p[iz]]]  & 31]
		g011 = grad3[p[ix  + p[iy1 + p[iz1]]] & 31]
		g101 = grad3[p[ix1 + p[iy  + p[iz1]]] & 31]
		g110 = grad3[p[ix1 + p[iy1 + p[iz]]]  & 31]
		g111 = grad3[p[ix1 + p[iy1 + p[iz1]]] & 31]
		
		# dot product, calc noise from each adjacent gradient
		n000 = g000[0]*dx  + g000[1]*dy  + g000[2]*dz
		n001 = g001[0]*dx  + g001[1]*dy  + g001[2]*dz1
		n010 = g010[0]*dx  + g010[1]*dy1 + g010[2]*dz
		n100 = g100[0]*dx1 + g100[1]*dy  + g100[2]*dz
		n011 = g011[0]*dx  + g011[1]*dy1 + g011[2]*dz1
		n101 = g101[0]*dx1 + g101[1]*dy  + g101[2]*dz1
		n110 = g110[0]*dx1 + g110[1]*dy1 + g110[2]*dz
		n111 = g111[0]*dx1 + g111[1]*dy1 + g111[2]*dz1
		
		# 3d lerp, trilinear interpolate noise from all adjacent gradients
		nx00 = n000 + fx*(n100-n000)
		nx01 = n001 + fx*(n101-n001)
		nx10 = n010 + fx*(n110-n010)
		nx11 = n011 + fx*(n111-n011)
		nxy0 = nx00 + fy*(nx10-nx00)
		nxy1 = nx01 + fy*(nx11-nx01)
		return nxy0 + fz*(nxy1-nxy0) # nxyz
