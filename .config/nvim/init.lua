-- [[ Setting options ]]
-- See `:help vim.opt`

-- TODO:
-- - strict bindings for go to next error/todo/...
-- - s/kickstart/sensible/
-- - suppress "Undefined global `vim`." in this file
-- - move shortcuts to where plugin is initialized
-- - telescope is slower then plain fzf (via GFiles)

vim.g.mapleader = '\\'
vim.g.maplocalleader = '\\'

vim.opt.mouse = ""
vim.opt.guicursor = ""
vim.opt.number = true
vim.opt.fileencodings = "default"
vim.opt.encoding = "utf8"
vim.opt.langmap = "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯЖ;ABCDEFGHIJKLMNOPQRSTUVWXYZ:,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz"
vim.opt.textwidth = 0
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.fileformat = "unix"
vim.opt.wildmenu = true
vim.opt.laststatus = 2
vim.opt.updatetime = 250

-- It is already in status line
vim.opt.showmode = false
-- vim.opt.wildcharm = "<Tab>"
-- vim.opt.splitbelow = true
vim.g.have_nerd_font = true

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.opt.inccommand = ''

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

vim.opt.wildignore:append({
  "*/.git/**", "*/.hg/**", "*/.svn/**", "*/.cmake**", "*/.bld**",
  "*/build/**", "*/__pycache__/**", "*/.egg-info/**",
  "*.exe", "*.so", "*.dll", "*.a", "*.o",
  "*.la", "*.lo", "*.pc", "*.in",
  "*.sw[poa]",
  "*.zip", "*.rar", "*.tgz", "*.gz", "*.tar", "*.zst", "*.bgz",
  "*.pyc", "*.whl"
})

-- autoread/autowrite
vim.opt.autowrite = true
vim.opt.autoread = true
vim.cmd([[
  autocmd FocusGained,BufEnter,CursorHold,CursorHoldI,VimResume * if mode() != 'c' | checktime | endif
]])
vim.opt.hidden = true
vim.g.editorconfig = false

if vim.fn.exists('+pastetoggle') == 1 then
  vim.opt.pastetoggle = '<leader>p'
end

-- FIXME: move to the TS section
vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldlevel = 1000

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

vim.keymap.set('n', '<leader>q', '<cmd>q<CR>', { desc = 'Quit' })
vim.keymap.set('n', '<leader>d', '<cmd>bdelete<CR>', { desc = 'Close buffer' })
vim.keymap.set('n', '<leader>D', '<cmd>bdelete!<CR>', { desc = 'Close buffer (forcefully)' })
vim.keymap.set('n', '<leader>c', '<cmd>close<CR>', { desc = 'Close window' })
vim.keymap.set('n', '<leader>C', '<cmd>close!<CR>', { desc = 'Close window (forcefully)' })
vim.keymap.set('n', '<leader>w', '<cmd>write!<CR>', { desc = 'Save buffer forcefully' })
vim.keymap.set('n', '<leader>x', '<cmd>xit!<CR>', { desc = 'Save buffer and exit forcefully' })
vim.keymap.set('n', '<leader>B', '<cmd>Gitsigns blame<CR>', { desc = 'Git blame' })
vim.keymap.set('n', '<F1>', '<cmd>setlocal spell!<CR>', { desc = 'Enable spell check' })
vim.keymap.set('i', '<F1>', '<cmd>setlocal spell!<CR>', { desc = 'Enable spell check' })
-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', 'lq', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<leader>n', '<cmd>set number!<CR>', { desc = 'Exit terminal mode' })

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          -- telescope is slower then fzf, I found this [2], but does not looks like it helps a lot.
          --   [1]: https://github.com/LunarVim/LunarVim/issues/3562
          path_display = nil,
          mappings = {
            i = {
              ['<c-k>'] = 'move_selection_previous',
              ['<c-j>'] = 'move_selection_next',
            },
          },
        },
        -- pickers = {}
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<C-p>',      builtin.git_files, { desc = '[S]earch [F]iles in Git index' })
      vim.keymap.set('n', 'sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', 'sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', 'sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', 'ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      -- For "part->setName(part->getNewName(part->info))"
      --            ^^^^^^^                                   -> matches setName
      vim.keymap.set('n', 'sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<S-F>', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      -- For "part->setName(part->getNewName(part->info))"
      --            ^^^^^^^                                   -> matches the whole line
      vim.keymap.set('n', 'sW', function() local word = vim.fn.expand("<cWORD>") builtin.grep_string({ search = word }) end, {desc = "[S]earch current [W]ord (more precise)"})
      vim.keymap.set('n', 'sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', 'sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', 'sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', 's.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', 'sb', builtin.buffers, { desc = '[ ] Find existing buffers' })
      -- For compatiblity
      vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader><leader>', builtin.keymaps, { desc = '[S]earch [K]eymaps' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })
    end,
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by nvim-cmp
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          -- FIXME:
          map('gh', '<cmd>ClangdSwitchSourceHeader<cr>', 'Switch header/module (.h/.cpp/.c)')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          -- NOTE: should I use <leader> here?
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          -- FIXME: does not work
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local servers = {
        clangd = {},
        pyright = {},
        rust_analyzer = {},
        lua_ls = {},
        bashls = {},
        dockerls = {},
        -- I do not know or want to know go, but occasionally I have to read it, and without LSP I cannot even do it
        gopls = {},

        yamlls = {
          yaml = {
            schemas = {
              ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.31.1-standalone-strict/all.json"] = "/*.yaml",
              ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
            }
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --
      -- To check the current status of installed tools and/or manually install
      -- other tools, you can run
      --    :Mason
      --
      -- You can press `g?` for help in this menu.
      --
      -- `mason` had to be setup earlier: to configure its options see the
      -- `dependencies` table for `nvim-lspconfig` above.
      --
      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp-signature-help',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        -- For more info `:help ins-completion`, "they" are telling that it is really good!
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          -- FIXME: not a useful shortcut
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          ['<C-y>'] = cmp.mapping.confirm { select = true },
          ['<C-j>'] = cmp.mapping.confirm { select = true },
          ['<CR>'] = cmp.mapping.confirm { select = true },

          ['<C-Space>'] = cmp.mapping.complete {},

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        sources = {
          {
            name = 'lazydev',
            -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
            group_index = 0,
          },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
          { name = 'nvim_lsp_signature_help' },
        },
      }
    end,
  },

  {
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('tokyonight').setup {
        styles = {
          comments = { italic = false },
        },
      }
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    opts = {
      ensure_installed = { 'bash', 'c', 'cmake', 'diff', 'sql', 'python', 'rust', 'lua', 'markdown', 'markdown_inline', 'vim', 'vimdoc' },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
  },

  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      signs = false,
      FIX = { alt = { "FIXME", "BUG", "XXX" } },
      NOTE = { alt = { "INFO" } },
      highlight = {
        pattern = [[.*<(KEYWORDS)\s*[^:]*\s*:]],
      },
    }
  },

  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et
