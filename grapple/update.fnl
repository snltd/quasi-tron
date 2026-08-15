(local global-state (require :global-state))
(local actions (require :grapple.actions))
(local chooser (require :grapple.chooser))
(local defs (require :grapple.defs))
(local enemy (require :grapple.enemy))
(local state (require :grapple.state))
(local {: set-game-phase!} (require :util.actions))
(local {: pos?} (require :util.helpers))
(local {: keys} (require :global-defs))
(local {: nil? : sum} (require :util.helpers))
(import-macros {: dec! : inc!} :util.macros)

(fn end-grapple-phase []
  (each [_side board (pairs state.board)]
    (each [idx ttl (pairs board.active-cells)]
      (tset board.active-cells idx (- ttl 10000))))
  (set state.time-left 0)
  (let [score (sum state.box-owners)]
    (if (= 0 score) (do
    (set state.deadlock-flash-show true)
    (set state.deadlock-flash-timer 0)
      (set state.phase :deadlock))
        (or (and (< score 0) (= state.enemy-side :right))
            (and (< 0 score) (= state.enemy-side :left)))
        (set-game-phase! :select-components (math.abs score))
        (set-game-phase! :main-game {:injured true}))))

(fn update-deadlock-timer [dt]
  (inc! state.deadlock-flash-timer dt)
  (dec! state.deadlock-timer dt)

  (if state.deadlock-flash-show
    (when (<= 0.9 state.deadlock-flash-timer )
      (set state.deadlock-flash-timer 0)
      (set state.deadlock-flash-show false))
    (when (<= 0.3 state.deadlock-flash-timer )
      (set state.deadlock-flash-timer 0)
      (set state.deadlock-flash-show true)))

  (if (<= state.deadlock-timer 0)
      (set-game-phase! :grapple {:player-pips 3 :enemy-pips 1})))

(fn update-grapple-timer [dt]
  (if (= state.phase :grapple)
  (let [new-time (- state.time-left dt)]
    (if (< new-time 0)
        (end-grapple-phase)
        (set state.time-left new-time)))))

(fn update-board! [dt]
  (each [_side board (pairs state.board)]
    (each [idx ttl (pairs board.active-cells)]
      (local new-ttl (- ttl dt))
      (tset board.active-cells idx new-ttl)
      (if (< new-ttl 0)
          (tset board.active-cells idx nil)))
    (each [i pip (ipairs board.active-pips)]
      (dec! pip.ttl dt)
      (when (not (pos? pip.ttl))
        (tset (. board.paths pip.row) defs.firing-pip-col "─")
        (table.remove board.active-pips i)))))

(fn update-boxes! []
  (set state.box-owners (actions.update-boxes! state.box-owners state.board)))

(fn grapple-key-handler [dt]
  (dec! global-state.key-timer dt)
  (let [held (or (love.keyboard.isDown keys.up)
                 (love.keyboard.isDown keys.down))
        board (. state.board state.player-side)]
    (if held
        (when (or (not global-state.key-held) (<= global-state.key-timer 0))
          (if (love.keyboard.isDown keys.down)
              (actions.pip-down! board defs.board.rows)
              (love.keyboard.isDown keys.up)
              (actions.pip-up! board defs.board.rows))
          (set global-state.key-timer
               (if global-state.key-held keys.repeat-rate keys.repeat-delay))
          (set global-state.key-held true))
        (set global-state.key-held false))))

(fn grapple-update [dt]
  (grapple-key-handler dt)
  (update-boxes!)
  (enemy.move (. state.board state.enemy-side) state.enemy-skills dt))

(fn update [dt]
  (update-board! dt)
  (update-grapple-timer dt)
  (if (= state.phase :grapple) (grapple-update dt)
      (= state.phase :chooser) (chooser.update dt)
      (= state.phase :deadlock) (update-deadlock-timer dt)))

{: update}
