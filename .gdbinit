# Generic GDB mermaid diagram generator
source ~/.config/gdb/gdb_mermaid.py

set disassembly-flavor intel
set debuginfod enabled off   
set history save
set verbose off
set print pretty on
set print array off
set print array-indexes on
set print address off

# TUI
tui new-layout hsplit {-horizontal src 1 asm 1} 1 status 0 cmd 1
set tui border-kind ascii
set tui border-kind space
set style tui-active-border foreground black
set style tui-border foreground none

# REMOVE HASHES IN RUST
set language rust
set print demangle on
set print asm-demangle on
set print address off
set filename-display basename

tui enable
