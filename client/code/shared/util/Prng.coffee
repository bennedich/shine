'use strict'

class Prng
	module.exports = @
	
	constructor : (@seed) ->
		@hash = @generateHash @seed
	
	# based on java implementation of hashCode
	# s[0]*31^(n-1) + s[1]*31^(n-2) + ... + s[n-1]
	# source: http://docs.oracle.com/javase/6/docs/api/java/lang/String.html#hashCode()
	generateHash : (seed) ->
		hash = 0
		seed = seed.toString()
		for i in [0...seed.length] by 1
			hash *= 31
			hash += seed.charCodeAt i
			hash %= 0x100000000
		return hash
	
	# based on use of linear congruential generator (lcg) in borland implementation of random()
	# source: http://www.cigital.com/papers/download/developer_gambling.php
	#
	# borland lcg parameters m=2^32, a=134775813, c=1
	# source: ttp://en.wikipedia.org/wiki/Linear_congruential_generator
	random : ->
		@hash *= 134775813
		@hash += 1
		@hash %= 0x100000000
		return @hash / 0x100000000
