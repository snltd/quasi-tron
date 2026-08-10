{:board {:rows 12 
         :cols 12 } ; width of a half of the board 
 :gcol {:background [0.7 0.2 0.2]
        :left [0.7 0.7 0.2]
        :right [0.2 0.2 0.7]
        :lines [0 0 0]}
 :pip-ttl 5
 :firing-pip-col 3 ; where we put a pip once it's fired
 :size {:window {:width 1000 :height 750}}
 :keys {:up :p
        :down :l
        :left :q
        :right :w
        :fire "return"
        :repeat-delay 0.20
        :repeat-rate 0.10}}
