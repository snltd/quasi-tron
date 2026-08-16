(local registry (require :util.phase-registry))
(local draw (require :select-components.draw))
(local setup (require :select-components.setup))
(local keypress (require :select-components.keypress))

(local self {:draw draw.component-list
             :keypress keypress.handler
             :launch setup.launch})

(registry.register! :select-components self)
self
