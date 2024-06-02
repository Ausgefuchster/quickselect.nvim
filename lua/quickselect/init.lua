local M = {}

local patterns = {
    hex = '#%x%x%x%x%x%x',
    short_hex = '#%x%x%x',
    rgb = 'rgb(%d+,%d+,%d+)',
    ip = '%d+%.%d+%.%d+%.%d+',
    email = '%w+@%w+%.%w+',
    url = 'https?://[%w-_%.%?%.:/%+=&]+',
    number = '%d%d%d%d+',
    path = '~/[%w-_%.%?%.:/%+=&]+',
}

local possible_labels = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

local function get_matches(lines)
    local matches = {}

    for _, pattern in pairs(patterns) do
        for i, line in pairs(lines) do
            local start = 1
            while start <= string.len(line) do
                local s, e = string.find(line, pattern, start)
                if s == nil then
                    break
                end

                local match = {
                    row = i - 1,
                    column = s - 1,
                    text = string.sub(line, s, e),
                }
                table.insert(matches, match)
                start = e + 1
            end
        end
    end

    return matches
end

local function clear(namespace_id, mark_ids, labels)
    for _, mark_id in pairs(mark_ids) do
        vim.api.nvim_buf_del_extmark(0, namespace_id, mark_id)
    end
    for _, label in pairs(labels) do
        vim.keymap.del('n', label)
    end
    vim.api.nvim_buf_clear_namespace(0, namespace_id, 0, -1)
    vim.keymap.del('n', '<esc>')
end

local function register_keymap(namespace_id, match, label, labels, marks)
    vim.keymap.set('n', label, function()
        vim.api.nvim_win_set_cursor(0, { match.row + 1, match.column })
        clear(namespace_id, marks, labels)
    end)
end

function M.setup(opts)
    vim.keymap.set('n', '<leader>qs', function()
        local lines = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
        local matches = get_matches(lines)
        local namespace_id = vim.api.nvim_create_namespace('quickselect')
        local marks = {}
        local labels = {}
        for _, match in pairs(matches) do
            local label = string.sub(possible_labels, #marks + 1, #marks + 1)
            local mark_id = vim.api.nvim_buf_set_extmark(0, namespace_id, match.row, match.column, {
                virt_text = {
                    { label }
                },
                virt_text_pos = 'overlay',
            })
            table.insert(marks, mark_id)
            table.insert(labels, label)
            register_keymap(namespace_id, match, label, labels, marks)
        end

        vim.keymap.set('n', '<esc>', function()
            clear(namespace_id, marks, labels)
        end)
    end)
end

function M.quick_select()
end

return M
