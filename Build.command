#!/bin/zsh
cd -- "${0:A:h}"
quarto render
printf '\nWebsite built in the _site folder.\n'
read '?Press Return to close.'
