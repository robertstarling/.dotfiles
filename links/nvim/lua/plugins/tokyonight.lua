return {
  { -- Color scheme
    'folke/tokyonight.nvim',

    -- Make sure to load this before all the other start plugins.
    priority = 1000,
    init = function()
      vim.cmd.colorscheme 'tokyonight'

      -- Comments are italicized by default in tokyonight, and it's ugly.
      vim.cmd.hi 'Comment gui=none'

      -- Make the colorcolumn the same color as the default background.
      -- This way, it will only be visible on the current line (thanks to the cursorline setting).
      vim.cmd 'hi! link ColorColumn Normal'

      -- I want the "vim crosshair", but the cursorcolumn is too much. This tones it
      -- down a bit by using a darker color that more closely matches the background.
      vim.cmd.hi 'CursorColumn guibg=#1d2133'
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
