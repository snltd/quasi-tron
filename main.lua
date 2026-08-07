love.filesystem.setRequirePath("?.lua;.lib/?.lua;.lib/?/init.lua")
fennel = require("fennel")
debug.traceback = fennel.traceback

table.insert(package.loaders, function(modname)
  local filename = modname:gsub("%.", "/") .. ".fnl"
  if love.filesystem.getInfo(filename) then
    return function(...)
      return fennel.eval(love.filesystem.read(filename), { env = _G, filename = filename }, ...), filename
    end
  end
end)

require("quasi-tron")
