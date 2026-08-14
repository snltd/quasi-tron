(local fonts {:display-font nil :big-font nil})

(fn fonts.setup []
  (set fonts.display-font (love.graphics.newFont :assets/MatrixType-Regular.ttf 32))
  (set fonts.big-font (love.graphics.newFont :assets/MatrixType-Regular.ttf 54)))

fonts
