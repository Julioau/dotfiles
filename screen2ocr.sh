#!/bin/bash
# grim seleciona uma região, slurp captura essa região.
# esse é o programinha de OCR, ele recebe a imagem capturada, 
# manda todos os erros pra /dev/null (imporante!)
# regex hacks, eu pedi ajuda pro GPT pra isso, ainda é meio que mágica
# eu só queria uniformizar o texto, de vez em quando, dependendo da fonte
# o output sai com dois ' ' repetidos, ou dois '\n',   etc...
# bota no meu clipboard
grim -g "$(slurp -d)" - | \
tesseract stdin stdout $1 2>/dev/null --psm 4 | \
sed -E ':a;N;$!ba;s/[[:space:]]+/ /g;s/^[[:space:]]+|[[:space:]]+$//g' | \
wl-copy                                                                     
