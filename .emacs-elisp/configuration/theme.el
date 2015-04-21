;;-------------------- Color theme --------------------
(require 'hl-line+)
(global-hl-line-mode t)
;; (require 'col-highlight)
;; (column-highlight-mode 1)
(set-frame-parameter nil 'background-mode 'dark)
(load-theme 'solarized t)
;; (load-theme 'molokai t)
;; background alpha
;;Fonts
(defun frame-setting ()
  (set-default-font "文泉驿等宽正黑-12")
  (set-frame-font "Monaco-12")
  (set-fontset-font "fontset-default" 'han "文泉驿等宽正黑-12")
  ;; (set-frame-parameter (selected-frame) 'alpha '(85 50))
  )

(if (and (fboundp 'daemonp) (daemonp))
    (add-hook 'after-make-frame-functions
              (lambda (frame)
                (with-selected-frame frame
                  (frame-setting))))
  (frame-setting))

;; mode-line

(set-face-attribute
 'mode-line nil
 :inverse-video nil)
;; (set-face)
(set-face-attribute
 'mode-line-inactive nil
 :foreground "#dc322f"
 :inverse-video nil)

(defun my-mode-line ()
  (setq-default mode-line-format
                (list
                 ;; the buffer name; the file name as a tool tip
                 (propertize "[" 'face 'font-lock-comment-face)
                 (propertize "] " 'face 'font-lock-comment-face)

                 (propertize "[" 'face 'font-lock-comment-face)
                 '(:eval (propertize "%b" 'face 'font-lock-keyword-face
                                     'help-echo (format "%s" (buffer-file-name))
                                     ))
                 (propertize "] " 'face 'font-lock-comment-face)

                 (propertize "[" 'face 'font-lock-comment-face)
                 '(:eval (propertize (if overwrite-mode "Ovrewrite" "Insert")
                                     'face 'font-lock-preprocessor-face
                                     'help-echo (concat "Buffer is in "
                                                        (if overwrite-mode "overwrite" "insert") " mode")))

                 ;; was this buffer modified since the last save?
                 '(:eval (when (buffer-modified-p)
                           (concat (propertize "," 'face 'font-lock-comment-face)
                                   (propertize "Modidfied"
                                               'face 'font-lock-warning-face
                                               'help-echo "Buffer has been modified"))))

                 ;; is this buffer read-only?
                 '(:eval (when buffer-read-only
                           (concat (propertize "," 'face 'font-lock-comment-face)
                                   (propertize "Read-only"
                                               'face 'font-lock-type-face
                                               'help-echo "Buffer is read-only"))))

                 (propertize "] " 'face 'font-lock-comment-face)


                 ;; (propertize "%I" 'face 'font-lock-constant-face) ;; size
                 '(:eval (when (and (not (buffer-modified-p)) my-mode-line-buffer-line-count)
                           (propertize (concat "/" my-mode-line-buffer-line-count "L")
                                       'face 'font-lock-type-face
                                       )))


                 ;; the current major mode for the buffer.
                 ;; mode-line-modes ;; too much infomation
                 (propertize "[" 'face 'font-lock-comment-face)
                 '(:eval (propertize "%m" 'face 'font-lock-string-face
                                     'help-echo buffer-file-coding-system))
                 (propertize "] " 'face 'font-lock-comment-face)

                 ;; vc-mode
                 (propertize "[" 'face 'font-lock-comment-face)
                 '(:eval (when vc-mode
                           (concat
                            (propertize (string-strip (format "%s" vc-mode)) 'face 'font-lock-variable-name-face))))

                 (propertize "] " 'face 'font-lock-comment-face)

                 (propertize "[" 'face 'font-lock-comment-face)
                 ;; relative position, size of file
                 (propertize "%p/%I" 'face 'font-lock-type-face) ;; % above top
                 (propertize "(" 'face 'font-lock-comment-face)
                 (propertize "%l,%c" 'face 'font-lock-negation-char-face) ;; % above top
                 (propertize ")" 'face 'font-lock-comment-face)
                 (propertize "] " 'face 'font-lock-comment-face)


                 (propertize "[" 'face 'font-lock-comment-face)
                 ;; add the time, with the date and the emacs uptime in the tooltip
                 '(:eval (propertize (format-time-string "%H:%M:%S")
                                     'face 'font-lock-comment-face
                                     'help-echo
                                     (concat (format-time-string "%Y-%02m-%02d %02H:%02M:%02S %Y-%02m-%02d %3a; ")
                                             (emacs-uptime "Uptime:%hh"))))

                 ;; show buffer file name
                 '(:eval (when show-buffer-file-name
                           (format " [%s]" (buffer-file-name))))


                 (propertize "] " 'face 'font-lock-comment-face)
                 (propertize "%-" 'face 'font-lock-comment-face)
                 ;; fill with '-'
                 ))
  )
(my-mode-line)

;;-----------------window-numbering--------------------
(require 'window-numbering)
(window-numbering-mode 1)
;;---------------wcy-swbuffer--------------------
(require 'wcy-swbuff)
;;then you can use C-` and <C-S-kp-tab> to switch buffer.
(setq wcy-switch-buffer-active-buffer-face 'highlight)
(setq wcy-switch-buffer-inactive-buffer-face 'secondary-selection)



;;Window Configuration
;;===========================================================
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


(require 'minimap)
(setq minimap-window-location 'right)
(minimap-mode t)
