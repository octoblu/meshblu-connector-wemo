{afterEach, beforeEach, describe, it} = global
{expect} = require 'chai'
sinon = require 'sinon'

Connector = require '../'

describe 'Connector', ->
  beforeEach (done) ->
    @sut = new Connector
    {@wemo} = @sut
    @sut.start {}, done
    @wemo.emit 'connected'
    @wemo.isOnline = sinon.stub().yields null, {running: true}

  afterEach (done) ->
    @sut.close done

  describe '->isOnline', ->
    it 'should yield running true', (done) ->
      @sut.isOnline (error, response) =>
        return done error if error?
        expect(response.running).to.be.true
        done()

  describe '->getBinaryState', ->
    beforeEach (done) ->
      @wemo.getBinaryState = sinon.stub().yields null, 1
      @sut.getBinaryState (error, @binaryState) =>
        done error

    it 'should call wemo.getBinaryState', ->
      expect(@wemo.getBinaryState).to.have.been.called

    it 'should return the binaryState', ->
      expect(@binaryState).to.equal 1

  describe '->getInsightParams', ->
    beforeEach (done) ->
      @wemo.getInsightParams = sinon.stub().yields null, 1, 2, {
        ONSince: 1470236236
        OnFor: 2183
        TodayONTime: 4284
        TodayConsumed: 16437160
      }
      @sut.getInsightParams (error, @binaryState, @instantPower, @insightParams) =>
        done error

    it 'should call wemo.getInsightParams', ->
      expect(@wemo.getInsightParams).to.have.been.called

    it 'should return the binaryState, instantPower, and insightParams', ->
      expect(@binaryState).to.equal 1
      expect(@instantPower).to.equal 2
      expect(@insightParams).to.deep.equal {
        ONSince: 1470236236
        OnFor: 2183
        TodayONTime: 4284
        TodayConsumed: 16437160
      }

  describe '->turnOff', ->
    beforeEach (done) ->
      @wemo.turnOff = sinon.stub().yields null
      @sut.turnOff done

    it 'should call wemo.turnOff', ->
      expect(@wemo.turnOff).to.have.been.called

  describe '->turnOn', ->
    beforeEach (done) ->
      @wemo.turnOn = sinon.stub().yields null
      @sut.turnOn done

    it 'should call wemo.turnOn', ->
      expect(@wemo.turnOn).to.have.been.called

  describe '->onConfig', ->
    describe 'when called with a config', ->
      it 'should not throw an error', ->
        expect(=> @sut.onConfig { type: 'hello' }).to.not.throw(Error)
