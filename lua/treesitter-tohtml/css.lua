local M = {}

-- Css String from highlights
M.hi_TOCSS = function()
  return M.hi_map_to_css(M.map_hi())
end

M.int_to_hex = function(int)
  local fmt = string.format('%x', int)
  return '#' .. string.rep('0', 6 - string.len(fmt)) .. fmt
end

M.hi_group_to_class = function(hl_group_name)
  local r = '_'
  for i = 1, #hl_group_name do
    r = r .. string.format("%2x",string.byte(hl_group_name, i))
  end
  return r
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
      classes[root] = { his = { M.hi_group_to_class(highlight) } }

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
      table.insert(classes[root].his, M.hi_group_to_class(highlight))
    end
    ::continue::
  end
  return classes
end

-- generate css from highlight map
M.hi_map_to_css = function(hi_table)
  local variables = 'html{\n'
  local final_css = ''

  for root, highlight in pairs(hi_table) do
    local class_body = ''
    local rr = M.hi_group_to_class(root)

    if highlight.bg ~= nil then
      variables = variables .. '/*' .. root .. ' */'
      variables = variables .. '--' .. rr .. '_bg: ' .. highlight.bg .. ';\n'
      class_body = class_body .. 'background: var(--' .. rr .. '_bg);\n'
    end

    if highlight.fg ~= nil then
      variables = variables .. '/*' .. root .. ' */'
      variables = variables .. '--' .. rr .. '_fg: ' .. highlight.fg .. ';\n'
      class_body = class_body .. 'color: var(--' .. rr .. '_fg);\n'
    end

    if highlight.bold ~= nil then
      -- class_body = class_body .. 'font-weight: bold;\n'
    end

    if highlight.bold ~= nil then
      -- class_body = class_body .. 'font-style; italic;\n'
    end

    --generate a class for each high in group
    local clses = table.concat(
      vim.tbl_map(function(value)
        return '.' .. value .. '{\n' .. class_body .. '}\n'
      end, highlight.his),
      '\n'
    )

    final_css = final_css .. clses

    -- final_css = final_css .. '}\n'
  end

  return variables .. final_css
end

return M
