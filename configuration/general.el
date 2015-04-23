;;Set title
(setq frame-title-format "%f@emacs")

;;
(global-linum-mode t)

;;
(fset 'yes-or-no-p 'y-or-n-p)

;; Helm
(require 'helm-config)
(helm-mode t)
(helm-autoresize-mode t)

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

;;Disable scroll bar
(set-scroll-bar-mode nil)

;;Highlight
(global-font-lock-mode t)

;;Highlight the chosen charactor
(transient-mark-mode t)

;;Default Mode
(setq default-major-mode 'text-mode)

;;Support copy and paste from outside
(setq x-select-enable-clipboard t)

;;C-k delete the whole line
(setq-default kill-whole-line t)

;;kill ring max: 200
(setq kill-ring-max 200)

;;Tab width
(setq default-tab-width 4)

;;Prevent jumping while scrolling
(setq redisplay-dont-pause t
	  scroll-step 1
	  scroll-margin 5
	  scroll-conservatively 10000
	  scroll-preserve-screen-position 1)

;;Show image
(auto-image-file-mode t)

(global-font-lock-mode 1)
;;; Also highlight parens
(setq show-paren-delay 0
	  show-paren-style 'parenthesis)
(show-paren-mode 1)

;;Cursor
;;==============================================================
;;Avoiding automatically
(mouse-avoidance-mode 'animate)
;;Scroll line : 3
(defun up-slightly () (interactive) (scroll-up 3))
(defun down-slightly () (interactive) (scroll-down 3))
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
;; (global-set-key (kbd "C-t") 'my-go-to-char)
;;==============================================================

;;Full screen
;;It seems not work well with Gnome or gtk?
;;==========================================================================
(defun toggle-fullscreen (&optional f)
  (interactive)
  (let ((current-value (frame-parameter nil 'fullscreen)))
	(set-frame-parameter nil 'fullscreen
						 (if (equal 'fullboth current-value)
							 (if (boundp 'old-fullscreen) old-fullscreen nil)
						   (progn (setq old-fullscreen current-value)
								  'fullboth)))))
(add-hook 'emacs-startup-hook 'toggle-fullscreen)
;;============================================================================

;; Undo-Tree
(require 'undo-tree)
(global-undo-tree-mode t)

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


;; package
(require 'package)
(add-to-list 'package-archives
			 '("melpa" . "http://melpa.org/packages/") t)
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize)


;; expand-region
(require 'expand-region)

;; restclient
(require 'restclient)

;;
(defadvice comment-or-uncomment-region (before slickcomment activate compile)
  "When called interactively with no active region, toggle comment on current line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
	 (list (line-beginning-position)
		   (line-beginning-position 2)))))

;;
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


;; Hungry-delete
(require 'hungry-delete)
(global-hungry-delete-mode)


;; ace-jump-mode
(autoload
  'ace-jump-mode
  "ace-jump-mode"
  "Emacs quick move minor mode"
  t)
;; you can select the key you prefer to
(autoload
  'ace-jump-mode-pop-mark
  "ace-jump-mode"
  "Ace jump back:-)"
  t)
(eval-after-load "ace-jump-mode"
  '(ace-jump-mode-enable-mark-sync))
