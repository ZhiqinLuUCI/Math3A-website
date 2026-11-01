#!/bin/zsh
cd -- "${0:A:h}"
# Quarto watches the source files, rebuilds changed pages, and refreshes the
# browser automatically. Keep this Terminal window open while editing.
quarto preview
