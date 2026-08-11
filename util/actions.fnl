(local grapple (require :grapple))
(local global-state (require :global-state))

(fn set-phase! [phase params]
  (print "setting phase to " phase)
  (set global-state.phase phase)
  (if (= phase :grapple) (grapple.launch params)))

{: set-phase!}
