http = require 'http'

class SampleJob
  constructor: ({@connector}) ->
    throw new Error 'SampleJob requires connector' unless @connector?

  do: ({data}, callback) =>
    return callback @_userError(422, 'data.on is required') unless data?.on?

    return @connector.turnOn callback if data.on

    @connector.turnOff callback

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = SampleJob
