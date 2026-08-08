;; The Quazatron grapple sub-game.
;; A central column of cells. Each player has a number of pips. Firing a pip
;; into a cell changes its colour. When the time reaches zero, whoever has the
;; most cells of their colour wins.
;;
;; Initial sketch for how it works:
;; To generate the game board we have a store of paths. Paths can be a straight
;; line to a single cell, or they can branch into multiple paths, some or all
;; of which may be dead-ends.

(local {: keys : size : gcol : number-of-cells : pip-ttl}
       (require :grapple.defs))

(local draw (require :grapple.draw))
(local init (require :grapple.init))
(local state (require :grapple.state))
(local {: pos? : nil?} (require :util.helpers))
; (import-macros {: inc! : dec! } :util.macros)

(macro dec! [token opt-val]
  "Decrement token by 1, or by opt-val if given"
  `(set ,token (if (nil? ,opt-val) (- ,token 1) (- ,token ,opt-val))))

(macro inc! [token opt-val]
  "Increment token by 1, or by opt-val if given"
  `(set ,token (if (nil? ,opt-val) (+ ,token 1) (+ ,token ,opt-val))))

(var key-timer 0)
(var key-held false)

(fn love.load []
  (math.randomseed (os.time))
  (love.window.setTitle "Quasi-Tron")
  (love.window.setMode size.window.width size.window.height {:resizable true})
  (love.graphics.setBackgroundColor (unpack gcol.background))
  (set state.pips.player 3)
  ;; TODO dynamically
  (set state.pips.enemy 5)
  ;; TODO dynamically
  (set state.cell-owner (init.cell-owners))
  (set state.board (init.board number-of-cells)))

(fn love.draw []
  (let [(win-w win-h) (love.graphics.getDimensions)
        scale (math.min (/ win-w size.window.width)
                        (/ win-h size.window.height))
        offset-x (/ (- win-w (* size.window.width scale)) 2)
        offset-y (/ (- win-h (* size.window.height scale)) 2)]
    (love.graphics.push)
    (love.graphics.translate offset-x offset-y)
    (love.graphics.scale scale scale)
    (draw.board)
    (draw.active-pips)
    (love.graphics.pop)))

(fn love.update [dt]
  (each [i pip (ipairs state.active-pips)]
    (dec! pip.ttl dt)
    (if (not (pos? pip.ttl))
      (table.remove state.active-pips i))
    )
  ;; keyboard stuff
  (set key-timer (- key-timer dt))
  (let [held (or (love.keyboard.isDown keys.up)
                 (love.keyboard.isDown keys.down))]
    (if held
        (when (or (not key-held) (<= key-timer 0))
          (if (love.keyboard.isDown keys.down)
              (if (< state.pip-row.player number-of-cells)
                  (inc! state.pip-row.player)
                  (set state.pip-row.player 1))
              (love.keyboard.isDown keys.up)
              (if (not= state.pip-row.player 1)
                  (dec! state.pip-row.player)
                  (set state.pip-row.player number-of-cells)))
          (set key-timer (if key-held keys.repeat-rate keys.repeat-delay))
          (set key-held true))
        (set key-held false))))

(fn fire []
  (let [row state.pip-row.player
        adjacent (. (. state.board row) 3)]
    (when (and (pos? row) (not= adjacent :◁))
      (table.insert state.active-pips {:owner 0 :ttl pip-ttl :row row})
      (dec! state.pips.player)
      (set state.pip-row.player 0))))

(fn love.keypressed [key]
  ;; we don't need/want repeat on the fire
  (if (and (= key keys.fire) (pos? state.pips.player)) (fire)
      (= key "escape") (love.event.quit)))
