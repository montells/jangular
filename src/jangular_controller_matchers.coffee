'use strict'

################################
# jangular controller matchers #
################################

common = require './jangular_common'

expect_to_be_function = common.expect_to_be_function
validate_arguments_count = common.validate_arguments_count
validate_arguments_gt = common.validate_arguments_gt

assert_is_spy = (_spy) ->
  throw new Error "Expected a spy, but got #{jasmine.pp _spy}." unless jasmine.isSpy _spy

q = ->
  _q = undefined
  inject ($q) -> _q = $q
  _q

spy_have_been_called = (_spy) ->
  pass = _spy.calls.any()
  result =
    pass: pass
    message: pass ? "Expected spy #{_spy.and.identity()} not to have been called.": "Expected spy #{_spy.and.identity()}  to have been called.'"

spy_have_been_called_with = (_spy, args) ->
  result =
    pass: false
  pass = _spy.calls.any()
  unless pass
    result.message = ->
      "Expected spy #{_spy.and.identity()} to have been called with #{jasmine.pp(args)} but it was never called."
  else
    if jasmine.matchersUtil.contains _spy.calls.allArgs(), args, jasmine.customEqualityTesters
      result.pass = true
      result.message = ->
        "Expected spy #{_spy.and.identity()} not to have been called with #{jasmine.pp(args)} but it was."
    else
      result.message = -> "Expected spy #{_spy.and.identity()} to have been called with #{jasmine.pp(args)} but actual calls were #{jasmine.pp(_spy.calls.allArgs()).replace(/^\[ | \]$/g, '')}."
  result

to_call_service = ->
  compare: (fn, service, fn_name) ->

    # validations
    validate_arguments_count arguments, 3, 'to_call_service takes only 2 arguments: target service to spy on and the function name'
    expect_to_be_function fn

    # spy on service
    _spy = spyOn service, fn_name
    assert_is_spy _spy

    # spy on service and return a solved promise
    deferred = q().defer()
    deferred.resolve()
    _spy.and.returnValue deferred.promise

    # make the call
    fn()

    # assert
    spy_have_been_called _spy

to_call_service_with = ->
  compare: (fn, service, fn_name, args...) ->
    validate_arguments_gt arguments, 3, 'to_call_service_with takes 3 or more arguments: target service to spy on, the function name and the expected arguments'
    expect_to_be_function fn

    # spy on service
    _spy = spyOn service, fn_name
    assert_is_spy _spy

    # spy on service and return a solved promise
    deferred = q().defer()
    deferred.resolve()
    _spy.and.returnValue deferred.promise

    # make the call
    fn()

    # assert
    spy_have_been_called_with _spy, args

jangular_controller_matchers =
  to_call_service: to_call_service
  toCallService: to_call_service
  to_call_service_with: to_call_service_with
  toCallServiceWith: to_call_service_with

module.exports = jangular_controller_matchers
