;; The Quazatron grapple sub-game.
;; A central column of cells. Each player has a number of pips. Firing a pip
;; into a cell changes its colour. When the time reaches zero, whoever has the
;; most cells of their colour wins.
;;
;; Initial sketch for how it works:
;; To generate the game board we have a store of paths. Paths can be a straight
;; line to a single cell, or they can branch into multiple paths, some or all
;; of which may be dead-ends.

(local global-defs (require :global-defs))
(local global-state (require :global-state))
(local select-side (require :select-grapple-side))
(local grapple (require :grapple))
(local {: half } (require :util.helpers))

(fn love.load []
  (math.randomseed (os.time))
  (love.window.setTitle "QuasiTron")
  (love.window.setMode global-defs.size.window.width
                       global-defs.size.window.height
                       {:resizable true})
  (grapple.load))

(fn love.draw []
  (let [(win-w win-h) (love.graphics.getDimensions)
        scale (math.min (/ win-w global-defs.size.window.width)
                        (/ win-h global-defs.size.window.height))
        offset-x (half (- win-w (* global-defs.size.window.width scale)))
        offset-y (half (- win-h (* global-defs.size.window.height scale)))]
    (love.graphics.push)
    (love.graphics.translate offset-x offset-y)
    (love.graphics.scale scale scale)
    (grapple.draw)
    (love.graphics.pop)))

(fn love.update [dt]
  (if (= global-state.phase :grapple)
        (grapple.update dt)
      (= global-state.phase :select-side)
        (select-side.update dt)))

;; we don't need/want repeat on the fire
(fn love.keypressed [key]
  (if (= key "escape") (love.event.quit)) ; for now
  (if (and (= key global-defs.keys.fire) (= global-state.phase :grapple))
        (grapple.fire)
      (= global-state.phase :select-side)
        (select-side.keypress key)))

