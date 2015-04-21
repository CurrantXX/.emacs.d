;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   Filename:    .emacs
;;
;;   Description: Configuration file of Emacs
;;
;;   Created at:  Tue Feb 03 13:26:20 UTC 2015
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

(add-to-list 'load-path "~/.emacs-elisp/dash.el/")
(require 'dash)
(add-to-list 'load-path (expand-file-name "~/.emacs-elisp"))
(setq my-auto-lisp (list "~/.emacs-elisp/configuration"))
(require 'load-files)

;;-------------------- Smart Compile --------------------
;;    Load the smart-compile+ .                         .
;;-------------------------------------------------------
(require 'smart-compile+)
(global-set-key [(f9)] 'smart-compile)

;;-------------------- gdb设置 --------------------
;;     多窗口gdb
;; ------------------------------------------------
(setq gdb-many-windows t)
(setq gdb-use-separate-io-buffer t)

;;-------------------- clang-completion-mode --------------------
(load-library "clang-completion-mode")

;;-------------------- 重定义注释方法 --------------------
;; 没有任中任何区域时，注释、反注释作用于当前行，否则作用于
;; 选中区域
;;-----------------------------------------------------
(defadvice comment-or-uncomment-region (before slickcomment activate compile)
  "When called interactively with no active region, toggle comment on current line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))
(global-set-key (kbd "C-.") 'comment-or-uncomment-region)

;;-------------------- 重定义删除行 --------------------
;;     T_T目前不知道作用
;;     When called interactively with no active
;;     region, copy a single line instead.When
;;     called interactively with no active region,
;;     kill a single line instead.”
;;----------------------------------------------------
(defadvice kill-ring-save (before slickcopy activate compile)
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))
(defadvice kill-region (before slickcut activate compile)
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))


;;-------------------- html-helper-mode --------------------
;;    Set up the html-helper-mode.                          .
;;-----------------------------------------------------------
(setq html-helper-build-new-buffer nil)
(setq html-helper-address-string "<a href= \"http://gallon.cc\">G_allon<\\a>")

(global-font-lock-mode 1)
;;; Also highlight parens
(setq show-paren-delay 0
      show-paren-style 'parenthesis)
(show-paren-mode 1)
;;; This is the binary name of my scheme implementation
(setq scheme-program-name "mit-scheme")

(global-set-key (kbd "C-M-y") 'query-replace-regexp)
(global-set-key (kbd "M-.") 'delete-horizontal-space)
;; Hungry-delete
(require 'hungry-delete)
(global-hungry-delete-mode)
(global-set-key (kbd "C-c C-d") 'hungry-delete-forward)
(global-set-key (kbd "C-c DEL") 'hungry-delete-backward)

;; ====================
;; insert date and time

(defvar current-date-time-format "%a %b %d %H:%M:%S %Z %Y"
  "Format of date to insert with `insert-current-date-time' func
See help of `format-time-string' for possible replacements")

(defvar current-time-format "%a %H:%M:%S"
  "Format of date to insert with `insert-current-time' func.
Note the weekly scope of the command's precision.")

(defun insert-current-date-time ()
  "insert the current date and time into current buffer.
Uses `current-date-time-format' for the formatting the date/time."
       (interactive)
;       (insert (let () (comment-start)))
       (insert (format-time-string current-date-time-format (current-time)))
       )

(defun insert-current-time ()
  "insert the current time (1-week scope) into the current buffer."
       (interactive)
       (insert (format-time-string current-time-format (current-time)))
       )

(global-set-key "\C-c\C-t" 'insert-current-date-time)
;; (global-set-key "\C-c\C-t" 'insert-current-time)
