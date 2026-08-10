; (local { : paths } (require :grapple.paths))
; (local {: flatten} (require :util.helpers))
(local actions (require :grapple.actions))
(local draw (require :grapple.draw))
(local load (require :grapple.load))
(local update (require :grapple.update))

{:load load.load :draw draw.board :update update.update :fire actions.fire}
