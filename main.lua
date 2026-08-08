love.filesystem.setRequirePath("?.lua;.lib/?.lua;.lib/?/init.lua")
fennel = require("fennel")
debug.traceback = fennel.traceback

local fnl_path = {"?.fnl", ".lib/?.fnl"}

table.insert(package.loaders, function(modname)
  local basename = modname:gsub("%.", "/")
  for _, template in ipairs(fnl_path) do
    local filename = template:gsub("%?", basename)

    if love.filesystem.getInfo(filename) then
      return function(...)
        return fennel.eval(love.filesystem.read(filename),
              { env = _G, filename = filename, correlate = true },
              ...),
            filename
      end
    end
  end
end)

require("quasi-tron")
