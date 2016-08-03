_              = require 'lodash'
{EventEmitter} = require 'events'
WemoClient     = require '@octoblu/wemo-client'
debug           = require('debug')('meshblu-connector-wemo:wemo-manager')

class WemoManager extends EventEmitter
  constructor: ->
    @wemo = new WemoClient
    @client = null

  discover: ({wemoName, autoDiscover}) =>
    return if wemoName == @wemoName && autoDiscover == @autoDiscover && @client?
    { @wemoName, @autoDiscover } = { wemoName, autoDiscover }
    @client = null
    @discovering = true
    debug 'discovering...'
    @wemo.discover @_onDiscover

  getBinaryState: (callback) =>
    return callback new Error 'No current WeMo connection' unless @client?
    @client.getBinaryState (error, state) =>
      return callback error if error?
      callback null, parseInt(state)

  getInsightParams: (callback) =>
    return callback new Error 'No current WeMo connection' unless @client?
    unless @client.deviceType == WemoClient.DEVICE_TYPE.Insight
      return callback new Error 'GetInsightParams is not supported on this device. Only Insight devices are supported.'
    @client.getInsightParams (error, state, instantPower, insightParams) =>
      return callback error if error?
      callback null, parseInt(state), parseInt(instantPower), {
        ONSince:       parseInt(insightParams.ONSince)
        OnFor:         parseInt(insightParams.OnFor)
        TodayONTime:   parseInt(insightParams.TodayONTime)
        TodayConsumed: parseInt(insightParams.TodayConsumed)
      }

  isOnline: (callback) =>
    return callback null, running: !!@client

  _onDiscover: (device) =>
    return debug 'missing device' unless device?
    { deviceType } = device
    {Switch, Insight} = WemoClient.DEVICE_TYPE
    if !_.includes [Switch, Insight], deviceType
      return debug 'invalid device type', deviceType
    if !@autoDiscover && device.friendlyName != @wemoName
      return debug('name doesn\'t match', JSON.stringify(device.friendlyName), JSON.stringify(@wemoName))
    @discovering = false
    debug 'discovered', device.friendlyName
    @client = @wemo.client device
    @_emitConnected()

  _emitConnected: =>
    @emit 'connected'

  turnOn: (callback) =>
    @_changeState state: 1, callback

  turnOff: (callback) =>
    @_changeState state: 0, callback

  _changeState: ({state}, callback) =>
    callback = _.once callback
    return callback new Error 'No current WeMo connection' unless @client?
    timeout = setTimeout =>
      callback new Error 'Timed out waiting for state to change'
    , 5000
    @client.once 'binaryState', =>
      clearTimeout timeout
      callback()

    @client.setBinaryState state

module.exports = WemoManager
