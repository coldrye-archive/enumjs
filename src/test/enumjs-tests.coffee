###
 * Copyright 2011 axn software UG (haftungsbeschränkt)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
###

vows = require 'vows'
assert = require 'assert'

vows.describe('Basic Tests').addBatch({

	'When require()d':
		topic: () -> 
			require('../lib/enumjs.js')
		'the source must compile': (topic) ->
			assert.isNotNull topic
		'the Enum export must be available': (topic) ->
			assert.isTrue 'Enum' of topic
		'Enum must be a class function': (topic) -> 
			assert.isFunction topic.Enum
		'Enum must not be instantiatable': (topic) ->
			assert.throws (-> topic.Enum()), TypeError
		'Enum.create() must be available': (topic) ->
			assert.isFunction topic.Enum.create

	'Enum.create() must fail':
		topic: () ->
			require('../lib/enumjs.js').Enum
		'with a TypeError on an empty arguments list' : (topic) ->
			assert.throws (-> topic.create()), TypeError
		'with a TypeError on an empty declaration' : (topic) ->
			assert.throws (-> topic.create {}), TypeError
		'with a TypeError on an invalid declaration' : (topic) ->
			assert.throws (-> topic.create "invalid"), TypeError
			assert.throws (-> topic.create ["invalid"]), TypeError
			assert.throws (-> topic.create { CONST1 : "invalid" }), TypeError
		'with a TypeError on duplicate ordinals' : (topic) ->
			assert.throws (-> topic.create { CONST1 : 5, CONST2 : 4, CONST3 : 0 }), TypeError
			assert.throws (-> topic.create { CONST1 : 1, CONST2 : 2, CONST3 : 1 }), TypeError
			assert.throws (-> topic.create { CONST1 : 1, CONST2 : 1 }), TypeError
			assert.throws (-> topic.create { CONST1 : { ordinal : 1 }, CONST2 : 2, CONST3 : { ordinal : 1 } }), TypeError
			assert.throws (-> topic.create { CONST1 : { ordinal : "a2" }, CONST2 : 1, CONST3 : { ordinal : 0 } }), TypeError
		'with a TypeError on invalid constant literals' : (topic) ->
			assert.throws (-> topic.create { "CON ST1" : 0 }), TypeError
			assert.throws (-> topic.create { "53CONST1" : 0 }), TypeError

	'Inheritance and prevention of instantiation':
		topic: () ->
			Enum = require('../lib/enumjs.js').Enum
			Enum.create { A : 1, B : 0, C : 0 }
		'The enum class cannot be instantiated' : (topic) ->
			assert.throws (-> topic()), TypeError
		'The Enum class cannot be instantiated' : (topic) ->
			Enum = require('../lib/enumjs.js').Enum
			assert.throws (-> Enum()), TypeError
		'values() must not be an instance method' : (topic) ->
			assert.isUndefined topic.A.values
			assert.typeOf topic.values, 'function'
		'enum is a subclass of Enum' : (topic) ->
			Enum = require('../lib/enumjs.js').Enum
			assert.equal topic.super_, Enum
		'enum constants are instances of enum' : (topic) ->
			Enum = require('../lib/enumjs.js').Enum
			assert.instanceOf topic.A, topic
			assert.instanceOf topic.A, Enum 
			assert.instanceOf topic.B, topic
			assert.instanceOf topic.B, Enum 
		'valueOf() class method is different from valueOf() instance method' : (topic) ->
			assert.notStrictEqual topic.valueOf, topic.A.valueOf 
			assert.notStrictEqual topic.valueOf, topic.B.valueOf 
		'subclasses of Enum have no create() factory method' : (topic) ->
			assert.isUndefined topic.create 
# nice to have but not possible with existing implementations of extends/inherits
#		'subclasses of Enum cannot be inherited from' : (topic) ->
#			assert.throws (-> class t extends topic), TypeError
#			util = require "util"
#			assert.throws (-> f = -> {}; util.inherits f, Enum), TypeError

	'Instance methods valueOf() and values()':
		topic: () ->
			Enum = require('../lib/enumjs.js').Enum
			Enum.create { A : 1, B : 0, C : 0 }
		'values() returns array of length 3' : (topic) ->
			assert.equal 3, topic.values().length
		'array returned by values() contains all of the declared enum constants in arbitrary order' : (topic) ->
			values = topic.values()
			assert.isTrue topic.A in values
			assert.isTrue topic.B in values
			assert.isTrue topic.C in values
		'valueOf() returns correct constants' : (topic) ->
			assert.strictEqual topic.A, topic.valueOf('A')
			assert.strictEqual topic.A, topic.valueOf(1)
			assert.strictEqual topic.B, topic.valueOf('B')
			assert.strictEqual topic.B, topic.valueOf(2)
			assert.strictEqual topic.C, topic.valueOf('C')
			assert.strictEqual topic.C, topic.valueOf(3)

	'When an enum is create()d properly using only integers':
		topic: () ->
			Enum = require('../lib/enumjs.js').Enum
			Enum.create { A : 1, B : 0, C : 0 }
		'instance method valueOf() must return correct enum constant' : (topic) ->
			assert.doesNotThrow (-> topic.A.valueOf()), TypeError
			assert.doesNotThrow (-> topic.A.valueOf('0')), TypeError
			assert.doesNotThrow (-> topic.A.valueOf('Z')), TypeError
			assert.equal topic.A.valueOf(), topic.A.ordinal()
			assert.equal topic.A.valueOf('0'), topic.A.ordinal()
			assert.equal topic.A.valueOf('Z'), topic.A.ordinal()
		'class method valueOf() must throw TypeError on undefined, unknown ordinal or unknown constant literal' : (topic) ->
			assert.throws (-> topic.valueOf()), TypeError
			assert.throws (-> topic.valueOf(0)), TypeError
			assert.throws (-> topic.valueOf('Z')), TypeError
		'valueOf() must comply to the official protocol' : (topic) ->
			assert.doesNotThrow (-> topic.A.valueOf()), TypeError
			assert.isNumber topic.A.valueOf()
			assert.equal 1, topic.A.valueOf()
		'The minimum ordinal is one (1)' : (topic) ->
			assert.isTrue topic.A.ordinal() == 1
		'The ordinals are all in sequence' : (topic) ->
			assert.isTrue topic.A.ordinal() == 1
			assert.isTrue topic.B.ordinal() == 2
			assert.isTrue topic.C.ordinal() == 3

	'When an enum is create()d properly using object notation only':
		topic: () ->
			Enum = require('../lib/enumjs.js').Enum
			Enum.create { A : { ordinal : 0 }, B : { ordinal : 0 }, C : {} }
		'The minimum ordinal is one (1)' : (topic) ->
			assert.isTrue topic.A.ordinal() == 1
		'The ordinals are all in sequence' : (topic) ->
			assert.isTrue topic.A.ordinal() == 1
			assert.isTrue topic.B.ordinal() == 2
			assert.isTrue topic.C.ordinal() == 3

	'When an enum is create()d properly mixing object notation and integers':
		topic: () ->
			Enum = require('../lib/enumjs.js').Enum
			Enum.create { A : { ordinal : 0 }, B : 2, C : { ordinal : 0 } }
		'The minimum ordinal is one (1)' : (topic) ->
			assert.isTrue topic.A.ordinal() == 1
		'The ordinals are all in sequence' : (topic) ->
			assert.isTrue topic.A.ordinal() == 1
			assert.isTrue topic.B.ordinal() == 2
			assert.isTrue topic.C.ordinal() == 3

	'When an enum is create()d properly with custom ordinals':
		topic: () ->
			Enum = require('../lib/enumjs.js').Enum
			Enum.create { A : 100, B : { ordinal : 49 }, C : 0 }
		'The minimum ordinal is 49' : (topic) ->
			assert.isTrue topic.B.ordinal() == 49
			assert.isTrue topic.A.ordinal() > topic.B.ordinal()
			assert.isTrue topic.C.ordinal() > topic.B.ordinal()
		'There is a gap of 50 between the ordinals of A and C, with B and C being in sequence' : (topic) ->
			assert.isTrue (topic.A.ordinal() - topic.C.ordinal()) == 50
			assert.isTrue (topic.C.ordinal() - topic.B.ordinal()) == 1

	'Custom constructor':
		topic: () ->
			Enum = require('../lib/enumjs.js').Enum
			Enum.create({ 
				ctor: (inverse) ->
					try
						@_inverse = this.self_.valueOf(inverse)
					catch e
						@_inverse = this
				statics :
					inverse : (value) ->
						this.self_.valueOf(value).inverse()
				instance :
					inverse : () ->
						return @_inverse
				A : 
					construct : ['B']
					ordinal : 0
				B :
					construct : ['A']
					ordinal : 2
				C : 0
			})
		'Custom static class fields are available' : (topic) ->
			assert.isTrue 'inverse' of topic
		'Custom static class fields work as expected' : (topic) ->
			assert.strictEqual topic.B, topic.inverse topic.A.name()
			assert.strictEqual topic.A, topic.inverse topic.B.name()
			assert.strictEqual topic.C, topic.inverse topic.C.name()
		'Custom instance fields are available' : (topic) ->
			assert.isTrue 'inverse' of topic.A
			assert.isTrue 'inverse' of topic.B
			assert.isTrue 'inverse' of topic.C
			assert.isTrue '_inverse' of topic.A
			assert.isTrue '_inverse' of topic.B
			assert.isTrue '_inverse' of topic.C
		'Custom instance method works as expected' : (topic) ->
			assert.strictEqual topic.B, topic.A.inverse()
			assert.strictEqual topic.A, topic.B.inverse()
			assert.strictEqual topic.C, topic.C.inverse()

}).export(module)

