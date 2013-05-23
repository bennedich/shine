'use strict'

{vec4} = require '/gl-matrix'

module.exports =
	# WHITE
	WHITE : vec4.fromValues 1,1,1,1
	
	# BLACK
	BLACK : vec4.fromValues 0,0,0,1

	GREEN : vec4.fromValues 0,.6,0,1

	# RED
	BRIGHT_RED : vec4.fromValues 1,0,0,1
	RED : vec4.fromValues .6,0,0,1
	DARK_RED : vec4.fromValues .4,0,0,1
