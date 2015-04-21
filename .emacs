;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   Filename:    .emacs
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
(add-to-list 'load-path "~/.emacs-elisp/common/dash.el/")
(add-to-list 'load-path "~/.emacs-elisp/common/helm")
(add-to-list 'load-path "~/.emacs-elisp/common/undo-tree")
(add-to-list 'load-path "~/.emacs-elisp/common/hungry-delete")
;; before conf
(require 'dash)

;; configuration
(load "~/.emacs-elisp/configuration/AC-yas.el")
(load "~/.emacs-elisp/configuration/auto-header.el")
(load "~/.emacs-elisp/configuration/auto-pair.el")
(load "~/.emacs-elisp/configuration/cc-mode.el")
(load "~/.emacs-elisp/configuration/decode.el")
(load "~/.emacs-elisp/configuration/flymake.el")
(load "~/.emacs-elisp/configuration/general.el")
(load "~/.emacs-elisp/configuration/js2-mode.el")
(load "~/.emacs-elisp/configuration/org.el")
(load "~/.emacs-elisp/configuration/python.el")
(load "~/.emacs-elisp/configuration/scala.el")
(load "~/.emacs-elisp/configuration/web-mode.el")
(load "~/.emacs-elisp/configuration/yafolding.el")
(load "~/.emacs-elisp/configuration/theme.el")

;; key bingdings
;;===================================================
(global-set-key (kbd "M-x") 'helm-M-x)  ;; helm
(global-set-key (kbd "C-=") 'eshell)
(global-set-key [f6] 'speedbar)
;; (setq-default indent-tabs-mode nil) ;;Disable TAB triggering indent
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
