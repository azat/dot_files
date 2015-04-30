setlocal foldmethod=expr foldlevel=1 foldminlines=2
setlocal foldexpr=match(substitute(getline(v:lnum),'\\s','','g'),'[^>]\\\|$')
setlocal foldenable

set spell
