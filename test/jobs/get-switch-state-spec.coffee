{job} = require '../../jobs/get-switch-state'

describe 'GetSwitchState', ->
  context 'when given a valid message', ->
    beforeEach (done) ->
      @connector =
        getBinaryState: sinon.stub().yields null, 0
      message = {}
      @sut = new job {@connector}
      @sut.do message, (@error, @response) =>
        done()

    it 'should not error', ->
      expect(@error).not.to.exist

    it 'should call connector.getBinaryState', ->
      expect(@connector.getBinaryState).to.have.been.called

    it 'should return the current state', ->
      expect(@response.data.binaryState).to.equal 0
