function stringsplit(inputstr, sep)
    sep = sep or "%s"
  local t = {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

function stringjoin(t, sep)
    local str = ""
    for _, e in ipairs(t) do
        str = str .. tostring(e) .. ":"
    end

    return string.sub(str, 1, -2)
end

function tableNextIndex(index, table)
  return (index % #table) + 1
end

function tablePrevIndex(index, table)
  return ((index - 2) % #table) + 1
end

function tableChangeIndex(index, table, d)
  return ((index - 1 + d) % #table) + 1
end

json = require "json"

function jsonDecodeFile(filename)
    if(love.filesystem.getInfo(filename) == nil) then
        return nil
    end
    local str = ""
    for line in love.filesystem.lines(filename) do
        str = str .. line
    end

    return json.decode(str)
end

function jsonEncodeFile(t, filename)
  local file = io.open(filename, "w")

  file:write(json.encode(t))

  io.close(file)
end