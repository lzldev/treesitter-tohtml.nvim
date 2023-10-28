local M = {}

-- traverse links in hi table
M.get_root_class = function(cur_name, hi_table, walked)
  -- avoids infinite loops
  if walked ~= nil and vim.tbl_contains(walked, cur_name) then
    table.insert(walked, cur_name)
  elseif walked == nil then
    walked = { cur_name }
  end

  if not not hi_table[cur_name].link then
    if hi_table[hi_table[cur_name].link] == nil then
      return nil
    end
    return M.get_root_class(hi_table[cur_name].link, hi_table, walked)
  end

  return cur_name
end

M.fill_list = function(value, size)
  local list = {}
  for i = 1, size do
    table.insert(list, value)
  end
  return list
end

local html_escape_map = {
  ['&'] = '&amp;',
  ['<'] = '&lt;',
  ['>'] = '&gt;',
  ['"'] = '&quot;',
  ["'"] = '&#39;',
}

M.escape_html = function(str)
  return string.gsub(str, '[&<>"\']', function(c)
    return html_escape_map[c]
  end)
end

M.lineN_span = function(start, end_, separator, end_separator, extra_class)
  local ret = ''

  if not extra_class then
    extra_class = ''
  end
  if not separator then
    separator = ''
  end

  for i = start, end_-1 do
    local ii = i + 2

    if i == end_-1 and not end_separator then
      separator = ''
    end

    ret = ret
      .. '<span id="ln'
      .. ii
      .. '" class="ln '
      .. extra_class
      .. '">'
      .. ii
      .. '</span>'
      .. separator
  end

  return ret
end

return M
