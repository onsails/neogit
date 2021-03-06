local util = require("neogit.lib.util")
local cli = require("neogit.lib.git.cli")

local function parse_diff(output)
  output = util.slice(output, 5)
  local diff = {
    lines = output,
    hunks = {}
  }

  local len = #output

  local hunk = nil

  for i=1,len do
    local line = output[i]
    if not vim.startswith(line, "+++") then
      local matches = vim.fn.matchlist(line, "^@@ -\\([0-9]*\\),\\?\\([0-9]*\\)\\? +\\([0-9]*\\),\\?\\([0-9]*\\)\\? @@")

      if #matches ~= 0 then
        if hunk ~= nil then
          table.insert(diff.hunks, hunk)
        end
        hunk = {
          index_from = tonumber(matches[2]),
          index_len = tonumber(matches[3]) or 1,
          disk_from = tonumber(matches[4]),
          disk_len = tonumber(matches[5]) or 1,
          first = i,
          last = i
        }
      else
        hunk.last = hunk.last + 1
      end
    end
  end

  table.insert(diff.hunks, hunk)

  return diff
end

local diff = {
  parse = parse_diff,
  staged = function(name, cb)
    if cb then
      cli.run("diff --cached " .. name, function(o)
        cb(parse_diff(o))
      end)
    else
      return parse_diff(cli.run("diff --cached " .. name))
    end
  end,
  unstaged = function(name, cb)
    if cb then
      cli.run("diff " .. name, function(o)
        cb(parse_diff(o))
      end)
    else
      return parse_diff(cli.run("diff " .. name))
    end
  end,
}

return diff
