local M = {}

M.TSNode_tohtml = function(buf, node)
  if node:child_count() == 0 then
    local text = vim.treesitter.get_node_text(node, buf)
    return '<span>' .. text .. '</span>'
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
    <body>
    <pre>
  ]] .. body .. [[
    </pre>
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
  local name = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()) .. ".html"
  local content = mysplit(M.GenerateHTML(), '\n')

  local new_buf = vim.api.nvim_create_buf(true, false)
  -- vim.api.nvim_buf_set_text(newb, 0, 0, 0, 0, { content })

  vim.api.nvim_buf_set_name(new_buf,name)
  vim.api.nvim_buf_set_lines(new_buf,0,0,false,content)
end

local __default = {}

M.setup = function(opts)
  M.config = vim.tbl_deep_extend('force', __default, opts)
end

return M
