# Jeskape

Have you ever wanted to map keys in insert mode, but found that it causes the
mapped keys to lag? The reason for this is that neovim waits until it is sure
that you arent typing a mapped combination before inserting characters.

For example, some people like to map `jk` to `<esc>`, which, when using `imap`,
will cause `j` to not be typed until `timeoutlen` runs out, or another key is
pressed. Thankfully jeskape is here to save the day and get rid of that pesky
lag!

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

Configure the plugin using the `setup` function.

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
                -- Insert the name of the current buffer
                return vim.api.nvim_buf_get_name(0)
            end,
        },
    },
    -- The maximum length of time between keystrokes where they are still considered a part of
    -- the same mapping.
    timeout = vim.o.timeoutlen,
}
```

## Alternatives

You can also try some of these plugins if all you need is escaping insert mode.

- https://github.com/max397574/better-escape.nvim
- https://github.com/jdhao/better-escape.vim
- https://github.com/zhou13/vim-easyescape
