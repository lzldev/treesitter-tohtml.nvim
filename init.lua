local M = {}

return {
  setup = function(opts)
    vim.print 'hello'
    vim.print 'HELLO FROM NEW PLUGIN'
  end,
  config = function(opts)
    vim.print 'config'
    vim.print 'HELLO FROM NEW PLUGIN.config'
  end,
}
