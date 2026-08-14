(local global-state (require :global-state))
(local actions (require :grapple.actions))
(local chooser (require :grapple.chooser))
(local defs (require :grapple.defs))
(local enemy (require :grapple.enemy))
(local state (require :grapple.state))
(local {: pos?} (require :util.helpers))
(local {: keys} (require :global-defs))
(local {: nil?} (require :util.helpers))
(import-macros {: dec!} :util.macros)

(fn update-timer [dt]
  (let [new-time (- state.time-left dt)]
    (if (< new-time 0)
        (do
          (set state.time-left 0)
          (set state.phase :adjudicate))
        (set state.time-left new-time))))

(fn update-board! [dt]
  (each [_side board (pairs state.board)]
    (each [idx ttl (pairs board.active-cells)]
      (local new-ttl (- ttl dt))
      (tset board.active-cells idx new-ttl)
      (when (< new-ttl 0)
        (tset board.active-cells idx nil)))
    (each [i pip (ipairs board.active-pips)]
      (dec! pip.ttl dt)
      (when (not (pos? pip.ttl))
        (tset (. board.paths pip.row) defs.firing-pip-col "─")
        (table.remove board.active-pips i)))))

(fn update-boxes! []
  (set state.box-owners (actions.update-boxes state.box-owners state.board)))

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

(fn update [dt]
  (update-board! dt)
  (update-timer dt)
  ;; player 
  (if (= state.phase :grapple)
      (do
        (grapple-key-handler dt)
        (update-boxes!)
        (enemy.move (. state.board state.enemy-side) state.enemy-skills dt))
      (= state.phase :chooser)
      (chooser.update dt)))

{: update}
