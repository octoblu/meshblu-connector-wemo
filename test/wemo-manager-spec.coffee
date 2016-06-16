UUID = require 'uuid'
WemoClient = require 'wemo-client'
WemoManager = require '../src/wemo-manager'
{EventEmitter} = require 'events'

describe 'WemoManager', ->
  beforeEach ->
    @sut = new WemoManager
    {@wemo} = @sut
    @wemo.discover = sinon.stub()
    @wemo.client = sinon.stub()

  describe '->getBinaryState', ->
    context 'when there is a client', ->
      beforeEach ->
        @sut.client =
          getBinaryState: sinon.stub().yields null, '1'

      it 'should yield 1', (done) ->
        @sut.getBinaryState (error, state) =>
          return done error if error?
          expect(state).to.equal 1
          done()

    context 'when there is no client', ->
      beforeEach ->
        @sut.client = null

      it 'should yield an error', (done) ->
        @sut.getBinaryState (error) =>
          expect(error).to.exist
          done()

  describe '->turnOn', ->
    context 'when there is a client', ->
      beforeEach (done) ->
        @client = new EventEmitter
        @client.setBinaryState = sinon.stub()
        @sut.client = @client
        @sut.turnOn done
        @client.emit 'binaryState', 1

      it 'should call setBinaryState', ->
        expect(@sut.client.setBinaryState).to.have.been.calledWith 1

    context 'when there is no client', ->
      beforeEach ->
        @sut.client = null

      it 'should yield an error', (done) ->
        @sut.turnOn (error) =>
          expect(error).to.exist
          done()

  describe '->turnOff', ->
    context 'when there is a client', ->
      beforeEach (done) ->
        @client = new EventEmitter
        @client.setBinaryState = sinon.stub()
        @sut.client = @client
        @sut.turnOff done
        @client.emit 'binaryState', 0

      it 'should call setBinaryState', ->
        expect(@sut.client.setBinaryState).to.have.been.calledWith 0

    context 'when there is no client', ->
      beforeEach ->
        @sut.client = null

      it 'should yield an error', (done) ->
        @sut.turnOff (error) =>
          expect(error).to.exist
          done()

  describe '->isOnline', ->
    context 'when there is a client', ->
      beforeEach ->
        @sut.client = {}

      it 'should be online', (done) ->
        @sut.isOnline (error, {running}) =>
          return done error if error?
          expect(running).to.be.true
          done()

    context 'when there is no client', ->
      beforeEach ->
        @sut.client = null

      it 'should be offline', (done) ->
        @sut.isOnline (error, {running}) =>
          return done error if error?
          expect(running).to.be.false
          done()

  describe '->discover', ->
    context 'when looking for a client', ->
      context 'when there is no client', ->
        beforeEach ->
          wemoName = 'foo'
          autoDiscover = false
          @sut.discover {wemoName, autoDiscover}

        it 'should start discovering', ->
          expect(@sut.discovering).to.be.true

        it 'should call wemo.discover', ->
          expect(@wemo.discover).to.have.been.called

        context 'when the correct client has been discovered', ->
          beforeEach (done) ->
            @client = {}
            @wemo.client.returns @client
            device =
              deviceType: WemoClient.DEVICE_TYPE.Switch
              friendlyName: 'foo'
            @sut.on 'connected', done
            @sut._onDiscover device

          it 'should stop discovering', ->
            expect(@sut.discovering).to.be.false

          it 'should create a client', ->
            expect(@sut.client).to.deep.equal @client

    context 'when auto discovering', ->
      context 'when there is no client', ->
        beforeEach ->
          wemoName = null
          autoDiscover = true
          @sut.discover {wemoName, autoDiscover}

        it 'should start discovering', ->
          expect(@sut.discovering).to.be.true

        it 'should call wemo.discover', ->
          expect(@wemo.discover).to.have.been.called

        context 'when the correct client has been discovered', ->
          beforeEach (done) ->
            @client = {}
            @wemo.client.returns @client
            device =
              deviceType: WemoClient.DEVICE_TYPE.Switch
              friendlyName: UUID.v4()
            @sut.on 'connected', done
            @sut._onDiscover device

          it 'should stop discovering', ->
            expect(@sut.discovering).to.be.false

          it 'should create a client', ->
            expect(@sut.client).to.deep.equal @client
