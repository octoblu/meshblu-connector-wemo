{job} = require '../../jobs/toggle-switch'

describe 'ToggleSwitch', ->
  context 'when given an `on` message', ->
    beforeEach (done) ->
      @connector =
        turnOn: sinon.stub().yields null
      message =
        data:
          on: true
      @sut = new job {@connector}
      @sut.do message, (@error) =>
        done()

    it 'should not error', ->
      expect(@error).not.to.exist

    it 'should call connector.turnOn', ->
      expect(@connector.turnOn).to.have.been.called

  context 'when given an `off` message', ->
    beforeEach (done) ->
      @connector =
        turnOff: sinon.stub().yields null
      message =
        data:
          on: false
      @sut = new job {@connector}
      @sut.do message, (@error) =>
        done()

    it 'should not error', ->
      expect(@error).not.to.exist

    it 'should call connector.turnOff', ->
      expect(@connector.turnOff).to.have.been.called

  context 'when given an invalid message', ->
    beforeEach (done) ->
      @connector = {}
      message = {}
      @sut = new job {@connector}
      @sut.do message, (@error) =>
        done()

    it 'should error', ->
      expect(@error).to.exist
