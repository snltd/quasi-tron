(local global-defs (require :global-defs))
(local global-state (require :global-state))
(local grapple (require :grapple))
(local select-side (require :select-grapple-side))
(local {: half } (require :util.helpers))

(var display-font nil)

(fn love.load []
  (math.randomseed (os.time))
  (love.window.setTitle "QuasiTron")
  (set display-font (love.graphics.newFont "assets/Orbitron-Bold.ttf" 32))
  (love.graphics.setFont display-font)
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
    (if ( = global-state.phase :select-side)
      (select-side.draw))
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
