;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   Filename:    general.el
;;   Version:     1.0
;;
;;   Description: General Configuration for Emacs
;;
;;   Created at:  Mon Jun 23 21:53:01 2014
;;
;;   Gallon Choi is a student majoring in Software Engineering,
;;   from the School of Computer,
;;   Guangdong University of Technology, GZ 510006, P. R. China
;;
;;   Status:      Experimental, do not distribute.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq default-direct "~/Workspace/")
;;Line number
(global-linum-mode t)
;;speedbar
(global-set-key [f6] 'speedbar)
;;Disable TAB triggering indent
(setq-default indent-tabs-mode nil)
;;eshell
(global-set-key [(control =)] 'eshell)

(fset 'yes-or-no-p 'y-or-n-p)

;; Smex
;; (autoload 'smex "smex"
;; "Smex is a M-x enhancement for Emacs, it provides a convenient interface to
;; your recently and most frequently used commands.")
;; (global-set-key (kbd "M-x") 'smex)
;; Helm (Helm is better than smex)
(add-to-list 'load-path "~/.emacs-elisp/helm")
(require 'helm-config)
(global-set-key (kbd "M-x") 'helm-M-x)
(helm-mode 1)

;;ido-mode cooporate with smex
;; (ido-mode t)
;;Set Chinese punctuation
(setq sentence-end "\\([。！？]\\|……\\|[.?!][]\"')}]*\\($\\|[ \t]\\)\\)[ \t\n]*")
(setq sentence-end-double-space nil)

;;Disable scroll-bar
(customize-set-variable 'scroll-bar-mode nil)
;;Disable making temporary files
(setq-default make-backup-file nil)
;;Disable startup-message
(setq inhibit-startup-message t)
;;Bracket pair
(show-paren-mode t)
;;Tool and menu bar
(tool-bar-mode 0)
(menu-bar-mode 0)
;;Highlight
(global-font-lock-mode t)
;;Highlight the chosen charactor
(transient-mark-mode t)
;;Default Text Mode: Markdown
(setq default-major-mode 'markdown-mode)
;;Support copy and paste from outside
(setq x-select-enable-clipboard t)
;;C-k delete the whole line
(setq-default kill-whole-line t)
;;kill ring max: 200
(setq kill-ring-max 200)
;;Tab width
(setq default-tab-width 4)
;;Disable scroll bar
(set-scroll-bar-mode nil)
;;Prevent jumping while scrolling
(setq scroll-margin 5
      scroll-conservatively 10000)
;;Show image
(auto-image-file-mode)
;;Set title
(setq frame-title-format "%f@emacs")
;;Set mark
(global-unset-key (kbd "C-SPC"))
(global-set-key (kbd "M-SPC") 'set-mark-command)
;;Eval-region
(define-key emacs-lisp-mode-map (kbd "C-x C-r") 'eval-region)
(define-key lisp-interaction-mode-map (kbd "C-x C-r") 'eval-region)
;;Code check
(global-set-key (kbd "C-c u") 'flymake-mode)
;;Common display setting
;;=============================================================
;;time
(setq display-time-24hr-format t)
(setq display-time-format "%02H:%02M:%02S %Y-%02m-%02d %3a")
(setq display-time-interval 1);;时间更新频率
(display-time-mode 1)
;;column number
(column-number-mode t)
(size-indication-mode t)
;;calendar color
(setq calendar-load-hook
      '(lambda ()
         (set-face-foreground 'diary-face "skyblue")
         (set-face-background 'holiday-face "slate blue")
         (set-face-foreground 'holiday-face "white")))
;;=============================================================

;;Cursor
;;==============================================================
;;Avoiding automatically
(mouse-avoidance-mode 'animate)
;;Scroll line : 3
(defun up-slightly () (interactive) (scroll-up 3))
(defun down-slightly () (interactive) (scroll-down 3))
(global-set-key [mouse-4] 'down-slightly)
(global-set-key [mouse-5] 'up-slightly)
;;==============================================================

;;Find the next nearest charactor and jump to it
;;==============================================================
(defun my-go-to-char (n char)
  "Move forward to Nth occurence of CHAR.
Typing `my-go-to-char-key' again will move forwad to the next Nth
occurence of CHAR."
  (interactive "p\ncGo to char: ")
  (let ((case-fold-search nil))
    (if (eq n 1)
        (progn                            ; forward
          (search-forward (string char) nil nil n)
          (backward-char)
          (while (equal (read-key)
                        char)
            (forward-char)
            (search-forward (string char) nil nil n)
            (backward-char)))
      (progn                              ; backward
        (search-backward (string char) nil nil )
        (while (equal (read-key)
                      char)
          (search-backward (string char) nil nil )))))
  (setq unread-command-events (list last-input-event)))
(global-set-key (kbd "C-t") 'my-go-to-char)
;;==============================================================

;;Full screen
;;It seems not work well with Gnome or gtk?
;;============================================================================
(defun toggle-fullscreen (&optional f)
  (interactive)
  (let ((current-value (frame-parameter nil 'fullscreen)))
    (set-frame-parameter nil 'fullscreen
                         (if (equal 'fullboth current-value)
                             (if (boundp 'old-fullscreen) old-fullscreen nil)
                           (progn (setq old-fullscreen current-value)
                                  'fullboth)))))
(global-set-key [f11] 'toggle-fullscreen)
(add-hook 'emacs-startup-hook 'toggle-fullscreen)
;;============================================================================

;; Undo-Tree
;; Trigger-key: C-x u
(require 'undo-tree)
(global-undo-tree-mode t)

;;Window Configuration
;;===========================================================
;;next window
(global-set-key [(control \')] 'next-multiframe-window)
;;split and delete windows
(global-set-key (kbd "M-1") 'delete-other-windows)
(global-set-key (kbd "M-2") 'split-window-below)
(global-set-key (kbd "M-3") 'split-window-right)
(global-set-key (kbd "M-0") 'delete-window)
;;Swap windows
(defun transpose-buffers (arg)
  "Transpose the buffers shown in two windows."
  (interactive "p")
  (let ((selector (if (>= arg 0) 'next-window 'previous-window)))
    (while (/= arg 0)
      (let ((this-win (window-buffer))
            (next-win (window-buffer (funcall selector))))
        (set-window-buffer (selected-window) next-win)
        (set-window-buffer (funcall selector) this-win)
        (select-window (funcall selector)))
      (setq arg (if (plusp arg) (1- arg) (1+ arg))))))
(global-set-key (kbd "M-9") 'transpose-buffers)
;;==========================================================

;; ==================== 滚动缩放 ====================
;; http://zhuoqiang.me/torture-emacs.html
;; For Linux
(global-set-key (kbd "<C-mouse-4>") 'text-scale-increase)
(global-set-key (kbd "<C-mouse-5>") 'text-scale-decrease)

;;gdb按键设置
;;==========================================================
(global-set-key [(f8)] 'gud-step)
(global-set-key [(f7)] 'gud-next)
(global-set-key [(f4)] 'gud-until);;Recover kmacro-end-or-call-macro
(global-set-key [(f12)] 'gud-remove)
(global-set-key "\C-cf" 'gud-finish)
(global-set-key "\C-cs" 'gud-start)
(global-set-key "\C-cg" 'gud-go)
(global-set-key "\C-ct" 'gud-cont)
(global-set-key "\C-cw" 'gud-watch)
;;==========================================================
;; Indent region or buffer
(defun indent-buffer ()
  "Indent the currently visited buffer."
  (interactive)
  (indent-region (point-min) (point-max)))

(defun indent-region-or-buffer ()
  "Indent a region if selected, otherwise the whole buffer."
  (interactive)
  (save-excursion
    (if (region-active-p)
        (progn
          (indent-region (region-beginning) (region-end))
          (message "Indented selected region."))
      (progn
        (indent-buffer)
        (message "Indented buffer.")))
    (whitespace-cleanup)
    (untabify (point-min) (point-max))))
(global-set-key (kbd "C-c C-i") 'indent-region-or-buffer)

(global-set-key "\C-j" 'newline-and-indent)
(require 'rfringe)

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize)


;; expand-region
(require 'expand-region)
(global-set-key (kbd "C-c RET") 'er/expand-region)

;; restclient
(require 'restclient)
