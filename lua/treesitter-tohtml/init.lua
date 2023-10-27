local M = {}

M.TSNode_tohtml = function(buf, node)
  if node:child_count() == 0 then
    local text = vim.treesitter.get_node_text(node, buf)
    local row, collumn = node:start()

    local inspect = vim.inspect_pos(
      buf,
      row,
      collumn,
      { semantic_tokens = true, treesitter = true }
    )

    -- extmarks has a higher priority
    local ts_high = ''
    local token = ''

    if vim.tbl_count(inspect.semantic_tokens) > 0 then
      local highest = -99999
      local highest_value = nil
      for _, v in ipairs(inspect.semantic_tokens) do
        if v.opts.priority > highest then
          highest_value = v.opts.hl_group_link
        end
      end

      token = token
        .. require('treesitter-tohtml.css').hi_group_to_class(highest_value)
    elseif vim.tbl_count(inspect.treesitter) > 0 then
      for _, ts_group in ipairs(inspect.treesitter) do
        local highlight = ts_group.hl_group_link
        token = token
          .. ' '
          .. require('treesitter-tohtml.css').hi_group_to_class(highlight)
      end
    end

    return '<span class="' .. ts_high .. token .. '">' .. text .. '</span>'
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
        ret = ret .. string.rep('\n', srow - erow) .. string.rep(' ', scol)
      end
    end

    -- if child:parent():parent() == nil then
    --   ret = ret .. '\n--EMPTY--\n'
    -- end

    ret = ret .. M.TSNode_tohtml(buf, child)
  end

  return ret
end

-- HTML From TSTree
M.TSTree_tohtml = function(buf)
  local root = vim.treesitter.get_node({ bufnr = buf }):tree():root()
  return M.TSNode_tohtml(buf, root)
end

M.GenerateHTML = function()
  local buf = vim.api.nvim_get_current_buf()
  -- vim.print(vim.inspect(classes))
  -- vim.print(get_css(classes))

  local css = require('treesitter-tohtml.css').hi_TOCSS()
  local buf_name = vim.api.nvim_buf_get_name(buf)
  local body = M.TSTree_tohtml(buf)

  return [[
  <html>
    <head>
      <title>
  ]] .. buf_name .. [[
      </title>
      <style>
  ]] .. css .. [[
      </style>
    </head>
    <body class="Normal">
    <code><pre>]] .. '\n' .. body .. [[
    </pre></code>
    </body>
  </html>
  ]]
end

M.TOPrintHTML = function()
  vim.print(M.GenerateHTML())
end

function mysplit(inputstr, sep)
  if sep == nil then
    sep = '%s'
  end
  local t = {}
  for str in string.gmatch(inputstr, '([^' .. sep .. ']+)') do
    table.insert(t, str)
  end
  return t
end

M.TOHtml = function()
  local name = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
    .. '.html'

  -- refactor GenerateHTML to  Return an String array
  local content = mysplit(M.GenerateHTML(), '\n')
  local new_buf = vim.api.nvim_create_buf(true, false)
  -- vim.api.nvim_buf_set_text(newb, 0, 0, 0, 0, { content })

  vim.api.nvim_buf_set_name(new_buf, name)
  vim.api.nvim_buf_set_lines(new_buf, 0, 0, false, content)
end

local __default = {}

M.setup = function(opts)
  M.config = vim.tbl_deep_extend('force', __default, opts)
end

return M
