# This file automatically gets called first by SocketStream and must always exist

# Make 'ss' available to all modules and the browser console
window.ss = require('socketstream')

ss.server.on 'disconnect', ->
  console.log('Connection down :-(')

ss.server.on 'reconnect', ->
  console.log('Connection back up :-)')

###
ss.server.on 'ready', ->

# Wait for the DOM to finish loading
jQuery ->

  # Load app
  require('/app')
###

do ->
	log = console.log.bind console, '[env]'
	
	init = (key) ->
		lock[key] = true
		return unless (lock.every (key) -> key)
		log 'inited environment'
		log 'loading scripts'
		#window.util = require '/util'
		#window.shine = require '/shine'
		#window.cli = new shine.Cli('#myTerm');
		
		window.kaos = require '/kaos'
		window.os = kaos.boot()
		
		
		#window.Cli = require '/cli'
		#window.cli = new Cli '#ascii'
	
	key = {}
	key[k] = i for k, i in ['SERVER', 'CLIENT', 'ENV']
	lock = (false for _ of key)
	
	ss.server.on 'ready', ->
		log 'server ready'
		init key.SERVER
		ss.rpc 'ss.env', (env) ->
			ss.env = env
			init key.ENV
	
	window.addEventListener 'load', ->
		log 'client ready'
		init key.CLIENT
