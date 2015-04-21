;;------------------- smartparens-mode ------------------
(add-to-list 'load-path "~/.emacs-elisp/smartparens/")
(require 'smartparens-config)
(smartparens-global-mode)
(show-smartparens-global-mode 0)
(show-smartparens-mode 0)
(global-set-key (kbd "M-k") 'sp-kill-sexp)
(global-set-key (kbd "M-S-<left>") 'sp-add-to-next-sexp)
(global-set-key (kbd "M-S-<right>") 'sp-add-to-previous-sexp)
