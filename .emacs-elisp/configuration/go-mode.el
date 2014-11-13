;; ----------------- go-mode ----------------------
;; Tutorial: http://yousefourabi.com/blog/2014/05/emacs-for-go/

(add-to-list 'load-path "~/.emacs-elisp/go-mode.el")
(require 'go-mode)

;; Keybindings
;; ------------------------------------------------
;; "C-c C-r": Remove all unused imports
;; "C-c C-g": Move the point to the imports block
;; "C-c C-f": Format the buffer without saving
;; "C-c C-k": Show the go documentation for a given package
;; ------------------------------------------------
(add-hook 'go-mode-hook '(lambda ()
                           (local-set-key (kbd "C-c C-r") 'go-remove-unused-imports)))
(add-hook 'go-mode-hook '(lambda ()
                           (local-set-key (kbd "C-c C-g" 'go-goto-imports))))
(add-hook 'go-mode-hook '(lambda ()
                           (local-set-key (kbd "C-c C-f" 'gofmt))))
(add-hook 'before-save-hook 'gofmt-before-save)
(add-hook 'go-mode-hook '(lambda ()
                           (local-set-key (kbd "C-c C-k") 'godoc)))

;; go-flymake
(add-to-list 'load-path "~/.emacs-elisp/goflymake")
(require 'go-flymake)
