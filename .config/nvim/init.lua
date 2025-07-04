-- [[ Setting options ]]
-- See `:help vim.opt`

-- TODO:
-- - strict bindings for go to next error/todo/... (:Telescope jumplist)
-- - s/kickstart/sensible/
-- - move shortcuts to where plugin is initialized

vim.g.mapleader = '\\'
vim.g.maplocalleader = '\\'

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
vim.keymap.set('n', '<leader>c', '<cmd>close<CR>', { desc = 'Close window' })
vim.keymap.set('n', '<leader>C', '<cmd>close!<CR>', { desc = 'Close window (forcefully)' })
vim.keymap.set('n', '<leader>w', '<cmd>write!<CR>', { desc = 'Save buffer forcefully' })
vim.keymap.set('n', '<leader>x', '<cmd>xit!<CR>', { desc = 'Save buffer and exit forcefully' })
vim.keymap.set('n', '<leader>B', '<cmd>Gitsigns blame<CR>', { desc = 'Git blame' })
vim.keymap.set('n', '<F1>', '<cmd>setlocal spell!<CR>', { desc = 'Enable spell check' })
vim.keymap.set('i', '<F1>', '<cmd>setlocal spell!<CR>', { desc = 'Enable spell check' })
-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', 'Q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<leader>n', '<cmd>set number!<CR>', { desc = 'Exit terminal mode' })
-- Keep visual selection after indenting
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })

