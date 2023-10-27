local M = {}

M.get_root_class = function(cur_name, hi_table, walked)
  
  -- avoids infinite loops
  if walked ~= nil then
    for _, v in ipairs(walked) do
      if v == cur_name then
        return nil
      end
    end

    table.insert(walked,cur_name)
  elseif walked == nil then
    walked = { cur_name }
  end

  if not not hi_table[cur_name].link then
    if hi_table[hi_table[cur_name].link] == nil then
      return nil
    end
    return M.get_root_class(hi_table[cur_name].link, hi_table,walked)
  end

  return cur_name
end

return M
