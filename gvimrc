" --- GUI options ---

" Font
if has("mac")
  set guifont=DejaVu\ Sans\ Mono:h13
else
  set guifont=DejaVu\ Sans\ Mono\ 10,DejaVu\ Sans\ Mono:h10,Consolas:h11,Monospace:h10
end
" Mouse right-click does popup in GUIs
set mousemodel=popup_setpos
if has("unix")
  " Enable autoselect on platforms with two clipboards
  set guioptions+=a
end
" Initial window size
set columns=80
set lines=42
