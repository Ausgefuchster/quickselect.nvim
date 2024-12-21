local M = {}

local function get_matches(lines, patterns)
    local matches = {}

    for _, pattern in ipairs(patterns) do
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

local function buf_get_matches(patterns)
    local lines = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
    return get_matches(lines, patterns)
end

local function highlight_and_mark(match, label, namespace_id)
    vim.api.nvim_buf_add_highlight(0, namespace_id, 'Search', match.row, match.column, match.column + string.len(match.text))
    local mark_id = vim.api.nvim_buf_set_extmark(0, namespace_id, match.row, match.column, {
        virt_text = {
            { label, 'CurSearch' }
        },
        virt_text_pos = 'overlay',
    })

    return mark_id
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

local function register_keymap(namespace_id, match, label, labels, marks, match_action)
    vim.keymap.set('n', label, function()
        match_action(match)
        clear(namespace_id, marks, labels)
    end)
end

M.default_config = {
    patterns = {
        -- Hex color
        '#%x%x%x%x%x%x',
        -- Short-Hex color
        '#%x%x%x',
        -- RGB color
        'rgb(%d+,%d+,%d+)',
        -- IP Address
        '%d+%.%d+%.%d+%.%d+',
        -- Email
        '%w+@%w+%.%w+',
        -- URL
        'https?://[%w-_%.%?%.:/%+=&]+',
        -- 4+ digit number
        '%d%d%d%d+',
        -- File path
        '~/[%w-_%.%?%.:/%+=&]+',
    },
    select_match = true,
    use_default_patterns = true,
    labels = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
    keymap = {
    },
}

function M.setup(opts)
    opts = opts or {}
    if opts.use_default_patterns == nil then
        opts.use_default_patterns = M.default_config.use_default_patterns
    end
    if opts.use_default_patterns == true then
        if opts.patterns == nil then
            opts.patterns = M.default_config.patterns
        else
            opts.patterns = vim.list_extend(opts.patterns, M.default_config.patterns)
        end
    end
    if opts.labels == nil then
        opts.labels = M.default_config.labels
    end
    if opts.select_match == nil then
        opts.select_match = M.default_config.select_match
    end

    M.config = opts

    if opts.keymap == nil then
        return
    end

    for _, keymap in ipairs(opts.keymap) do
        for _, mode in ipairs(keymap.mode) do
            if mode ~= 'n' and mode ~= 'v' and mode ~= 'i' and mode ~= 'x' then
                error('Invalid mode: ' .. mode)
            end
            if keymap[1] == nil or keymap[2] == nil then
                error('Invalid keymap: ' .. keymap)
            end
            vim.keymap.set(mode, keymap[1], keymap[2], { desc = keymap.desc })
        end
    end
end

function M.quick_select()
    local matches = buf_get_matches(M.config.patterns)
    if #matches == 0 then
        return
    end

    local marks = {}
    local labels = {}
    local namespace_id = vim.api.nvim_create_namespace('quickselect')
    for _, match in pairs(matches) do
        local label = string.sub(M.config.labels, #marks + 1, #marks + 1)
        local mark_id = highlight_and_mark(match, label, namespace_id)

        table.insert(marks, mark_id)
        table.insert(labels, label)
        register_keymap(namespace_id, match, label, labels, marks, function(match)
            vim.api.nvim_win_set_cursor(0, { match.row + 1, match.column })

            if M.config.select_match == true then
                vim.cmd('normal! v')
                vim.api.nvim_win_set_cursor(0, { match.row + 1, match.column + string.len(match.text) - 1})
            end
        end)
    end

    vim.keymap.set('n', '<esc>', function()
        clear(namespace_id, marks, labels)
    end)
end

function M.quick_yank()
    local matches = buf_get_matches(M.config.patterns)
    if #matches == 0 then
        return
    end

    local marks = {}
    local labels = {}
    local namespace_id = vim.api.nvim_create_namespace('quickselect')
    for _, match in pairs(matches) do
        local label = string.sub(M.config.labels, #marks + 1, #marks + 1)
        local mark_id = highlight_and_mark(match, label, namespace_id)

        table.insert(marks, mark_id)
        table.insert(labels, label)
        register_keymap(namespace_id, match, label, labels, marks, function(match)
            local current_cursor = vim.api.nvim_win_get_cursor(0)

            vim.api.nvim_win_set_cursor(0, { match.row + 1, match.column })

            vim.cmd('normal! v')
            vim.api.nvim_win_set_cursor(0, { match.row + 1, match.column + string.len(match.text) - 1})
            vim.cmd('normal! y')

            vim.api.nvim_win_set_cursor(0, current_cursor)
        end)
    end

    vim.keymap.set('n', '<esc>', function()
        clear(namespace_id, marks, labels)
    end)
end

return M
