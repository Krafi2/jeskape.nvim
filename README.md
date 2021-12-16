# Jeskape

Have you ever wanted to map keys in insert mode, but found that it causes the
mapped keys to lag? This happens because neovim waits until it is sure that you
aren't typing a mapped combination before inserting characters. Jeskape works
around the issue by implementing its own mapping system for insert mode.

## Installation

Install using your favourite package manager.

```lua
-- with packer.nvim
use {
    "Krafi2/jeskape.nvim",
    config = function()
        require("jeskape").setup()
    end,
}
```

## Configuration

You can configure the plugin using the `setup` function.

```lua
require("jeskape").setup {
    -- Mappings are specified in this table
    mappings = {
        -- Typing `hi` quickly will cause the string `hello!` to be inserted
        hi = "hello!",
        -- They can also be specified in a tree-like format
        j = {
            -- Here `jk` will escape insert mode
            k = "<esc>",
            -- You can have as many layers as you want!
            h = {
                g = "I pressed jhg!",
            },
            -- If the mapping leads to a function, it will be evaluated every
            -- time the mapping is reached and its return value will be fed to
            -- neovim
            f = function()
                print("Oh look, a function!")
                -- Insert the name of the current file
                return vim.fn.expand "%:t"
            end,
        },
        -- Special characters
        [";"] = {
            [";"] = "<esc>A;<enter>",
        },
    },
    -- The maximum length of time between keystrokes where they are still considered a part of
    -- the same mapping.
    timeout = vim.o.timeoutlen,
}
```

## Alternatives

You can also try one of these plugins if all you need is escaping insert mode.

- https://github.com/max397574/better-escape.nvim
- https://github.com/jdhao/better-escape.vim
- https://github.com/zhou13/vim-easyescape
