### ###

class Screen extends require './Command'
	'use strict'
	module.exports = this
	
	@help : 'enter/exit fullscreen'
	
	_onExecute : ->
		switch @_payload[0]
			when 'full'   then @_output.enterFullscreen()
			when 'window' then @_output.exitFullscreen()
			else @_output.toggleFullscreen()
