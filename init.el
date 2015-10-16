;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   Filename:    init.el
;;   Version:     1.9
;;
;;   Description: Configuration file of Emacs
;;
;;   Created at:  Tue Apr 21 22:41:38 2015
;;
;;   Gallon Choi is a student majoring in Software Engineering,
;;   from the School of Computer,
;;   Guangdong University of Technology, GZ 510006, P. R. China
;;
;;   Status:      Experimental, do not distribute.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;Personal message
(setq user-full-name "Gallon Choi")
(setq user-mail-address "gallonq@gmail.com")
(setq default-direct "~/Workspace/")

;; load-path
; common
(add-to-list 'load-path "~/.emacs.d/common/dash.el/")
(add-to-list 'load-path "~/.emacs.d/common/helm/")
(add-to-list 'load-path "~/.emacs.d/common/undo-tree")
(add-to-list 'load-path "~/.emacs.d/common/hungry-delete")
(add-to-list `load-path "~/.emacs.d/common/yasnippet/")
(add-to-list 'load-path "~/.emacs.d/common/company-mode/")
(add-to-list 'load-path "~/.emacs.d/common/")
(add-to-list 'load-path "~/.emacs.d/common/smartparens/")
(add-to-list 'load-path "~/.emacs.d/common/expand-region.el/")
(add-to-list 'load-path "~/.emacs.d/common/restclient.el/")
(add-to-list 'load-path "~/.emacs.d/common/rainbow-mode")
(add-to-list 'load-path "~/.emacs.d/common/window-numbering.el")
(add-to-list 'load-path "~/.emacs.d/common/wcy-swbuff/")
(add-to-list 'load-path "~/.emacs.d/common/minimap")
(add-to-list 'load-path "~/.emacs.d/common/yafolding.el")
(add-to-list 'load-path "~/.emacs.d/common/ace-jump-mode")
(add-to-list 'load-path "~/.emacs.d/common/fold-this.el/")
(add-to-list 'load-path "~/.emacs.d/common/flycheck/")

; language
(add-to-list 'load-path "~/.emacs.d/lang/c/")
(add-to-list 'load-path "~/.emacs.d/lang/c/smart-compile-plus/")
(add-to-list 'load-path "~/.emacs.d/lang/c/emacs-helm-gtags/")
;; (add-to-list 'load-path "~/.emacs.d/lang/js/js2-mode/")
;; (add-to-list 'load-path "~/.emacs.d/lang/js/")
;; (add-to-list 'load-path "~/.emacs.d/lang/org/org-bullets")
;; (add-to-list 'load-path "~/.emacs.d/lang/latex/magic-latex-buffer")
;; (add-to-list 'load-path "~/.emacs.d/lang/python")
;; (add-to-list 'load-path "~/.emacs.d/lang/python/emacs-deferred")
;; (add-to-list 'load-path "~/.emacs.d/lang/python/emacs-ctable")
;; (add-to-list 'load-path "~/.emacs.d/lang/python/emacs-epc")
;; (add-to-list 'load-path "~/.emacs.d/lang/python/emacs-python-environment")
;; (add-to-list 'load-path "~/.emacs.d/lang/python/emacs-jedi")
;; (add-to-list 'load-path "~/.emacs.d/lang/php/php-mode")
;; (add-to-list 'load-path "~/.emacs.d/lang/web/web-mode")
;; (add-to-list 'load-path "~/.emacs.d/lang/web/emmet-mode")
;; (add-to-list 'load-path "~/.emacs.d/lang/web/ac-emmet")
;; (add-to-list 'load-path "~/.emacs.d/lang/rust/rust-mode")
;; (add-to-list 'load-path "~/.emacs.d/lang/rust/emacs-racer")
;; (add-to-list 'load-path "~/.emacs.d/lang/rust/company-racer")
;; (add-to-list 'load-path "~/.emacs.d/lang/rust/flycheck-rust")

; theme
(add-to-list 'load-path "~/.emacs.d/themes/hl-line-plus")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/emacs-color-theme-solarized")

;; before conf
(require 'dash)

;; configuration
(load "~/.emacs.d/configuration/AC-yas.el")
(load "~/.emacs.d/configuration/auto-header.el")
(load "~/.emacs.d/configuration/auto-pair.el")
(load "~/.emacs.d/configuration/cc-mode.el")
(load "~/.emacs.d/configuration/decode.el")
(load "~/.emacs.d/configuration/flymake.el")
(load "~/.emacs.d/configuration/general.el")
;; (load "~/.emacs.d/configuration/js2-mode.el")
;; (load "~/.emacs.d/configuration/org.el")
;; (load "~/.emacs.d/configuration/python.el")
;; (load "~/.emacs.d/configuration/web-mode.el")
(load "~/.emacs.d/configuration/yafolding.el")
(load "~/.emacs.d/configuration/theme.el")
;; (load "~/.emacs.d/configuration/rust-mode.el")

;; key bingdings
;;===================================================
(global-set-key (kbd "M-x") 'helm-M-x)  ;; helm
(global-set-key (kbd "C-=") 'eshell)
(global-set-key [f6] 'speedbar)
(setq-default indent-tabs-mode nil) ;;Disable TAB triggering indent
;;Set mark
(global-unset-key (kbd "C-SPC"))
(global-set-key (kbd "M-SPC") 'set-mark-command)
;;Eval-region
(define-key emacs-lisp-mode-map (kbd "C-x C-r") 'eval-region)
(define-key lisp-interaction-mode-map (kbd "C-x C-r") 'eval-region)
;;Code check(flymake)
(global-set-key (kbd "C-c u") 'flymake-mode)

(global-set-key [mouse-4] 'down-slightly)
(global-set-key [mouse-5] 'up-slightly)
(global-set-key (kbd "<C-mouse-4>") 'text-scale-increase)
(global-set-key (kbd "<C-mouse-5>") 'text-scale-decrease)

(global-set-key [f11] 'toggle-fullscreen)

;;gdb
(global-set-key [(f9)] 'smart-compile)
(global-set-key [(f8)] 'gud-step)
(global-set-key [(f7)] 'gud-next)
(global-set-key [(f4)] 'gud-until);;Recover kmacro-end-or-call-macro
(global-set-key [(f12)] 'gud-remove)
(global-set-key (kbd "C-c f") 'gud-finish)
(global-set-key (kbd "C-c s")'gud-start)
(global-set-key (kbd "C-c g")'gud-go)
(global-set-key (kbd "C-c t")'gud-cont)
(global-set-key (kbd "C-c w")'gud-watch)

;; indent
(global-set-key (kbd "C-c C-i") 'indent-region-or-buffer)
(global-set-key (kbd "C-j")'newline-and-indent)

;; expand region
(global-set-key (kbd "C-c RET") 'er/expand-region)

;; comment or uncomment
(global-set-key (kbd "C-.") 'comment-or-uncomment-region)

;; hungry delete
(global-set-key (kbd "C-M-y") 'query-replace-regexp)
(global-set-key (kbd "M-.") 'delete-horizontal-space)
(global-set-key (kbd "C-c C-d") 'hungry-delete-forward)
(global-set-key (kbd "C-c DEL") 'hungry-delete-backward)

;; insert date time
(global-set-key (kbd "C-c C-t") 'insert-current-date-time)

;; autopair
(global-set-key (kbd "M-k") 'sp-kill-sexp)
(global-set-key (kbd "M-S-<left>") 'sp-add-to-next-sexp)
(global-set-key (kbd "M-S-<right>") 'sp-add-to-previous-sexp)

;; python
;; (setq jedi:goto-definition (kbd "C-c C-.")) ;; change keybinds
;; (define-key python-mode-map (kbd "C-c C-a") 'py-pep8-run)


;; window-numbering
(define-key window-numbering-keymap (kbd "C-0") 'select-window-0)
(define-key window-numbering-keymap (kbd "C-1") 'select-window-1)
(define-key window-numbering-keymap (kbd "C-2") 'select-window-2)
(define-key window-numbering-keymap (kbd "C-3") 'select-window-3)
(define-key window-numbering-keymap (kbd "C-4") 'select-window-4)
(define-key window-numbering-keymap (kbd "C-5") 'select-window-5)
(define-key window-numbering-keymap (kbd "C-6") 'select-window-6)
(define-key window-numbering-keymap (kbd "C-7") 'select-window-7)
(define-key window-numbering-keymap (kbd "C-8") 'select-window-8)
(define-key window-numbering-keymap (kbd "C-9") 'select-window-9)
(define-key window-numbering-keymap (kbd "M-1") 'delete-other-windows)
(define-key window-numbering-keymap (kbd "M-2") 'split-window-below)
(define-key window-numbering-keymap (kbd "M-3") 'split-window-right)
(define-key window-numbering-keymap (kbd "M-0") 'delete-window)
(global-set-key (kbd "C-`") 'wcy-switch-buffer-forward)
(global-set-key (kbd "<C-S-kp-tab>") 'wcy-switch-buffer-backward)
;;next window
(global-set-key [(control \')] 'next-multiframe-window)
;;split and delete windows
(global-set-key (kbd "M-1") 'delete-other-windows)
(global-set-key (kbd "M-2") 'split-window-below)
(global-set-key (kbd "M-3") 'split-window-right)
(global-set-key (kbd "M-0") 'delete-window)
(global-set-key (kbd "M-9") 'transpose-buffers)


;; web-mode
;; (define-key web-mode-map (kbd "C-.") 'web-mode-comment-or-uncomment)
;; (define-key web-mode-map (kbd "C-c /") 'web-mode-element-close)
;; (define-key web-mode-map (kbd "C-c C-d") 'hungry-delete-forward)
;; (define-key web-mode-map (kbd "C-c DEL") 'hungry-delete-backward)


;; emmet-mode
;; (define-key emmet-mode-keymap (kbd "C-c C-j") 'emmet-expand-line)
;; (define-key emmet-mode-keymap (kbd "C-j") 'newline-and-indent)
;; (define-key emmet-mode-keymap (kbd "C-c C-n") 'emmet-next-edit-point)
;; (define-key emmet-mode-keymap (kbd "C-c C-p") 'emmet-prev-edit-point)

;; yafolding
(define-key global-map (kbd "C-'") 'yafolding-toggle-element)
(define-key global-map (kbd "C-c C-f") 'yafolding-toggle-all)

;; ace-jump-mode
(define-key global-map (kbd "C-t") 'ace-jump-mode)
