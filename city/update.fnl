(local defs (require :city.defs))
(local levels (require :data.levels))
(local global-defs (require :global-defs))
(local state (require :city.state))
(local {: pp : nil? : inc : dec} (require :util.helpers))
(import-macros {: dec! : inc!} :util.macros)
(var key-down false)

;; we represent the player's current velocity as an xyx vec in state
; 
(fn inertia! [axis dt]
  (tset state.velocity axis 0))

;; in a separate fn so we can accelerate etc
(fn velocity [axis dt]
  (let [current-speed state.speed]
    (if (< current-speed state.max-speed)
        (inc! state.speed (* state.accel state.accel dt))))
  (* state.speed dt))

(fn up! [dt]
  ;; down needs to check we aren't at the edge of the board AND that we aren't
  ;; bumping up against a wall
  (set key-down true)
  (let [new-x (- state.player-x (velocity dt))]
    (if (< -0.96 new-x)
        (set state.player-x new-x))))

(fn down! [dt]
  ;; down only needs to check we aren't at the edge of the board
  (set key-down true)
  (let [new-x (+ state.player-x (velocity dt))
        boundary (dec (length (. (. levels state.map-key) 1)))]
    (if (< new-x boundary)
        (set state.player-x new-x))))

(fn left! [dt]
  ;; left needs to check we aren't at the edge of the board AND that we aren't
  ;; bumping up against a wall
  (set key-down true)
  (let [new-y (- state.player-y (velocity dt))]
    (if (< -0.46 new-y)
        (set state.player-y new-y))))

(fn right! [dt]
  ;; right only needs to check we aren't at the edge of the board
  (set key-down true)
  (let [new-y (+ state.player-y (velocity dt))
        boundary (- (length (. (. levels state.map-key) 1)) 2.5)]
    (if (< new-y boundary)
        (set state.player-y new-y))))

(fn keyboard [dt]
  (let [k global-defs.keys]
    (set key-down false)
    
    (if (love.keyboard.isDown k.down) (down! dt)
        (love.keyboard.isDown k.up) (up! dt)
        (inertia! :x dt)
        )
    (if (love.keyboard.isDown k.left) (left! dt)
        (love.keyboard.isDown k.right) (right! dt)
        (inertia! :y dt)
        )))

(fn update [dt]
  (keyboard dt))

{: update}
