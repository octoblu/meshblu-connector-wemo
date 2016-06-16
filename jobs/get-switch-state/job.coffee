http = require 'http'

class GetSwitchState
  constructor: ({@connector}) ->
    throw new Error 'GetSwitchState requires connector' unless @connector?

  do: (message, callback) =>
    @connector.getBinaryState (error, state) =>
      return callback error if error?

      metadata =
        code: 200
        status: http.STATUS_CODES[200]

      data =
        binaryState: state

      return callback null, {metadata, data}

module.exports = GetSwitchState
