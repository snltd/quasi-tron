(local global-state (require :global-state))

(fn level []
  (love.graphics.print "main game goes here" 100 100)
  (love.graphics.print (.. "player has " global-state.player.hp " hit points")
                       200 200))

{: level}
