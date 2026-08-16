(local global-defs (require :global-defs))
(local global-state (require :global-state))
(local state (require :select-components.state))
(local defs (require :select-components.defs))
(local {: set-game-phase!} (require :util.actions))
(local {: nil? : not-nil?} (require :util.helpers))
(import-macros {: dec! : inc!} :util.macros)

(fn select-component [component-type]
  (if (not-nil? (. state.components component-type))
      (if (< (math.random 7) state.grapple-score)
          (do
            (tset global-state.player.components component-type
                  (. state.components component-type))
            (tset state.components component-type "INTERFACED"))
          (tset state.components component-type "DAMAGED"))))

(fn handler [key]
  (let [cr defs.component-rows
        row state.active-row
        keys global-defs.keys]
    (if (= key keys.fire)
        (if (= row defs.exit-row) (set-game-phase! :city)
            (= row cr.drive) (select-component :drive)
            (= row cr.power) (select-component :power)
            (= row cr.weapon) (select-component :weapon)
            (= row cr.chassis) (select-component :chassis)
            (= row cr.devices) (select-component :devices))
        (= key keys.down)
          (if (not= row cr.devices) (inc! state.active-row 2))
        (= key keys.up)
          (if (not= row defs.exit-row) (dec! state.active-row 2)))))

{: handler}
