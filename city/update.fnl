; (local defs (require :city.defs))
(local levels (require :data.levels))
(local global-defs (require :global-defs))
(local state (require :city.state))
(local {: pp : nil? : inc : dec} (require :util.helpers))
(import-macros {: dec! : inc!} :util.macros)

;; These tune the physicas of the way the player's robot moves
(local rebound-factor -0.22)
(local inertia-factor 9)
(local speed-factor 0.4)
 
;; we represent the player's current velocity as an xyx vec in state
(fn speed []
  (math.sqrt (+ (^ state.velocity.x 2) (^ state.velocity.y 2))))

(fn inertia-p-axis! [axis dt]
  (if (< 0 (. state.velocity axis))
      (let [new (- (. state.velocity axis) (* (/ inertia-factor state.weight) dt))]
        (tset state.velocity axis (if (< new 0) 0 new)))))

(fn inertia-n-axis! [axis dt]
  (if (< (. state.velocity axis) 0)
      (let [new (+ (. state.velocity axis) (* (/ inertia-factor state.weight) dt))]
        (tset state.velocity axis (if (< 0 new) 0 new)))))

(fn inertia! [axis dt]
  (inertia-p-axis! axis dt)
  (inertia-n-axis! axis dt))

(fn velocity [axis dt]
  (* speed-factor state.accel (. state.velocity axis) dt))

(fn move! [dt]
  (let [new-x (- state.player-x (velocity :x dt))
        new-y (- state.player-y (velocity :y dt))
        boundary-x (dec (length (. (. levels state.map-key) 1)))
        boundary-y (- (length (. (. levels state.map-key) 1)) 2.5)]
    (if (< -0.96 new-x boundary-x) (set state.player-x new-x)
        (set state.velocity.x (* rebound-factor state.velocity.x)))
    (if (< -0.46 new-y boundary-y) (set state.player-y new-y)
        (set state.velocity.y (* rebound-factor state.velocity.y)))))

(fn power! [dir dt]
  (if (< (speed) state.max-speed)
      (if (= dir :up) (inc! state.velocity.x dt)
          (= dir :down) (dec! state.velocity.x dt)
          (= dir :left) (inc! state.velocity.y dt)
          (= dir :right) (dec! state.velocity.y dt))))

(fn keyboard [dt]
  (let [k global-defs.keys]
    (if (love.keyboard.isDown k.down) (power! :down dt)
        (love.keyboard.isDown k.up) (power! :up dt)
        (inertia! :x dt))
    (if (love.keyboard.isDown k.left) (power! :left dt)
        (love.keyboard.isDown k.right) (power! :right dt)
        (inertia! :y dt))))

(fn update [dt]
  (keyboard dt)
  (move! dt))

{: update}
