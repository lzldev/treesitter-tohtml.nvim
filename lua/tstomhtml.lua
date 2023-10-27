local M = {}

local get_root_class
get_root_class = function(cur_name, table)
  if not not table[cur_name].link then
    if table[table[cur_name].link] == nil then
      return nil
    end
    return get_root_class(table[cur_name].link, table)
  end

  return cur_name
end

local map_hi = function(buf)
  local hi_table = vim.api.nvim_get_hl(buf, {})
  local classes = {}

  for highlight, values in pairs(hi_table) do
    if getmetatable(values) ~= nil then
      goto continue
    end

    local root = get_root_class(highlight, hi_table)

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
    else
      table.insert(classes[root].his, highlight)
    end
    ::continue::
  end
  return classes
end

local get_css = function(classes)
  local final_css = ''
  for _, highlight in pairs(classes) do
    local c = '.' .. table.concat(highlight.his, ',.')

    final_css = final_css .. c .. ' {\n'

    if not not highlight.bg then
      final_css = final_css .. 'background: "' .. highlight.bg .. '"\n'
    end

    if not not highlight.fg then
      final_css = final_css .. 'color: "' .. highlight.fg .. '"\n'
    end

    if not not highlight.bold then
      final_css = final_css .. 'font-weight: bold\n'
    end

    final_css = final_css .. '}\n'
  end

  return final_css
end

local generate_tag
generate_tag = function(buf, node)
  if node:child_count() == 0 then
    local text = vim.treesitter.get_node_text(node, buf)
    return text
  end

  local ret = ''
  for child in node:iter_children() do
    local prev = child:prev_sibling()

    if prev ~= nil then
      local erow, ecol = prev:end_()
      local srow, scol = child:start()

      if erow == srow then
        ret = ret .. string.rep(' ', (scol - ecol))
      end

      if erow < srow then
        ret = ret .. string.rep('\n', srow - erow) .. string.rep('-', scol)
      end
    end

    -- if child:parent():parent() == nil then
    --   ret = ret .. '\n--EMPTY--\n'
    -- end

    ret = ret .. generate_tag(buf, child)
  end

  return ret
end

local node_tree_tohtml = function(buf)
  local root = vim.treesitter.get_node({ bufnr = buf }):tree():root()
  return generate_tag(buf, root)
end

M.printHI = function()
  local buf = vim.api.nvim_get_current_buf()
  -- vim.print(vim.inspect(classes))
  -- vim.print(get_css(classes))

  local hi_map = map_hi(buf)
  local code = node_tree_tohtml(buf)

  vim.print(code)
end

M.setup = function(opts)
  vim.print 'hmm'
end

return M
