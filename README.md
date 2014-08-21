Versal Gadget API
================

This is a collection of everything needed to create a Versal gadget.
Install this as a bower component and import this package's `index.html`.

##To use:##

###As a component (let the bower package load it's own dependencies via html imports):###

In your gadget directory: `bower install versal-gadget-api versal-component-runtime`

In the `<head>` of your your gadget's `versal.html`:

`<script src="bower_components/versal-gadget-api/versal-component-runtime/dist/runtime.min.js"></script>`

`<html rel="import" href="bower_components/versal-gadget-api/index.html"/>`

###As vanilla JS/CSS:###

In you gadget directory: `bower install versal-gadget-api`

In the `<head>` of your gadget's `versal.html`:

`<script src="bower_components/underscore/underscore.js"></script>`

`<script src="bower_components/eventEmitter/EventEmitter.js"></script>`

`<script src="bower_components/versal-gadget-api/player-api/index.js"></script>`

`<script src="bower_components/versal-gadget-api/challenges-js-api/challenges_iframe_api.js"></script>`

Optional CSS steps:

`<link rel="stylesheet" href="bower_components/normalize-css/normalize.css"/>`

`<link rel="stylesheet" href="bower_components/versal-gadget-api/gadget-theme/index.css"/>`
