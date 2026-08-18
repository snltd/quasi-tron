
(fn dec! [token opt-val]
  "Decrement token by 1, or by opt-val if given"
  `(set ,token (if (nil? ,opt-val) (- ,token 1) (- ,token ,opt-val))))

(fn inc! [token opt-val]
  "Increment token by 1, or by opt-val if given"
  `(set ,token (if (nil? ,opt-val) (+ ,token 1) (+ ,token ,opt-val))))

(fn zero! [token]
  "set token to zero"
  `(set ,token 0))

{: dec! : inc! :  zero! }
