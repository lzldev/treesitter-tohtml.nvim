local M = {}

-- Css String from highlights
M.hi_TOCSS = function()
  return M.hi_map_to_css(M.map_hi())
end

M.hi_group_to_class = function(hl_group_name)
  return string.gsub(hl_group_name, '@', '')
end

-- map hightlights into a table following links
M.map_hi = function()
  local hi_table = vim.api.nvim_get_hl(0, {})
  local classes = {}

  for highlight, values in pairs(hi_table) do
    if getmetatable(values) ~= nil then
      goto continue
    end

    local root =
      require('treesitter-tohtml.utils').get_root_class(highlight, hi_table)

    if root == nil then
      goto continue
    end

    if not classes[root] then
      local hi_to_class = M.hi_group_to_class(highlight)

      classes[root] = { his = { hi_to_class } }

      if type(values.bg) == 'number' then
        classes[root].bg = M.int_to_hex(values.bg)
      end

      if type(values.fg) == 'number' then
        classes[root].fg = M.int_to_hex(values.fg)
      end

      if type(values.bold) == 'boolean' then
        classes[root].bold = values.bold
      end

      if type(values.italics) == 'boolean' then
        classes[root].bold = values.italics
      end
    else
      local hi_to_class = M.hi_group_to_class(highlight)

      table.insert(classes[root].his, hi_to_class)
    end
    ::continue::
  end
  return classes
end

-- generate css from highlight map
M.hi_map_to_css = function(hi_table)
  local final_css = ''

  for _, highlight in pairs(hi_table) do
    local c = '.' .. table.concat(highlight.his, ',.')

    final_css = final_css .. c .. ' {\n'

    if highlight.bg ~= nil then
      final_css = final_css .. 'background: ' .. highlight.bg .. ';\n'
    end

    if highlight.fg ~= nil then
      final_css = final_css .. 'color: ' .. highlight.fg .. ';\n'
    end

    if highlight.bold ~= nil then
      final_css = final_css .. 'font-weight: bold;\n'
    end

    if highlight.bold ~= nil then
      final_css = final_css .. 'font-style; italic;\n'
    end

    final_css = final_css .. '}\n'
  end

  return final_css
end

M.int_to_hex = function(int)
  local fmt = string.format('%x', int)
  return '#' .. string.rep('0', 6 - string.len(fmt)) .. fmt
end

return M
