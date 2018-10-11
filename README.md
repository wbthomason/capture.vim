# capture.vim

A weak mimicry of `org-capture` for Vim and Neovim.

# Installation

Use your favorite plugin manager, or manually install like any other plugin.
[UltiSnips](https://github.com/SirVer/ultisnips) is a required dependency; if there's interest, I
might try to get rid of the need for it in the future (or at least make  `capture.vim` work with
other snippet engines).

For example, using `plug.vim`, you would write:
```vim
Plug 'wbthomason/capture.vim' | Plug 'SirVer/ultisnips'
```

# Usage

To use `capture.vim`, you need to define your custom _capture templates_. A capture template
minimally defines
a file or filename format to which to capture your data, a search pattern to determine where a new
entry should start, and an UltiSnips-format snippet to insert for each new entry. It optionally also
defines a search pattern and snippet for _extending_ entries. Capture templates live in the
`g:capture_templates` variable.

More specifically, a capture template looks like the following:
```vim
let g:capture_templates = {
  \ 'foo': " The name of the template
  \ { 'file': '~/foo.md', " The filename or filename pattern to use. 
  \                       " The pattern can use the following variables: %d - day, %y - year, %M - month,
  \                       " %h - hh hour, %m - mm minute, %s - ss second, %w - weekday name,
  \                       " %D - yyyymmdd date, %H - hostname, %u - user, %f - current filename
  \   'pattern': '^# Test <c-r>=strftime("%c")<cr>', " The search pattern for a new entry. This can be any
  \                                                  " valid vimscript search expression.
  \   'new_snip': '# Test `!v strftime("%c")`', " The UltiSnips snippet to insert for a new entry
  \   'extend_pattern': '.*$', " The search pattern to determine where to extend an existing entry
  \   'extend_snip': 'Have some more foo!' " The UltiSnips snippet to insert when extending an entry
  \}
```

`capture.vim` defines a single command: `:Capture <template name>`. Map it, run it directly, etc.

Note that while the allowable variables in the capture file path are somewhat restricted, I'm open
to either adding more options or implementing a better method of permitting capture file path
formats.

# Rationale/Purpose

I often find myself wanting to jot a quick note in a larger notes file, or make a journal entry
automatically timestamped with the date and time, or in some other way _capture_ a piece of
information into a templated format quickly and easily. I was not aware of any other plugins
providing this full functionality, so I wrote `capture.vim` (originally as an exercise in writing
Neovim plugins in embedded Lua, but quickly translated to Vimscript (a) for Vim compatibility and
(b) because I don't need the speed benefits of Lua when 90% of the plugin's work is calling Vim
functions).

This functionality is something that `org-capture` from `org-mode` in Emacs provides nicely, which I
missed upon returning from the land of Evil Emacs to using Neovim. `org-capture` has additional
integrations with the rest of `org-mode` (adding to an agenda, etc.) that I have not implemented
here. I hope someone else finds the core capturing functionality useful!

# Examples

Here are some practical example templates that I use in my configuration:

```vim
let g:capture_templates = {
      \ 'journal': {'file': '~/wiki/journal/journal.md',
      \             'pattern': '^# ',
      \             'new_snip': '# `!v strftime("%A, %F")`^M^M## `!v strftime("%R")` - ${1:title}^M^M${0:entry}',
      \             'extend_pattern': '.\+$',
      \             'extend_snip': '^M## `!v strftime("%R")` - ${1:title}^M^M${0:entry}'},
      \ 'research': {'file': '~/wiki/research.md',
      \             'pattern': '^# ',
      \             'new_snip': '# `!v strftime("%A, %F")`^M^M## `!v strftime("%R")` - ${1:title}^M^M${0:entry}',
      \             'extend_pattern': '.\+$',
      \             'extend_snip': '^M## `!v strftime("%R")` - ${1:title}^M^M${0:entry}'},
      \ 'advisor': {'file': '~/wiki/advisor_meetings.md',
      \             'pattern': '^# ',
      \             'new_snip': '# `!v strftime("%A, %F")`^M^M${0:meeting_notes}'},
      \}
```
