(local player (require :city.player))

(fn update [dt]
  (player.keyboard dt)
  (player.move! dt))

{: update}
