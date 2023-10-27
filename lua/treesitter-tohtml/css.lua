local M = {}

-- Css String from highlights
M.hi_TOCSS = function()
  return M.hi_map_to_css(M.map_hi())
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
      classes[root] = { his = { root } }

      if not not values.bg then
        classes[root].bg = '#' .. string.format('%x', values.bg)
      end
      if not not values.fg then
        classes[root].fg = '#' .. string.format('%x', values.fg)
      end

      if not not values.bold then
        classes[root].bold = values.bold
      end

      if not not values.italics then
        classes[root].bold = values.bold
      end
    else
      table.insert(classes[root].his, highlight)
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

    if not not highlight.bg then
      final_css = final_css .. 'background: "' .. highlight.bg .. '";\n'
    end

    if not not highlight.fg then
      final_css = final_css .. 'color: "' .. highlight.fg .. '";\n'
    end

    if not not highlight.bold then
      final_css = final_css .. 'font-weight: bold;\n'
    end

    final_css = final_css .. '}\n'
  end

  return final_css
end

return M
