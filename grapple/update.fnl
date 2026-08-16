(local global-state (require :global-state))
(local actions (require :grapple.actions))
(local chooser (require :grapple.chooser))
(local defs (require :grapple.defs))
(local enemy (require :grapple.enemy))
(local state (require :grapple.state))
(local {: set-game-phase!} (require :util.actions))
(local {: pos?} (require :util.helpers))
(local {: keys} (require :global-defs))
(local {: pp : nil? : sum} (require :util.helpers))
(import-macros {: dec! : inc!} :util.macros)

(fn end-grapple-phase []
  (each [_side board (pairs state.board)]
    (each [idx ttl (pairs board.active-cells)]
      (tset board.active-cells idx (- ttl 10000))))
  (set state.time-left 0)
  (let [score (sum state.box-owners)]
    (set state.message-flash-timer 0)
    (set state.message-flash-show true)
    (if (= 0 score) (set state.phase :deadlock)
        (or (and (< score 0) (= state.enemy-side :right))
            (and (< 0 score) (= state.enemy-side :left)))
        (when (= state.phase :grapple)
          (set state.final-score score)
          (set state.phase :winner))
        (set state.phase :failed))))

(fn update-message-timer [dt]
  (inc! state.message-flash-timer dt)
  (dec! state.message-timer dt)
  (if state.message-flash-show
      (when (<= 0.9 state.message-flash-timer)
        (set state.message-flash-timer 0)
        (set state.message-flash-show false))
      (when (<= 0.3 state.message-flash-timer)
        (set state.message-flash-timer 0)
        (set state.message-flash-show true)))
  (if (<= state.message-timer 0)
      (if (= state.phase :winner)
          (set-game-phase! :select-components
                           {:robot-id state.enemy-id
                            :grapple-score (math.abs state.final-score)})
          (= state.phase :failed)
            (set-game-phase! :city {:injured true})
          (set-game-phase! :grapple {:robot-id state.enemy-id}))))

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
  (enemy.move (. state.board state.enemy-side) state.enemy.grapple dt))

(fn update [dt]
  (update-board! dt)
  (update-grapple-timer dt)
  (if (= state.phase :grapple) (grapple-update dt)
      (= state.phase :chooser) (chooser.update dt)
      (= state.phase :winner) (update-message-timer dt)
      (= state.phase :failed) (update-message-timer dt)
      (= state.phase :deadlock) (update-message-timer dt)))

{: update}
