(local {: set-phase!} (require :util.actions))

(fn draw []
  (love.graphics.print "fire to start" 60 60 ))

(fn update [_dt]
  ;; play some music or something. Or dancing robots. I don't know.
)

(fn fire []
  ;; will drop you into the game proper when/if it exists. For now, let's grapple!
  (set-phase! :grapple { :player-pips 4 :enemy-pips 1 })
)

{: draw : update : fire }
