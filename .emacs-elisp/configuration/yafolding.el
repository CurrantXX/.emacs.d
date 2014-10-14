;;---------------yafolding-----------------
(require 'yafolding)
(define-key global-map (kbd "C-;") 'yafolding)
;;(define-key global-map (kbd "C-c C-f") 'yafolding-toggle-all)
(define-key global-map (kbd "C-c C-f") 'yafolding-toggle-all-by-current-level)
;;(add-hook 'indent-buffer-before-hook
;;    (lambda ()
;;      (yafolding-temp-toggle nil)))
;;(add-hook 'indent-buffer-after-hook
;;    (lambda ()
;;      (yafolding-temp-toggle t)))
