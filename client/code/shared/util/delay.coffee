defer = require './defer'

module.exports = ( ms ) ->
	deferred = defer()
	setTimeout ( -> deferred.resolve ms ), ms
	return deferred.promise
