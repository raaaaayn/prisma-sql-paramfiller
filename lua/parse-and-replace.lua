local run_formatter = function(text)
	text = text:gsub("`", "")
	local split = vim.split(text, "\n")
	local text_copy = vim.list_slice(split, 1, #split)
	local result = table.concat(text_copy, "\n")

	local bin = vim.api.nvim_get_runtime_file("bin/sql-format-via-python.py", false)[1]

	local j = require("plenary.job"):new {
		command = "python3",
		args = { bin },
		writer = { result },
	}
	return j:sync()
end

local parse_dat_sql = function(bufnr)
	print("Running")
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	if vim.bo[bufnr].filetype ~= "sql" then
		vim.notify "can only be used in sql"
		return
	end

	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false);

	local sql_query;
	local params;

	for _, line in ipairs(lines) do
		if string.match(line, "select.*") then
			sql_query = line
		elseif string.match(line, "SELECT.*") then
			sql_query = line
		elseif string.match(line, "Params.*") then
			params = line
		end
	end


	local count = 1

	for param in string.gmatch(params, '[_a-zA-Z0-9":.|>< -]+[,\\%]]') do
		local replace_str = param.gsub(param, '[,\\%]]', "");
		replace_str = replace_str.gsub(replace_str, '"', '\'')
		local param_num = string.gsub(string.format("$%q", count), '"', "");
		sql_query = sql_query.gsub(sql_query, param_num, replace_str, 1)
		count = count + 1;
	end

	local formatted = run_formatter(sql_query)
	local total_lines = 0

	for _, _ in pairs(formatted) do
		total_lines = total_lines + 1
	end

	vim.api.nvim_buf_set_lines(bufnr, 0, total_lines, false, formatted)
end

local M = {}

function M.setup()
	vim.api.nvim_create_user_command("ParseReplace", function()
		parse_dat_sql()
	end, {})
end

return M
