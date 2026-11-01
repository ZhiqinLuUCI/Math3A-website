#!/bin/zsh
cd -- "${0:A:h}"
quarto preview --no-browser
