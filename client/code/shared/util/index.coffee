'use strict'

module.exports =
	Key			: require './key'
	EventEmitter		: require './EventEmitter'
	Error			: require './Error'
	NotImplementedError	: require './NotImplementedError'
	defer			: require './defer'
	delay			: require './delay'
	Widget			: require './Widget'

module.exports.log = console.log.bind console, "[#{document.title}]"

module.exports.to_array = -> Array.prototype.slice.apply arguments
