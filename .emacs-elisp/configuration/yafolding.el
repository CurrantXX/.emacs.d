;;---------------yafolding-----------------
(add-to-list 'load-path "~/.emacs-elisp/yafolding.el")
(require 'yafolding)
(define-key global-map (kbd "C-'") 'yafolding-toggle-element)
(define-key global-map (kbd "C-c C-f") 'yafolding-toggle-all)
