local capture = {}
local nvim = vim.api

local function print_err(msg)
  nvim.nvim_err_writeln('[nvim-capture] ' .. msg)
end

capture.capture = function (template_name)
  if nvim.nvim_call_function('exists', {'g:capture_templates'}) == 0 then
    print_err("No templates defined! There aren't any default templates yet!")
    return
  end

  local templates = nvim.nvim_get_var('capture_templates')
  local template = templates[template_name]
  if not template then
    print_err('No capture template named ' .. template_name .. '!')
    return
  end

  -- Edit the specified file at the specified position
  -- Evaluate the filename in case it's an expression
  local target_file = nvim.nvim_call_function('expand', {template['file']})
  nvim.nvim_command('e ' .. target_file)
  local pattern = nvim.nvim_call_function('expand', {template['pattern']})
  local target_line = nvim.nvim_call_function('search', {pattern, 'nc'})
  if target_line == 0 then
  -- Expand the specified UltiSnips template
    nvim.nvim_command('normal Gi')
    nvim.nvim_call_function('UltiSnips#Anon', {template['new_snip']})
  else
    nvim.nvim_call_function('cursor', {target_line, 0})
    if template['extend_pattern'] then
      local extend_pattern = nvim.nvim_call_function('expand', {template['extend_pattern']})
      local extend_line = nvim.nvim_call_function('search', {extend_pattern, 'n'})
      if extend_line == 0 then
        print_err("Couldn't find the marker for entry end!")
        extend_line = target_line
      end
      nvim.nvim_call_function('cursor', {extend_line, 0})
    end
    nvim.nvim_command('normal o')
  -- Expand the specified UltiSnips template
  if template['extend_snip'] then
    nvim.nvim_call_function('UltiSnips#Anon', {template['extend_snip']})
  end
  end
end

return capture

