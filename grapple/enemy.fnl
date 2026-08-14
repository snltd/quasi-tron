(local action (require :grapple.actions))
(local state (require :grapple.state))
; (local global-defs (require :global-defs))
(local defs (require :grapple.defs))
(local {: array-contains? : pos? : nil?} (require :util.helpers))
(import-macros {: dec!} :util.macros)

;; Simple straight path for now. We could follow paths properly.
(fn straight-to-our-colour? [board-side box-owners]
  (let [row board-side.pip-row
        owner (. box-owners row)
        path (. board-side.paths row)]
    (and (= owner board-side.id) (array-contains? path "◀"))))

(fn via-inverter? [board-side]
  (let [path (. board-side.paths board-side.pip-row)]
    (array-contains? path :S)))

(fn dead-end? [board-side]
  (let [path (. board-side.paths board-side.pip-row)]
    (array-contains? path "◁")))

(fn waste-of-a-pip? [board-side box-owners]
  (or (dead-end? board-side) (via-inverter? board-side)
      (straight-to-our-colour? board-side box-owners)))

(fn move [board-side enemy-skills dt]
  (dec! state.enemy-move-timer dt)
  (when (<= state.enemy-move-timer 0)
    (if (and (not= 0 board-side.pip-row)
             (<= (math.random) enemy-skills.fire-prob))
        (if (not (and (<= (math.random) enemy-skills.smarts)
                      (waste-of-a-pip? board-side state.box-owners)))
            (action.fire! board-side)))
    (when (<= (math.random) enemy-skills.move-prob)
      (if (< (math.random) enemy-skills.dir-prob)
          (action.pip-down! board-side defs.board.rows)
          (action.pip-up! board-side defs.board.rows)))
    (set state.enemy-move-timer enemy-skills.speed)))

; (set state.enemy-move-timer
;    (if state.enemy-move-lock state.enemy.-rate keys.repeat-delay))
; (action.pip-up! board-side state.board.rows)
; (set state.enemy-move-timer state.enemy-move-interval)))
; (< n 50)
;   (action.pip-down! board rows)
; (and (< n 80) (pos? board.pips) (pos? board.pip-row))
;   (action.fire! board))))
; (<= state.enemy-move-timer 0)

{: move}
