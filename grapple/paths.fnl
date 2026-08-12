;; All path traversal logic is done left-to-right. Increasing index means
;; "away from start, towards centre", rather than a straight x co-ordinate.
;; The row number increases as we move down.
;; The paths are inverted for the right hand side of the board.
;;
;; Don't reformat this. Nothing will break, but it gets hard to read.
;;
;; We could randomly inject S or ▶ into any ├─── segments.
; 
;; If you want something to be more likely to be picked, duplicate it.
;; 
;; Key
;; ─ -- normal path
;; ◀ -- connects a normal path to a box
;; ◁ -- dead end
;; ▶ -- infinite repeater
;; S -- inverter
;; - -- inverted  path
;; x -- connects an inverted path to a box
 
;; fnlfmt: skip
{:paths
[
  ["───────────◀"]
  ["───────────◀"]
  ["───────────◀"]

  ["─────◁      "] 

  ["─────▶─────◀"]

  ["────────▶──◀"]

  ["─────▶──▶──◀"]

  ["─────S-----x"]
  ["────────S--x"]

  ["────┐       "
   "──◁ ├──────◀"
   "────┘       "]

  ["────┐       "
   "──◁ ├───▶──◀"
   "────┘       "]

  ["────┐       "
   "──◁ ├──────◀"
   "────┘       "]

  ["───────┐    "
   "─────◁ ├───◀"
   "─────▶─┘    "]

  ["────◁  ┌───◀"
   "────▶──┤    "
   "────◁  └───◀"]

  ["─────◁ ┌───◀"
   "───────┤    "
   "─────◁ └─◁ "]

  ["─────◁ ┌───◀"
   "───────┤    "
   "─────◁ └───◀"]

  ["─────◁ ┌───◀"
   "───────┤    "
   "─────◁ └─▶─◀"]

  ["─────◁ ┌───◀"
   "───────┤    "
   "─────◁ └─S-x"]

  ["────┐  ┌───◀"
   "    ├──┤    "
   "────┘  └───◀"]

  ["──◁ ┌──┐    "
   "────┤  ├───◀"
   "──◁ └──┘    "]
   
  ["────┐       "
   "──◁ ├──────◀"
   "────┘  ┌───◀" 
   "───────┤    "
   "─────◁ └───◀"]

  ["───────┐    "
   "────┐  ├───◀"
   "──◁ ├──┘    "
   "────┘       "]

  ["─────◁ ┌───◀"
   "──◁ ┌──┤    "
   "────┤  └───◀"
   "──◁ └──────◀"]
  ]}
