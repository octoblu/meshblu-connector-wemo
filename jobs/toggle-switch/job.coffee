http = require 'http'

class ToggleSwitch
  constructor: ({@connector}) ->
    throw new Error 'ToggleSwitch requires connector' unless @connector?

  do: ({data}, callback) =>
    return callback @_userError(422, 'data.on is required') unless data?.on?

    return @connector.turnOn callback if data.on

    @connector.turnOff callback

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = ToggleSwitch
