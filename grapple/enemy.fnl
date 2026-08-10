(local action (require :grapple.actions))
(local state (require :grapple.state))
(local { : pos? } (require :util.helpers))

(fn move [dt]
  (let [n (math.random 0 1000)
        board (. state.board state.enemy-side)]
    (if (< n 20)
          (action.pip-up board)
        (< n 50)
          (action.pip-down board)
        (and (< n 80) (pos? board.pips) (pos? board.pip-row))
          (action.fire-pip board))))

{: move}
