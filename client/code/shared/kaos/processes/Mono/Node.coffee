'use strict'

class Node
	module.exports = this
	__uid = 0
	
	constructor : (@x=0, @y=0) ->
		@uid = ++__uid
		@parent = null
		@nodes = {}

	add : (node) ->
		unless node.parent is null
			node.parent.remove node
		@nodes[node.uid] = node
		node.parent = this
		return node

	remove : (node) ->
		return null unless @nodes.hasOwnProperty node.uid
		delete @nodes[node.uid]
		node.parent = null
		return node
	
	translate : (x, y) ->
		@x += x
		@y += y
		return
	
	fixedUpdate : (fixedFrameIndex) ->
	update : (frameIndex, deltaTime) ->
	draw : (renderer, camera) ->


class Node.Camera extends Node


class Node.Text extends Node
	constructor : (@str='', x, y) ->
		super x, y
	
	draw : (rndr, cam) ->
		rndr.drawText @str, @x-cam.x, @y-cam.y


class Node.Image extends Node
	constructor : (@asciiBitmap, @w, @h) ->
		super()
	
	draw : (rndr, cam) ->
		rndr.drawAscii @asciiBitmap, @w, @h, @x-cam.x, @y-cam.y
