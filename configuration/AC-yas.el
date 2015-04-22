;; Yasnippet
;;===============================================================
(require 'yasnippet) ;; not yasnippet-bundle
(yas-global-mode t)
;;===============================================================

;;Notice: Yasnippet should be loaded before auto complete so that they can work together

;; Auto Complete
;;===============================================================
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs-elisp/auto-complete/dict")
(ac-config-default)
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
;;===============================================================
;; (set-face-background 'popup-face "#1c1c1c")
;; (set-face-foreground 'popup-face "#0087ff")
