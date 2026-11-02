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
hook global BufCreate .*\.(krt|skr) %{
    set-option buffer filetype karuta
    set-option buffer extra_word_chars '_' '-' ':'
}

hook global BufSetOption filetype=karuta %{
    require-module karuta
    add-highlighter buffer/karuta ref karuta
}

provide-module karuta %{
    add-highlighter shared/karuta regions
    add-highlighter shared/karuta/string region '"' '"' fill string
    add-highlighter shared/karuta/quoted-atom region "'" "'" fill string
    add-highlighter shared/karuta/line-comment region '(?<!#)%' '$' fill comment
    add-highlighter shared/karuta/code default-region group

    # Language directives.
    add-highlighter shared/karuta/code/keyword regex '\b(module|signature|project|comment|sakura|persisted|ephemeral|constraint|import|karuta|begin|end)\b' 1:keyword

    add-highlighter shared/karuta/code/variable regex '\b([A-Z_]\w*)\b' 1:variable

    add-highlighter shared/karuta/code/atom regex '\b([a-z][a-zA-Z0-9_-]*)\b(?![\[(])' 1:value

    add-highlighter shared/karuta/code/predicate regex '\b([a-z][a-zA-Z0-9_-]*)(?=[\[(])' 1:function

    add-highlighter shared/karuta/code/qualifier regex '\b([a-z][a-zA-Z0-9_-]*)(:)(?=[a-z])' 1:type 2:punctuation

    add-highlighter shared/karuta/code/number regex '\b(-?[0-9]+)\b' 1:value

    add-highlighter shared/karuta/code/arrow regex ':-' 0:operator
    add-highlighter shared/karuta/code/query regex '\?' 0:operator
    add-highlighter shared/karuta/code/bracket regex '[{}\[\]()]' 0:punctuation
    add-highlighter shared/karuta/code/separator regex '[,\.]' 0:puncuation
    add-highlighter shared/karuta/code/pipe regex '\|' 0:operator

    # Karuta's #%-comment comments out one expression, not the rest of the line.
    add-highlighter shared/karuta/code/expression-comment regex '#%' 0:comment
}
