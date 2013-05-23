'use strict'
{INTERVAL} = require '/kaos/kernel/step'

module.exports =
	INTERVAL : INTERVAL
	MAX_DELTA : 5 * INTERVAL
	STARTED : 0
	STOPPED : 1
	FIXED_UPDATE : 2
	UPDATE : 3
	DRAW : 4
