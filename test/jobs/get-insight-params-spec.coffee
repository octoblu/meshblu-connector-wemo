{beforeEach, context, describe, it} = global
{expect} = require 'chai'
sinon = require 'sinon'

{job} = require '../../jobs/get-insight-params'

describe 'getInsightParams', ->
  context 'when given a valid message', ->
    beforeEach (done) ->
      @connector =
        getInsightParams: sinon.stub().yields(null, 1, 234275, {
          ONSince: 1470236236
          OnFor: 2183
          TodayONTime: 4284
          TodayConsumed: 16437160
        })
      message = {}
      @sut = new job {@connector}
      @sut.do message, (@error, @response) =>
        done()

    it 'should not error', ->
      expect(@error).not.to.exist

    it 'should call connector.getInsightParams', ->
      expect(@connector.getInsightParams).to.have.been.called

    it 'should return the insightParams', ->
      expect(@response.data.binaryState).to.equal 1
      expect(@response.data.instantPower).to.equal 234275
      expect(@response.data.insightParams).to.deep.equal {
        ONSince: 1470236236
        OnFor: 2183
        TodayONTime: 4284
        TodayConsumed: 16437160
      }
