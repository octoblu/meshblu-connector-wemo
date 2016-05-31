{EventEmitter}  = require 'events'
_               = require 'lodash'
WemoClient      = require 'wemo-client'
debug           = require('debug')('meshblu-connector-wemo:index')

class Wemo extends EventEmitter
  constructor: ->
    @wemo = new WemoClient

  isOnline: (callback) =>
    callback null, running: !!@client

  close: (callback) =>
    debug 'on close'
    callback()

  onMessage: (message={}) =>
    unless @client?
      return @emit 'message', devices: ['*'], topic: 'status', payload: status: 'not-ready'

    return unless message.payload?
    { metadata, data } = message.payload
    return unless metadata?
    return unless data?
    { jobType } = metadata
    return unless jobType?
    return debug 'invalid jobType' unless jobType == 'toggleSwitch'
    debug 'running jobType', jobType, data.on
    onState = 0 unless data.on
    onState = 1 if data.on
    @client.setBinaryState onState

  onConfig: (device={}) =>
    debug 'on config'
    { wemoName, autoDiscover } = device.options ? {}
    @client = null if wemoName != @wemoName
    @client = null if autoDiscover != @autoDiscover
    @wemoName = wemoName
    @autoDiscover = autoDiscover
    @discover() unless @discovering

  onDiscover: (device) =>
    return debug 'missing device' unless device?
    { deviceType } = device
    if deviceType != WemoClient.DEVICE_TYPE.Switch
      return debug 'invalid device type'
    if !@autoDiscover && device.friendlyName != @wemoName
      return debug('name doesn\'t match', device.friendlyName, @wemoName)
    @discovering = false
    debug 'discovered', device.friendlyName
    @client = @wemo.client device
    @client.on 'binaryState', (value) =>
      debug 'got binaryState', value
      online = true if value == '1'
      online = false unless value == '1'
      @emit 'message', devices: ['*'], topic: 'status', payload: { status: 'state-change', online }

  discover: =>
    @discovering = true
    return if @client?
    _.delay @discover, 10000
    debug 'discovering...'
    @wemo.discover @onDiscover

  start: (device) =>
    @onConfig device
    @discover() unless @discovering

module.exports = Wemo
