(local actions (require :grapple.actions))
(local draw (require :grapple.draw))
(local keypress (require :grapple.keypress))
(local setup (require :grapple.setup))
(local update (require :grapple.update))

{:launch setup.launch
 :draw draw.board
 :update update.update
 :fire actions.fire
 :keypress keypress.handler}
