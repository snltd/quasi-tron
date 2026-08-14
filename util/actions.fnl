(local global-state (require :global-state))
(local registry (require :util.phase-registry))

(fn set-phase! [phase params]
  (set global-state.phase phase)
  (let [phase-module (registry.get phase)]
    (when (and phase-module phase-module.launch)
      (phase-module.launch params))))

{: set-phase!}
