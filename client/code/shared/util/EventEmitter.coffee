###
###
'use strict'

class EventEmitter
	module.exports = this
	
	constructor : ->
		@_lstnrs = {}
	
	on : (e, lstnr) ->
		@_lstnrs[e] = [] unless @_lstnrs.hasOwnProperty e
		@_lstnrs[e].push lstnr
		return
	
	off : (e, lstnr) ->
		i = @_lstnrs[e].indexOf lstnr
		i < 0 or @_lstnrs[e].splice i, 1
		return
	
	emit : (e, args...) ->
		return unless @_lstnrs.hasOwnProperty e
		lstnr.apply null, args for lstnr in @_lstnrs[e]
		return
