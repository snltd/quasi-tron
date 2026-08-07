;; The Quazatron grapple sub-game.
;; A central column of cells. Each player has a number of pips. Firing a pip
;; into a cell changes its colour. When the time reaches zero, whoever has the
;; most cells of their colour wins.
;;
;; Initial sketch for how it works:
;; To generate the game board we have a store of paths. Paths can be a straight
;; line to a single cell, or they can branch into multiple paths, some or all
;; of which may be dead-ends.

(local defs (require :grapple.defs))
(local draw (require :grapple.draw))
(local init (require :grapple.init))
(local state (require :grapple.state))

(local keys {:up :p :down :l :left :q :right: :w})
(local repeat-delay 0.20)
(local repeat-rate 0.10)

(var key-timer 0)
(var key-held false)

(macro inc! [n]
  `(set ,n (+ 1 ,n)))

(macro dec! [n]
  `(set ,n (- ,n 1)))

(fn love.load []
  (math.randomseed (os.time))
  (love.window.setTitle "Quasi-Tron")
  (love.window.setMode defs.size.window.width defs.size.window.height
                       {:resizable true})
  (love.graphics.setBackgroundColor (unpack defs.gcol.background))
  (set state.pips.player 3)
  ;; TODO dynamically
  (set state.pips.enemy 5)
  ;; TODO dynamically
  (set state.cell-owner (init.cell-owners))
  (set state.board (init.board defs.number-of-cells)))

(fn love.draw []
  (let [(win-w win-h) (love.graphics.getDimensions)
        scale (math.min (/ win-w defs.size.window.width)
                        (/ win-h defs.size.window.height))
        offset-x (/ (- win-w (* defs.size.window.width scale)) 2)
        offset-y (/ (- win-h (* defs.size.window.height scale)) 2)]
    (love.graphics.push)
    (love.graphics.translate offset-x offset-y)
    (love.graphics.scale scale scale)
    (draw.board)
    (love.graphics.pop)))

(fn love.update [dt]
  (set key-timer (- key-timer dt))
  (let [held (or (love.keyboard.isDown keys.up)
                 (love.keyboard.isDown keys.down))]
    (if held
        (when (or (not key-held) (<= key-timer 0))
          (if (love.keyboard.isDown keys.down)
              (if (< state.pip-row.player defs.number-of-cells)
                  (inc! state.pip-row.player)
                  (set state.pip-row.player 1))
              (love.keyboard.isDown keys.up)
              (if (not= state.pip-row.player 1)
                  (dec! state.pip-row.player)
                  (set state.pip-row.player defs.number-of-cells)))
          (set key-timer (if key-held repeat-rate repeat-delay))
          (set key-held true))
        (set key-held false))))

;; Just for now
(fn love.keypressed [key]
  (if (= key "escape") (love.event.quit)))
