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

return M