vim.keymap.set('n', '<C-w><C-w>', '<C-w><C-p>', { noremap = true, silent = true })

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

  -- telescope is slower then fzf, so for now fzf will be used for hot path,
  -- at least until the following will be resolved:
  --
  -- - https://github.com/nvim-telescope/telescope.nvim/issues/1423
  -- - https://github.com/nvim-telescope/telescope.nvim/pull/1491
  {
    'junegunn/fzf.vim',
    dependencies = {
      {
        'junegunn/fzf',
        build = function()
          vim.fn['fzf#install']()
        end,
      }
    },
    config = function()
      vim.keymap.set('n', '<C-p>', ':GFiles<CR>', { desc = '[S]earch [F]iles in Git index' })
      vim.keymap.set('n', 'sf', ':Files<CR>', { desc = '[S]earch [F]iles' })

      vim.api.nvim_create_user_command("GGrep", function(opts)
        local query

        if #opts.fargs > 0 then
          query = table.concat(opts.fargs, " ")
        else
          query = vim.fn.expand("<cword>")
        end

        local escaped = vim.fn["fzf#shellescape"](query)
        local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]

        vim.fn["fzf#vim#grep"](
          "git grep --line-number -- " .. escaped,
          vim.fn["fzf#vim#with_preview"]({ dir = git_root }),
          opts.bang and 1 or 0
        )
      end, {
        bang = true,
        nargs = "*"
      })
      vim.keymap.set('n', '<S-F>', ':GGrep<CR>', { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>b', ':Buffers<CR>', { desc = 'Search current [b]uffers' })
    end
  },

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
      vim.keymap.set('n', 'sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', 'sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', 'ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', 'sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', 'sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', 'sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', 's.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', 'sb', function() builtin.buffers({ sort_lastused = true, ignore_current_buffer = false }) end, { desc = '[ ] Find existing buffers' })
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
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
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
          ["rust_analyzer"] = function()
            require('lspconfig')["rust_analyzer"].setup({
              settings = {
                ["rust-analyzer"] = {
                  cargo = {
                    allFeatures = true,
                  },
                  -- checkOnSave = {
                  --   allFeatures = true,
                  --   command = "clippy",
                  -- },
                },
              },
            })
          end,
          ["lua_ls"] = function()
            require('lspconfig')["lua_ls"].setup({
              settings = {
                Lua = {
                  -- make the language server recognize "vim" global
                  diagnostics = {
                    globals = { "vim" },
                  },
                },
              },
            })
          end,
        }
      }
    end,
  },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- Known issues: https://github.com/rcarriga/nvim-dap-ui/issues/429#issuecomment-3029327715
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      local rtmin = vim.fn.system("kill -l SIGRTMIN"):gsub("%s+", "");
      -- Disable auto breakpoints for exceptions
      local pre_run_commands = {
        'breakpoint name configure --disable cpp_exception',
      }
      local post_run_commands = {
        'process handle -p false -s false SIGWINCH',
        -- For ClickHouse
        'process handle -p false -s false SIGUSR1',
        'process handle -p false -s false SIGUSR2',
        ('process handle -p false -s false %s'):format(rtmin),
      };

      dap.adapters.lldb = {
        type = 'executable',
        command = 'codelldb',
        name = "lldb"
      }
      dap.configurations.cpp = {
        {
          name = "Launch",
          type = "lldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
          preRunCommands = pre_run_commands,
          postRunCommands = post_run_commands,
        },
      }
      -- Optional for C and Rust to reuse same config
      dap.configurations.c = dap.configurations.cpp
      dap.configurations.rust = dap.configurations.cpp

      vim.keymap.set('n', 'du', dap.up, { desc = "DAP: Up" })
      vim.keymap.set('n', 'dU', dap.down, { desc = "DAP: Down" })
      vim.keymap.set('n', 'dc', dap.continue, { desc = "DAP: Continue" })
      vim.keymap.set('n', 'dn', dap.step_over, { desc = "DAP: Step Over / Next" })
      vim.keymap.set('n', 'ds', dap.step_into, { desc = "DAP: Step Into" })
      vim.keymap.set('n', 'dr', dap.step_out, { desc = "DAP: Step Out / Return" })
      vim.keymap.set('n', 'dD', function ()
          dap.disconnect()
          -- by some reason events does not work
          dapui.close()
      end, { desc = "DAP: Detach/Disconnect/Terminate" })
      vim.keymap.set('n', 'db', dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })
      vim.keymap.set("n", 'dB', function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "DAP: Conditional Breakpoint" })

      -- Function written with ChatGPT
      vim.keymap.set("n", "da", function()
        local Job = require("plenary.job")
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")

        Job:new({
          command = "pgrep",
          args = { "-u", os.getenv("USER"), "-a" },
          on_exit = function(j)
            local output = j:result()
            local processes = {}

            for _, line in ipairs(output) do
              local pid, cmd = line:match("^(%d+)%s+(.+)$")
              if pid and cmd then
                table.insert(processes, { pid = pid, cmd = cmd })
              end
            end

            vim.schedule(function()
              pickers.new({}, {
                prompt_title = "Attach to Process",
                finder = finders.new_table({
                  results = processes,
                  entry_maker = function(entry)
                    return {
                      value = entry,
                      display = entry.pid .. " - " .. entry.cmd,
                      ordinal = entry.cmd,
                    }
                  end,
                }),
                sorter = conf.generic_sorter({}),
                attach_mappings = function(prompt_bufnr, map)
                  actions.select_default:replace(function()
                    local selection = action_state.get_selected_entry()
                    if selection then
                      require("dap").run({
                        type = "lldb",
                        request = "attach",
                        pid = tonumber(selection.value.pid),
                        name = "Attach to process",
                        -- Disable auto breakpoints for exceptions
                        preRunCommands = pre_run_commands,
                        postRunCommands = post_run_commands,
                      })
                    end
                    -- Only close after we’ve safely accessed the selection
                    actions.close(prompt_bufnr)
                  end)
                  return true
                end,
              }):find()
            end)
          end,
        }):start()
      end, { desc = "DAP: Attach to Process (fuzzy)" })

      dapui.setup({
        mappings = {
          expand = "+",
          open = { "<CR>", "<2-LeftMouse>" },
          remove = "d",
          edit = "e",
          repl = "r",
        },
        layouts = {
          {
            -- You can change the order of elements in the sidebar
            elements = {
              { id = "repl", size = 0.2 },
              { id = "stacks", size = 0.5 },
              { id = "scopes", size = 0.2 },
              { id = "breakpoints", size = 0.1 },
              -- Watches are not regular thing
              { id = "watches", size = 00.01 },
              -- Useless
              -- { id = "console", size = 0.1 },
            },
            size = 100,
            position = "right",
          },
          -- {
          --   elements = { "repl", "console" },
          --   size = 80,
          --   position = "right",
          -- },
        },
      })
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      require("nvim-dap-virtual-text").setup()
    end
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
    "catppuccin/nvim",
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      require("catppuccin").setup {
        no_italic = true
      }
      vim.cmd.colorscheme "catppuccin"
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
