(local global-state (require :global-state))
(local actions (require :grapple.actions))
(local chooser (require :grapple.chooser))
(local defs (require :grapple.defs))
(local enemy (require :grapple.enemy))
(local state (require :grapple.state))
(local {: set-game-phase!} (require :util.actions))
(local {: keys} (require :global-defs))
(local {: pos? : not-pos? : neg? : nil? : sum} (require :util.helpers))
(import-macros {: dec! : inc! : zero!} :util.macros)

(fn stop-non-repeated-signals! []
  (each [_side board (pairs state.board)]
    (each [idx ttl (pairs board.active-cells)]
      (tset board.active-cells idx (- ttl 10000)))))

(fn end-grapple-phase []
  (stop-non-repeated-signals!)
  (zero! state.time-left)
  (zero! state.message-flash-timer)
  (set state.message-flash-show true)
  (set state.final-score (math.abs (sum state.box-owners)))
  (case (actions.winner state.box-owners state.player-side)
    :deadlock (set state.phase :deadlock)
    :player (set state.phase :winner)
    :enemy (set state.phase :failed)))

(fn update-message-timer [dt]
  (inc! state.message-flash-timer dt)
  (dec! state.message-timer dt)
  (if state.message-flash-show
      (when (<= 0.9 state.message-flash-timer)
        (zero! state.message-flash-timer)
        (set state.message-flash-show false))
      (when (<= 0.3 state.message-flash-timer)
        (zero! state.message-flash-timer)
        (set state.message-flash-show true)))
  (when (not-pos? state.message-timer)
    (case state.phase
      :winner (set-game-phase! :select-components
                               {:robot-id state.enemy-id
                                :grapple-score (math.abs state.final-score)})
      :failed (set-game-phase! :city {:injured true})
      _ (set-game-phase! :grapple {:robot-id state.enemy-id}))))

(fn update-grapple-timer [dt]
  (when (= state.phase :grapple)
    (let [new-time (- state.time-left dt)]
      (if (neg? new-time)
          (end-grapple-phase)
          (set state.time-left new-time)))))

(fn update-board! [dt]
  (each [_side board (pairs state.board)]
    (each [idx ttl (pairs board.active-cells)]
      (local new-ttl (- ttl dt))
      (tset board.active-cells idx new-ttl)
      (if (neg? new-ttl)
          (tset board.active-cells idx nil)))
    (each [i pip (ipairs board.active-pips)]
      (dec! pip.ttl dt)
      (when (not (pos? pip.ttl))
        (tset (. board.paths pip.row) defs.firing-pip-col "─")
        (table.remove board.active-pips i)))))

(fn update-boxes! []
  (set state.box-owners (actions.box-owners state.box-owners state.board)))

(fn grapple-key-handler [dt]
  (dec! global-state.key-timer dt)
  (let [held (or (love.keyboard.isDown keys.up)
                 (love.keyboard.isDown keys.down))
        board (. state.board state.player-side)]
    (if held
        (when (or (not global-state.key-held) (not-pos? global-state.key-timer))
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
  (enemy.move! (. state.board state.enemy-side) state.enemy.grapple dt))

(fn update [dt]
  (update-board! dt)
  (update-grapple-timer dt)
  (case state.phase
    :grapple (grapple-update dt)
    :chooser (chooser.update dt)
    :winner (update-message-timer dt)
    :failed (update-message-timer dt)
    :deadlock (update-message-timer dt)))

{: update}
