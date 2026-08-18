(fn gwrap [f]
  "convenience wrapper for temporarily changing colour, line-width etc"
  (love.graphics.push :all)
  (f)
  (love.graphics.pop))

(fn in-colour [col f]
  (gwrap (fn []
           (love.graphics.setColor (unpack col))
           (f))))

{: gwrap : in-colour}
