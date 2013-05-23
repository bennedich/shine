###
- A `promise` is an object which controls deferred operations. `promise`
  has two methods; `then` and `fin`. `then` returns a new `promise`.
  See usage below.
- A `deferred` is a function returning a promise.

Example usage:

	startSpinner()
	getData()
		.then( getRelatedData )
		.then( calcData )
		.then( fadeInData, err )
		.fin( stopSpinner )

- A promise is initially uninitialized
- Once .then(...) has been invoked the promise becomes initialized
- If .then(...) is invoked after initialization/resolve/reject an error
  is thrown
- If resolve/reject is invoked on a already resolved/rejected promise the
  invokation will silently end prematurely
- If resolve/reject is invoked on an uninitialized promise the promise
  will adapt the new state and end prematurely (because there are no
  listeners binded)
- A resolve propagates to the following promise
- A reject propagates until the first onFail callback is found
- Should there be a third route for propagation pacing without
  consideration to resolve/reject until a .fin(...) is run into?

If promise is already resolved/rejected and a new attempt is made it will
just be ignored. This makes it far easier to let deferred requests timeout
without having to deal with the case of multiple resolves/rejects.
###

TIMEOUT_DELAY = 1



module.exports = defer = ->
	return new Deferred



defer.asPromise = ( val ) ->
	deferred = defer()
	setTimeout ( -> deferred.resolve val ), TIMEOUT_DELAY
	return deferred.promise



defer.asDeferred = ( fn ) ->
	return ( args... ) ->
		deferred = defer()
		setTimeout ( ->
			try
				resp = fn.apply null, args
				deferred.resolve resp
			catch err
				deferred.reject err
		), TIMEOUT_DELAY
		return deferred.promise



defer.when = ( promises... ) ->
	### `when` is a deferred function which accepts an arbitrary amount of
		arguments and finishes when all args have been processed.
		
		If an error occurs all other arguments will still be processed,
		but `count` won't increase therefore preventing resolution.
		
		promises can be: promises, deferreds, functions, objects
	###
	deferred = defer()
	count = 0
	len = promises.length
	resps = []
	
	promises.forEach ( promise, i ) ->
		if promise instanceof Function
			try
				promise = promise()
			catch err
				setTimeout ( -> deferred.reject err ), TIMEOUT_DELAY
				return
		
		unless promise instanceof Promise
			promise = defer.asPromise promise
		
		tryResolve = ( resp ) ->
			resps[ i ] = resp
			++count
			return unless count is len
			deferred.resolve resps
		
		promise.then tryResolve, deferred.reject
	
	return deferred.promise



class PromiseError extends require './Error'

	states : [
		'uninitialized'
		'initialized'
		'resolved'
		'rejected'
	]

	constructor : ( promise, reason ) ->
		state = @states[ promise.state() ]
		return super "Promise #{ state }: #{ reason }"



class AbstractDeferred
	UNINITIALIZED	: 0
	INITIALIZED	: 1
	RESOLVED	: 2
	REJECTED	: 3
		


class Promise extends AbstractDeferred
	state	: null
	then	: null
	fin	: null



class Deferred extends AbstractDeferred
	
	constructor : ->
		@promise = new Promise
		@_state = @UNINITIALIZED
		@_deferred = null
		@_onDone = null
		@_onFail = null
		@_onFin = null
		
		@promise.state = =>
			return @_state
		
		@promise.then = ( onDone, onFail=null ) =>
			if @_state > @UNINITIALIZED
				throw new PromiseError this, 'not uninitialized'
			@_setState @INITIALIZED
			@_deferred = defer()
			@_onDone = onDone
			@_onFail = onFail
			return @_deferred.promise
		
		@promise.fin = ( onFin ) =>
			if @_state > @UNINITIALIZED
				throw new PromiseError this, 'not uninitialized'
			@_setState @INITIALIZED
			@_onFin = onFin
			return
	
	
	_setState : ( state ) ->
		@_state = state
	
	
	state : ->
		return @_state
	
	
	resolve : ( resp ) =>
		return if @_state > @INITIALIZED
		if @_state is @UNINITIALIZED
			@_setState @RESOLVED
			return
		@_setState @RESOLVED
		if @_onFin
			@_onFin()
			return
		try
			resp = @_onDone resp
		catch err
			@_deferred.reject err
		if resp instanceof Promise
			resp.then @_deferred.resolve, @_deferred.reject
		else
			@_deferred.resolve resp
		return
	
	
	reject : ( err ) =>
		return if @_state > @INITIALIZED
		if @_state is @UNINITIALIZED
			@_setState @REJECTED
			return
		@_setState @REJECTED
		if @_onFail
			@_onFail err
			deferred = this
			while deferred = deferred._deferred
				onFin = deferred._onFin
			onFin() if onFin
		else if @_deferred
			@_deferred.reject err
		else if @_onFin
			@_onFin()
		return





