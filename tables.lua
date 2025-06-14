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
