http = require 'http'

class GetInsightParams
  constructor: ({@connector}) ->
    throw new Error 'GetInsightParams requires connector' unless @connector?

  do: (message, callback) =>
    @connector.getInsightParams (error, binaryState, instantPower, insightParams) =>
      return callback error if error?

      metadata =
        code: 200
        status: http.STATUS_CODES[200]

      data = {binaryState, instantPower, insightParams}

      return callback null, {metadata, data}

module.exports = GetInsightParams
