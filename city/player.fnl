(local levels (require :data.levels))
(local global-defs (require :global-defs))
(local state (require :city.state))
(local {: zero? : pp : neg? : pos? : nil? : inc : dec} (require :util.helpers))
(import-macros {: dec! : inc!} :util.macros)

;; These tune the physicas of the way the player's robot moves
(local rebound-factor -0.22)
(local momentum-factor 9)
(local distance-factor 0.4)
(local accel-factor 1)

;; will be calculated from components

(local motive-force 5)
(local mass 10)

;; we represent the player's current velocity as an xyx vec in state
(fn speed []
  (let [v state.player.velocity]
    (math.sqrt (+ (^ v.x 2) (^ v.y 2) (^ v.z 2)))))

;; momentum deals with slowing down, inertia with speeding up
(fn momentum-p-axis! [axis dt]
  "Slow the player when a velocity component is +ve"
  (if (pos? (. state.player.velocity axis))
      (let [new (- (. state.player.velocity axis)
                   (* (/ momentum-factor state.player.weight) dt))]
        (tset state.player.velocity axis (if (pos? new) 0 new)))))

(fn momentum-n-axis! [axis dt]
  "Slow the player down when a velocity component is -ve"
  (if (neg? (. state.player.velocity axis))
      (let [new (+ (. state.player.velocity axis)
                   (* (/ momentum-factor state.player.weight) dt))]
        (tset state.player.velocity axis (if (neg? new) 0 new)))))

(fn momentum! [axis dt]
  "Slow the player down (when a key is not being pressed)"
  (momentum-p-axis! axis dt)
  (momentum-n-axis! axis dt))

(fn flat-out? []
  (= (speed) state.player.max-speed))

(fn stopped? []
  (zero? (speed)))

(fn accelerate [axis dir-fn dt]
  ;; if we're at top speed, return 0 because we can't accelerate
  ;; if we have to accelerate against the velocity, return -ve
  ;; if we can accelerate with the velocity, return the velocity delta
  ;; are we accelerating with or against the velocity?
  ;; F = ma so a = F / m
  (if (dir-fn (. state.player.velocity axis)) ; with
      (if (flat-out?) 0
          (* accel-factor dt (/ motive-force mass)))
      (if (stopped?) ; against
          0 (- 0 (* accel-factor dt (/ motive-force mass))))))

(fn distance-on-axis [axis dt]
  "Returns the distance to move the player along the given axis"
  (* (. state.player.velocity axis) dt))

(fn move! [dt]
  (let [new-x (- state.player.x (distance-on-axis :x dt))
        new-y (- state.player.y (distance-on-axis :y dt))
        boundary-x (dec (length (. (. levels state.map-key) 1)))
        boundary-y (- (length (. (. levels state.map-key) 1)) 2.5)]
    (if (< -0.96 new-x boundary-x) (set state.player.x new-x)
        (set state.player.velocity.x (* rebound-factor state.player.velocity.x)))
    (if (< -0.46 new-y boundary-y) (set state.player.y new-y)
        (set state.player.velocity.y (* rebound-factor state.player.velocity.y)))))

(fn power! [dir dt]
  (if (< (speed) state.player.max-speed)
      (if (= dir :up) (inc! state.player.velocity.x (accelerate :x pos? dt))
          (= dir :down) (dec! state.player.velocity.x (accelerate :x neg? dt))
          (= dir :left) (inc! state.player.velocity.y (accelerate :y pos? dt))
          (= dir :right) (dec! state.player.velocity.y (accelerate :y neg? dt)))))

(fn keyboard [dt]
  (let [k global-defs.keys]
    (if (love.keyboard.isDown k.down) (power! :down dt)
        (love.keyboard.isDown k.up) (power! :up dt)
        (momentum! :x dt))
    (if (love.keyboard.isDown k.left) (power! :left dt)
        (love.keyboard.isDown k.right) (power! :right dt)
        (momentum! :y dt))))

{: keyboard : move!}
