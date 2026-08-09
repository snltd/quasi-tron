;; All path traversal logic is done left-to-right. Increasing index means
;; "away from start, towards centre", rather than a straight x co-ordinate.
;;
;; Don't reformat this. Nothing will break, but it gets hard to read.
;;
;; We could randomly inject S or ▶ into any ├─── segments.
; 
;; If you want something to be more likely to be picked, duplicate it.
;; 
;; Key
;; ◀ -- connects to cell
;; ◁ -- end of path
;; ▶ -- infinite repeater
;; S -- colour switcher
;; - -- opposite colour path
; 
(local paths [
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
  ])

{: paths}
