(local fonts {:display-font nil :big-font nil})
(local face :assets/fonts/ParadroidMono-Light.ttf)
; (local face :assets/Monocode-Regular-V01.02b.ttf)

(fn fonts.setup []
  (set fonts.display-font (love.graphics.newFont face 32))
  (set fonts.big-font (love.graphics.newFont face 54)))

fonts
