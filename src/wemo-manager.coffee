_              = require 'lodash'
{EventEmitter} = require 'events'
WemoClient     = require 'wemo-client'
debug           = require('debug')('meshblu-connector-wemo:wemo-manager')

class WemoManager extends EventEmitter
  constructor: ->
    @wemo = new WemoClient

  discover: ({wemoName, autoDiscover}) =>
    return if wemoName == @wemoName && autoDiscover == @autoDiscover
    { @wemoName, @autoDiscover } = { wemoName, autoDiscover }
    @client = null
    @discovering = true
    debug 'discovering...'
    @wemo.discover @_onDiscover

  isOnline: (callback) =>
    return callback null, running: !!@client

  _onDiscover: (device) =>
    return debug 'missing device' unless device?
    { deviceType } = device
    if deviceType != WemoClient.DEVICE_TYPE.Switch
      return debug 'invalid device type'
    if !@autoDiscover && device.friendlyName != @wemoName
      return debug('name doesn\'t match', device.friendlyName, @wemoName)
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
    return callback new Error 'No current WeMo connection' unless @client
    @client.once 'binaryState', => callback()
    @client.setBinaryState state

module.exports = WemoManager
