;; Yasnippet
;;===============================================================
(require 'yasnippet) ;; not yasnippet-bundle
(yas-global-mode t)
;;===============================================================

;;Notice: Yasnippet should be loaded before auto complete so that they can work together

;; Auto Complete
;;===============================================================
(add-to-list 'load-path "~/.emacs-elisp/auto-complete/")
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs-elisp/auto-complete/ac-dict")
(ac-config-default)
;; (setq ac-sources
;;       '(ac-source-filename
;;         ac-source-functions
;;         ac-source-variables
;;         ac-source-symbols
;;         ac-source-features
;;         ac-source-abbrev
;;         ac-source-words-in-same-mode-buffers
;;         ac-source-dictionary
;;         ))
(ac-set-trigger-key "TAB")
(ac-set-trigger-key "<tab>")
(setq ac-use-quick-help t)
(setq ac-quick-help-delay 1.0)
(setq ac-fuzzy-enable t)
(put 'upcase-region 'disabled nil)
(setq ac-trigger-commands
      (cons 'backward-delete-char-untabify ac-trigger-commands))
;;web-mode auto complete
(add-to-list 'ac-modes 'web-mode)
;;lisp-mode auto complete
(add-to-list 'ac-modes 'lisp-mode)


;; Bug fixes
;; Issue: https://github.com/capitaomorte/yasnippet/issues/311
;; Solution:http://www.kurup.org/blog/2012/10/15/emacs-autocomplete-stumbles-on-yasnippet/

;; (defalias 'yas/get-snippet-tables 'yas--get-snippet-tables)
;; (defalias 'yas/table-hash 'yas--table-hash)
(delq 'ac-source-yasnippet ac-sources)
;;===============================================================
