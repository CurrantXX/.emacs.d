;;---------------wcy-swbuffer--------------------
(require 'wcy-swbuff)
;;then you can use C-` and <C-S-kp-tab> to switch buffer.
(global-set-key (kbd "C-`") 'wcy-switch-buffer-forward)
(global-set-key (kbd "<C-S-kp-tab>") 'wcy-switch-buffer-backward)
(setq wcy-switch-buffer-active-buffer-face 'highlight)
(setq wcy-switch-buffer-inactive-buffer-face 'secondary-selection)
