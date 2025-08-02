vim.lsp.config.rust_analyzer = {
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

      check = {
        command = "clippy",
        features = "all",
        allTargets = true,
      },
      diagnostics = {
        styleLints = { enable = true }
      },

    --   diagnostics = {
    --     enable = false;
    --   },
    --   checkOnSave = true,
    --   check = {
    --     features = "all",
    --     command = "clippy",
    --     extraArgs = {
    --       "--",
    --       "--no-deps",
    --       "-Dclippy::correctness",
    --       "-Dclippy::complexity",
    --       "-Wclippy::perf",
    --       "-Wclippy::pedantic",
    --     },
    --   },
    }
  }
}

vim.lsp.config.gopls = {
  cmd = { 'gopls' },
  root_markers = { '.direnv', 'flake.nix', 'go.mod' },
  filetypes = {'go'},
}

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
  end,
})

-- vim.lsp.config.hls.setup {
--   filetypes = { 'haskell', 'lhaskell', 'cabal' },
--   settings = {
--     haskell = {
--       formattingProvider = "fourmolu",
--       cabalFormattingProvider = "cabalfmt",
--     }
--   },
--   cmd = { "haskell-language-server-9.10.1", "--lsp" }
-- }

-- vim.lsp.config.ts_ls.setup{
--   cmd = { "typescript-language-server", "--stdio", "--tsserver-path", "tsserver" }
-- }

-- vim.lsp.config.elixirls.setup {
--   cmd = { "elixir-ls" },
--   root_dir = require("vim.lsp.config.util").root_pattern(".git")
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

vim.lsp.enable({'rust_analyzer', 'nil_ls', 'gopls', 'typescript_ls'})

vim.cmd("set completeopt+=noselect")
vim.o.winborder = 'rounded'
