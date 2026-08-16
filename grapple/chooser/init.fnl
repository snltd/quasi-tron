(local state (require :grapple.chooser.state))
(local draw (require :grapple.chooser.draw))
(local update (require :grapple.chooser.update))
(local keypress (require :grapple.chooser.keypress))
(local setup (require :grapple.chooser.setup))

{:launch setup.launch
 : state
 :update update.update
 :keypress keypress.handler
 : draw}
