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
