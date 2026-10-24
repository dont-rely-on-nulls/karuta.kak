# karuta.kak -- Kakoune support for the Karuta language
#
# Copyright (C) 2026 Marcos Magueta
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Supports Karuta source (.krt) and Sakura database (.skr) files.
# Load with: source /path/to/karuta.kak
#
# Uses Kakoune's conventional faces so the active colorscheme controls colors.

# Detect Karuta and Sakura files.
hook global BufCreate .*\.krt$ %{
    set-option buffer filetype karuta
}
hook global BufCreate .*\.skr$ %{
    set-option buffer filetype karuta
}

# Strings and comments are regions, so token rules do not affect their contents.
add-highlighter shared/karuta regions
add-highlighter shared/karuta/string region '"' '"' fill String
add-highlighter shared/karuta/line-comment region '(?<!#)%' '$' fill Comment
add-highlighter shared/karuta/code default-region group

# Language directives.
add-highlighter shared/karuta/code/keywords regex '\b(module|signature|project|comment|sakura|persisted|ephemeral|constraint|import|karuta|begin|end)\b' 0:Keyword

# Logic variables: X, Out, NewAcc, _Tail, and _.
add-highlighter shared/karuta/code/variables regex '\b([A-Z_][a-zA-Z0-9_]*)\b' 1:Variable

# Plain lower-case atoms used as constants.
add-highlighter shared/karuta/code/atoms regex '\b([a-z][a-zA-Z0-9_-]*)\b' 1:Builtin

# Predicate/functor names are lower-case atoms immediately followed by
# an argument/list opener.
add-highlighter shared/karuta/code/predicates regex '\b([a-z][a-zA-Z0-9_-]*)(?=[\[(])' 1:Function

# Module qualifiers, e.g. karuta: or a: in a:b:predicate.
# Requiring a following atom avoids treating the :- rule arrow as a qualifier.
add-highlighter shared/karuta/code/qualifiers regex '\b([a-z][a-zA-Z0-9_-]*)(:)(?=[a-zA-Z_])' 1:Type 2:Type

# Numeric literals, including negative integers.
add-highlighter shared/karuta/code/numbers regex '\b(-?[0-9]+)\b' 1:Value

# Operators and delimiters.
add-highlighter shared/karuta/code/arrow regex '(:-)' 1:Operator
add-highlighter shared/karuta/code/query regex '(\?)' 1:Operator
add-highlighter shared/karuta/code/range regex '(\.\.)' 1:Operator
add-highlighter shared/karuta/code/braces regex '([{}])' 1:Bracket
add-highlighter shared/karuta/code/brackets regex '([\[\]()])' 1:Bracket
add-highlighter shared/karuta/code/separators regex '([,|])' 1:Operator

# Karuta's #%-comment comments out one expression, not the rest of the line.
# Kakoune's regex/region highlighters do not parse nested Karuta expressions,
# so highlight the introducer rather than incorrectly swallowing later code.
add-highlighter shared/karuta/code/expression-comment regex '(#%)' 1:Comment

# Attach syntax and sensible indentation defaults to Karuta buffers.
hook global WinSetOption filetype=karuta %{
    add-highlighter window/ ref karuta
    set-option buffer indentwidth 2
    set-option buffer tabstop 2
    set-option buffer makecmd 'karuta compile %val{buffile}'
}
