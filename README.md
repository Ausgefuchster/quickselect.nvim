# 🏁 quickselect.nvim

Quickselect is inspired by [wezterm](https://github.com/wez/wezterm).
It allows you to quickly jump to patterns in the buffer.

## 🌟 Features

- Quickly jump to patterns in the buffer and select them
- Quick yank patterns in the buffer without moving the cursor
- Customizable patterns

## 📦 Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
    "ausgefuchster/quickselect.nvim",
    event = "VeryLazy",
    opts = {
        patterns = {
            -- Add your patterns here
        },
        keymap = {
            {
                mode = { 'n' },
                '<leader>qs',
                function()
                    require('quickselect').quick_select()
                end,
                desc = 'Quick select'
            },
            {
                mode = { 'n' },
                '<leader>qy',
                function()
                    require('quickselect').quick_yank()
                end,
                desc = 'Quick yank'
            }
        },
    },
}
```

## ⚙️  Configuration

### Default

<!-- Add collabsible for default conifg -->
<details>
<summary>Default Configuration</summary>

```lua
{
    patterns = {
        -- Hex color
        "#%x%x%x%x%x%x",
        -- Short-Hex color
        "#%x%x%x",
        -- RGB color
        "rgb(%d+,%d+,%d+)",
        -- IP Address
        "%d+%.%d+%.%d+%.%d+",
        -- Email
        "%w+@%w+%.%w+",
        -- URL
        "https?://[%w-_%.%?%.:/%+=&]+",
        -- 4+ digit number
        "%d%d%d%d+",
        -- File path
        "~/[%w-_%.%?%.:/%+=&]+",
    },
    select_match = true,
    use_default_patterns = true,
    labels = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
    keymap = {
    },
}
```
</details>

## 🚀 Usage

Require `quickselect` and call one of the following functions:

- `quick_select()`: Quick select patterns in the buffer
- `quick_yank()`: Quick yank patterns in the buffer

```lua
require('quickselect').quick_select()
require('quickselect').quick_yank()
```
