local M = {}

local function buffer_to_string()
    local content = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
    return table.concat(content, "\n")
end

local patterns = {
    hex = '#%x%x%x%x%x%x',
    short_hex = '#%x%x%x',
    rgb = 'rgb(%d+,%d+,%d+)',
    ip = '%d+%.%d+%.%d+%.%d+',
    email = '%w+@%w+%.%w+',
    url = 'https?://[%w-_%.%?%.:/%+=&]+',
    number = '%d%d%d%d+',
}

local function get_matches(text)
    local matches = {}

    for _, pattern in pairs(patterns) do
        print('pattern', pattern)
        local start = 1
        while start <= string.len(text) do
            local s, e = string.find(text, pattern, start)
            if s == nil then
                break
            end

            local match = {
                start = s,
                finish = e,
                text = string.sub(text, s, e),
            }
            table.insert(matches, match)
            start = e + 1
        end
    end

    return matches
end

function M.setup(opts)
    vim.keymap.set('n', '<leader>qs', function()
        local buffer = buffer_to_string()
        local matches = get_matches(buffer)
    end)
end

function M.quick_select()
    print("Hello from quickselect")
end

return M
