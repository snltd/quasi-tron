(local registry (require :util.phase-registry))
(local draw (require :city.draw))
(local update (require :city.update))

(local self { :draw draw.level
             :update update.update
})
; (local self {:launch setup.launch
;              :fire actions.fire!
;              :keypress keypress.handler})

(registry.register! :grapple self)
self
