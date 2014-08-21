assert = chai.assert

describe 'supported commands', ->
  papi = null
  postMessage = null

  beforeEach ->
    postMessage = sinon.spy()
    papi = new VersalPlayerAPI(eventSource: { postMessage })

  it 'startListening', ->
    papi.startListening()

    assert.deepEqual postMessage.firstCall.args, [{ event: 'startListening' }, '*']

  it 'setHeight', ->
    papi.setHeight(73)

    expectedMessage = { event: 'setHeight', data: { pixels: 73 } }
    assert postMessage.calledWith expectedMessage, '*'

  it 'setAttribute', ->
    papi.setAttribute 'foo', 'bar'

    expectedMessage = { event: 'setAttributes', data: { foo: 'bar'} }
    assert postMessage.calledWith expectedMessage, '*'

  it 'setAttributes', ->
    papi.setAttributes { foo: 'bar'}

    expectedMessage = { event: 'setAttributes', data: { foo: 'bar'} }
    assert postMessage.calledWith expectedMessage, '*'

  it 'setLearnerAttribute', ->
    papi.setLearnerAttribute 'foo', 'bar'

    expectedMessage = { event: 'setLearnerState', data: { foo: 'bar'} }
    assert postMessage.calledWith expectedMessage, '*'

  it 'setLearnerAttributes', ->
    papi.setLearnerAttributes { foo: 'bar'}

    expectedMessage = { event: 'setLearnerState', data: { foo: 'bar'} }
    assert postMessage.calledWith expectedMessage, '*'

  it 'setLearnerState', ->
    papi.setLearnerState { foo: 'bar'}

    expectedMessage = { event: 'setLearnerState', data: { foo: 'bar'} }
    assert postMessage.calledWith expectedMessage, '*'

  it 'setPropertySheetAttributes', ->
    papi.setPropertySheetAttributes { foo: 'bar' }

    expectedMessage =
      event: 'setPropertySheetAttributes',
      data: { foo: 'bar' }
    assert postMessage.calledWith expectedMessage, '*'

  it 'track', ->
    papi.track 'done', { foo: 'bar'}

    expectedMessage = { event: 'track', data: { '@type': 'done', foo: 'bar' } }
    assert postMessage.calledWith expectedMessage, '*'

  it 'error', ->
    papi.error { foo: 'bar'}

    expectedMessage = { event: 'error', data: { foo: 'bar'} }
    assert postMessage.calledWith expectedMessage, '*'

  it 'requestAsset', ->
    papi.requestAsset { type: 'image' }

    expectedMessage = {
      event: 'requestAsset',
      data: { type: 'image', attribute: '__asset__'}
    }
    assert postMessage.calledWith expectedMessage, '*'

  it 'assetUrl', () ->
    papi.handleMessage data: { event: 'environmentChanged', data: { assetUrlTemplate: 'http://asset.com/<%= id %>' } }
    assetUrl = papi.assetUrl 1
    assert.equal assetUrl, 'http://asset.com/1'

  describe 'compatibility', ->

    it 'setEditable was deprecated, and it should NOT trigger anything', ->
      editableChanged = sinon.spy()
      papi.on('editableChanged', editableChanged)
      papi.handleMessage data: { event: 'setEditable', data: { editable: true } }
      assert.equal editableChanged.called, false

  describe 'futures', ->

    it 'requestAsset emits assetSelected', ->
      papi.requestAsset { type: 'image', attribute: 'foo' }
      assetSelected = sinon.spy()
      papi.on 'assetSelected', assetSelected
      papi.handleMessage data: { event: 'attributesChanged', data: { foo: { id: 1 } } }
      assert assetSelected.calledWith { name: 'foo', asset: { id: 1 }}

    it 'requestAsset triggers a callback', ->
      assetSelected = sinon.spy()
      papi.requestAsset { type: 'image', attribute: 'foo' }, assetSelected
      papi.handleMessage data: { event: 'attributesChanged', data: { foo: { id: 1 } } }
      assert assetSelected.calledWith { id: 1 }

  describe 'automatically setting height', ->
    iframe = null
    setHeightWithCSS = (iframe) ->
      iframe.contentWindow.document.body.style = 'height: 300px; padding-top: 10px; border-top: 10px solid black; margin-top: 10px'
    expectedHeight = 300+10+10 # height+padding+border

    beforeEach (done) ->
      startListeningHandler = (event) ->
        return unless event.source == iframe.contentWindow
        if event.data.event == 'startListening'
          window.removeEventListener 'message', startListeningHandler
          done()
      window.addEventListener 'message', startListeningHandler

      iframe = document.createElement 'iframe'
      iframe.setAttribute 'src', '/base/player-api/test/test_gadget.html'
      document.body.appendChild(iframe)

    afterEach ->
      document.body.removeChild(iframe)

    it 'setHeightToBodyHeight sends a setHeight event with the body height', (done) ->
      iframe.style = 'height: 100px'
      setHeightWithCSS(iframe)
      setTimeout (-> iframe.contentWindow.papi.setHeightToBodyHeight()), 0 # defer

      setHeightHandler = (event) ->
        return unless event.source == iframe.contentWindow
        assert.equal event.data.event, 'setHeight'
        assert.equal event.data.data.pixels, expectedHeight
        window.removeEventListener 'message', setHeightHandler
        done()
      window.addEventListener 'message', setHeightHandler

    it 'watchBodyHeight watches height changes', (done) ->
      iframe.style = 'height: 100px'
      interval = iframe.contentWindow.papi.watchBodyHeight()

      setTimeout (-> setHeightWithCSS(iframe)), 50

      setHeightHandler = (event) ->
        return unless event.source == iframe.contentWindow
        assert.equal event.data.event, 'setHeight'
        if event.data.data.pixels == expectedHeight # there are other events before getting the expectedHeight
          iframe.contentWindow.papi.unwatchBodyHeight()
          window.removeEventListener 'message', setHeightHandler
          done()
      window.addEventListener 'message', setHeightHandler


    it 'unwatchBodyHeight stops watching for height changes', (done) ->
      iframe.style = 'height: 100px'
      interval = iframe.contentWindow.papi.watchBodyHeight()
      interval = iframe.contentWindow.papi.unwatchBodyHeight()

      setHeightWithCSS(iframe)

      setHeightHandler = (event) ->
        return unless event.source == iframe.contentWindow
        if event.data.event == 'setHeight' && event.data.data.pixels != 0
          assert false, 'Got an automatic setHeight event while called unwatchBodyHeight'
          done()
      window.addEventListener 'message', setHeightHandler

      finish = ->
        window.removeEventListener 'message', setHeightHandler
        done()
      setTimeout finish, 100
