function! s:PrintErr(msg)
  echoerr '[vim-capture] ' . a:msg
endfunction

function! s:CheckTemplate(template)
  if !has_key(a:template, 'file') || !has_key(a:template, 'pattern') || !has_key(a:template, 'new_snip')
    return v:false
  endif

  return v:true
endfunction

function! s:SubstitutePathVars(file_path)
  let day = strftime('%d')
  let year = strftime('%Y')
  let month = strftime('%m')
  let hour = strftime('%H')
  let minute = strftime('%M')
  let second = strftime('%S')
  let weekday = strftime('%A')
  let full_date = year . month . day
  let hostname = hostname()
  let user = $USER
  let filename = expand('%:t')

  let file_path = fnamemodify(a:file_path,
        \ ':gs?%d?' . day . '?'
        \ . ':gs?%y?' . year . '?'
        \ . ':gs?%\Cm?' . month . '?'
        \ . ':gs?%\Ch?' . hour . '?'
        \ . ':gs?%\CM?' . minute . '?'
        \ . ':gs?%s?' . second . '?'
        \ . ':gs?%w?' . weekday . '?'
        \ . ':gs?%D?' . full_date . '?'
        \ . ':gs?%\CH?' . hostname . '?'
        \ . ':gs?%u?' . user . '?'
        \ . ':gs?%f?' . filename . '?')

  return file_path
endfunction

function! capture#Capture(template_name)
  if !exists('g:capture_templates')
    call s:PrintErr('No templates defined!')
  endif

  if !has_key(g:capture_templates, a:template_name)
    call s:PrintErr('No capture template named: ' . a:template_name)
    return -1
  endif

  let template = g:capture_templates[a:template_name]
  " Check that the template has at least the required fields
  if !s:CheckTemplate(template)
    call s:PrintErr('The template for ' . a:template_name . ' is missing fields')
    return -1
  endif

  " Edit the specified file at the requested point
  " Expand variables in the template file path
  let target_file = s:SubstitutePathVars(template.file)
  execute 'edit' target_file
  let target_line = search(template.pattern, 'nc')
  if target_line ==? 0
    let insert_command = 'normal! G'
    if line('$') > 1
      let insert_command = insert_command . 'o'
    else
      let insert_command = insert_command . 'i'
    endif

    execute insert_command
    call UltiSnips#Anon(template.new_snip)
  else
    call cursor(target_line, 0)
    if has_key(template, 'extend_pattern')
      let extend_line = search(template.extend_pattern, 'n')
      if extend_line ==? 0
        call s:PrintErr("Couldn't find the marker for entry end!")
        let extend_line = target_line
      endif

      call cursor(extend_line, 0)
    endif
    execute 'normal! o'
    if has_key(template, 'extend_snip')
      call UltiSnips#Anon(template.extend_snip)
    endif
  endif
endfunction
