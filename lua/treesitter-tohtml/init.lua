local M = {}

M.get_TSToken = function(token_list)
  local highest = -999999
  local highest_value = nil

  for _, v in ipairs(token_list) do
    if v.opts.priority > highest then
      highest = v.opts.priority
      highest_value = v.opts.hl_group_link
    end
  end
  return require('treesitter-tohtml.css').hi_group_to_class(highest_value)
end

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

    if vim.tbl_count(inspect.extmarks) > 0 then
      ts_high = token .. M.get_TSToken(inspect.extmarks)
    end

    if vim.tbl_count(inspect.semantic_tokens) > 0 then
      token = token .. M.get_TSToken(inspect.semantic_tokens)
    elseif vim.tbl_count(inspect.treesitter) > 0 then
      for _, ts_group in ipairs(inspect.treesitter) do
        local highlight = ts_group.hl_group_link
        token = token
          .. ' '
          .. require('treesitter-tohtml.css').hi_group_to_class(highlight)
      end
    end

    return '<span class="'
      .. ts_high
      .. token
      .. '">'
      .. require('treesitter-tohtml.utils').escape_html(text)
      .. '</span>'
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
        -- require('treesitter-tohtml.utils').fill_list ' '

        if M.config and M.config.line_numbers then
          ret = ret
            .. '\n'
            .. require('treesitter-tohtml.utils').lineN_span(erow, srow, '\n')
            .. string.rep(' ', scol)
        else
          ret = ret .. string.rep('\n', srow - erow) .. string.rep(' ', scol)
        end
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
        .ln{
          display:inline-block;
          text-align:end;
          margin-right:10px;
          padding-right:4px;
          border-right:1px solid rgba(255,255,255,0.4);
          min-width:1rem;
        }
  ]] .. css .. [[
      </style>
    </head>
    <body class="]] .. require('treesitter-tohtml.css').hi_group_to_class 'Normal' .. [[">
    <code><pre>]] .. '\n' .. body .. [[
    </pre></code>
    </body>
  </html>
  ]]
end

M.TOPrintHTML = function()
  vim.print(M.GenerateHTML())
end

-- returns new buf number
M.TOHtml = function()
  local name = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
    .. '.html'

  for _, v in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(v) == name then
      vim.api.nvim_buf_delete(v, { force = true })
      break
    end
  end

  -- refactor GenerateHTML to  Return an String array
  local content = vim.split(M.GenerateHTML(), '\n')
  local new_buf = vim.api.nvim_create_buf(true, false)
  -- vim.api.nvim_buf_set_text(newb, 0, 0, 0, 0, { content })

  vim.api.nvim_buf_set_name(new_buf, name)
  vim.api.nvim_buf_set_lines(new_buf, 0, 0, false, content)

  return new_buf
end

local __default = {}

M.setup = function(opts)
  M.config = vim.tbl_deep_extend('force', __default, opts)
  vim.api.nvim_create_user_command('TSTOHtml', function(command_args)
    if not command_args['bang'] then
      M.TOHtml()
    else
      M.TOPrintHTML()
    end
  end, {
    bang = true,
  })
end

M.__debug = function()
  vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), M.TOHtml())
end

M.__debugW = function()
  vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), M.TOHtml())
  vim.cmd 'w! ~/test.html'
end

return M
