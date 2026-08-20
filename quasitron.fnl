(local global-defs (require :global-defs))
(local global-state (require :global-state))
(local city (require :city))
(local grapple (require :grapple))
(local select-components (require :select-components))
(local {: half} (require :util.helpers))
(local fonts (require :util.fonts))
(local intro (require :intro.draw))
(local {: set-game-phase!} (require :util.actions))

(fn love.load []
  (math.randomseed (os.time))
  (love.window.setTitle :QuasiTron)
  (fonts.setup)
  (love.graphics.setFont fonts.display-font)
  (love.window.setMode global-defs.size.window.width
                       global-defs.size.window.height {:resizable true})
  (set global-state.player global-defs.player)
  (set global-state.player.hp 20)
  ; (set-game-phase! :grapple {:robot-id :r8}))
  (set-game-phase! :city))
; (set-game-phase! :select-components {:robot-id :r8 :grapple-score 5}))

(fn love.draw []
  (let [(win-w win-h) (love.graphics.getDimensions)
        scale (math.min (/ win-w global-defs.size.window.width)
                        (/ win-h global-defs.size.window.height))
        offset-x (half (- win-w (* global-defs.size.window.width scale)))
        offset-y (half (- win-h (* global-defs.size.window.height scale)))]
    (love.graphics.push)
    (love.graphics.translate offset-x offset-y)
    (love.graphics.scale scale scale)
    (case global-state.game-phase
      :city (city.draw)
      :grapple (grapple.draw)
      :select-components (select-components.draw)
      :intro (intro.draw))
    (love.graphics.pop)))

(fn love.update [dt]
  (case global-state.game-phase
    :city (city.update dt)
    :grapple (grapple.update dt)
    :intro (intro.update dt)))

;; we don't need/want repeat on the fire
(fn love.keypressed [key]
  (if (= key :escape) (love.event.quit)) ; for now
  (case global-state.game-phase
    :grapple (grapple.keypress key)
    :select-components (select-components.keypress key)
    :intro (intro.fire)))
