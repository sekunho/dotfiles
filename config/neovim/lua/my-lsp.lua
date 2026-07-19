vim.lsp.config.rust_analyzer = {
  workspace_required = true,
  cmd = { 'rust-analyzer' },
  root_markers = { '.direnv', 'flake.nix', 'Cargo.toml' },
  filetypes = {'rust'},

  capabilities = {
    experimental = {
      serverStatusNotification = true,
    },
  },

  settings = {
    ['rust_analyzer'] = {
      excludeGlobs = {".direnv/**", "target/**"},
      files = {
        excludeDirs = { ".direnv", ".devenv", "node_modules" },
      },

      cargo = {
        targetDir = null,
        allTargets = false,
      },

      check = {
        command = "clippy",
        allTargets = false,
      },

      checkOnSave = false,
      procMacro = { enable = true },

      diagnostics = {
        styleLints = { enable = true }
      },
    }
  }
}

vim.lsp.config.gopls = {
  cmd = { 'gopls' },
  root_markers = { '.direnv', 'flake.nix', 'go.mod' },
  filetypes = {'go'},
}

vim.lsp.config.clangd = {
  cmd = { 'clangd'},
  root_markers = { ".direnv", "flake.nix", ".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", "compile_flags.txt", "configure.ac", ".git" }
};

vim.lsp.config.typescript_ls = {
  cmd = { 'typescript-language-server', "--stdio", "--tsserver-path", "tsserver" },
  root_markers = { 'package.json', 'flake.nix' },
  filetypes = {'typescript'}
};

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
    client.server_capabilities.semanticTokensProvider = nil
  end,
})

-- vim.lsp.config.ts_ls.setup{
--   cmd = { "typescript-language-server", "--stdio", "--tsserver-path", "tsserver" }
-- }

vim.lsp.config.nil_ls = {
  root_markers = { 'flake.nix' },
  filetypes = { 'nix' },
  cmd = { "nil" },
  settings = {
    ['nil'] = {
      testSetting = 42,
      formatting = {
        command = { "nixpkgs-fmt" },
      },
    },
  },
}

vim.lsp.config.css_variables = {
  cmd = { 'css-variables-language-server', '--stdio' },
  root_markers = { 'package.json', 'flake.nix', '.git' },
  filetypes = { 'css', 'scss', 'less' },
  settings = {
    cssVariables = {
      lookupFiles = { '**/*.less', '**/*.scss', '**/*.sass', '**/*.css' },
      blacklistFolders = {
        '**/.direnv', '**/.cache', '**/.git', '**/.hg', '**/.next', '**/.svn',
        '**/bower_components', '**/CVS', '**/dist', '**/node_modules', '**/tmp',
      },
    },
  },
}

vim.keymap.set('i', '<Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-n>' or '<Tab>'
end, { expr = true })
vim.keymap.set('i', '<S-Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>'
end, { expr = true })

vim.keymap.set('i', '<CR>', function()
  if vim.fn.pumvisible() == 1 and vim.fn.complete_info({ 'selected' }).selected ~= -1 then
    return '<C-y>'
  end
  return '<CR>'
end, { expr = true })

-- require("crates").setup {
--   lsp = {
--     enabled = true,
--     actions = true,
--     completion = true,
--     hover = true,
--   },
-- }

vim.lsp.config.nixd = {
  cmd = { 'nixd' },
  filetypes = { 'nix' },
  root_markers = { 'flake.nix', '.git' },
}

vim.lsp.enable({'rust_analyzer', 'nil_ls', 'gopls', 'typescript_ls', 'css_variables', 'nixd', 'basedpyright', 'ruff', 'clangd'})

vim.o.completeopt = 'menuone,noselect,popup,fuzzy'
vim.o.winborder = 'rounded'
