;; ----------------- go-mode ----------------------
;; Tutorial: http://yousefourabi.com/blog/2014/05/emacs-for-go/

(add-to-list 'load-path "~/.emacs-elisp")
(require 'go-mode)

;; Keybindings
;; ------------------------------------------------
;; "C-c C-r": Remove all unused imports
;; "C-c C-g": Move the point to the imports block
;; "C-c C-f": Format the buffer without saving
;; "C-c C-k": Show the go documentation for a given package
;; ------------------------------------------------

(add-hook 'go-mode-hook '(lambda ()
                           (local-set-key (kbd "C-c C-r") 'go-remove-unused-imports)
                           (local-set-key (kbd "C-c C-g" 'go-goto-imports))
                           (local-set-key (kbd "C-c C-f" 'gofmt))
                           (local-set-key (kbd "C-c C-k") 'godoc)))

(add-hook 'before-save-hook 'gofmt-before-save)
;; go-flymake
(add-to-list 'load-path "~/.emacs-elisp/goflymake")
(require 'go-flymake)
;; FIXME: go-mode with autopair
(add-hook 'go-mode-hook '(lambda ()
                           (local-set-key (kbd "C-c C-e") 'flymake-display-err-menu-for-current-line)
                           (cc-common-mode-auto-pair)))
(require 'go-autocomplete)
(require 'auto-complete-config)
