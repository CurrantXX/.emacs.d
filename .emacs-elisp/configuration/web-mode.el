;;------------------- web mode ----------------------
(require 'php-mode)
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.jsp\\'" . web-mode)) 
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode)) 
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode)) 
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.php\\'" . php-mode))
(add-to-list 'auto-mode-alist '("/\\(views\\|html\\|templates\\)/.*\\.php\\'" . web-mode))
(set-face-attribute 'web-mode-html-tag-face nil :foreground "dodgerblue")
(set-face-attribute 'web-mode-html-tag-bracket-face nil :foreground "white")
;; (set-face-attribute 'web-mode-html-attr-name-face nil :foreground "#7070f0")
(set-face-attribute 'web-mode-html-attr-name-face nil :foreground "#728a05")
(set-face-attribute 'web-mode-doctype-face nil :foreground "#66d9ef")
(set-face-attribute 'web-mode-block-face nil :background "#002b36")
(set-face-attribute 'web-mode-current-element-highlight-face nil :background "#465457")


(setq web-mode-engines-alist
      '(("php" . "\\.phtml\\'")
        ("blade" . "\\.blade\\."))
      )


;;Auto-pairing
(setq web-mode-enable-auto-pairing nil)
;;CSS colorization
(setq web-mode-enable-css-colorization t)
;;Block face: can be used to set blocks background(see web-mode-block-face)
(setq web-mode-enable-block-face t)
;;Part face: can be used to set parts background (see web-mode-part-face)
(setq web-mode-enable-part-face t)
;;Comment keywords (see web-mode-comment-keyword-face)
(setq web-mode-enable-comment-keywords t)
;;Highlight current HTML element (see web-mode-current-element-highlight-face)
(setq web-mode-enable-current-element-highlight t)
;;Heredoc (cf. PHP strings) fontification (when the identifier is <<<EOTHTML or <<<EOTJAVASCRIPT)
(setq web-mode-enable-heredoc-fontification t)

;; auto-pair
(setq web-mode-extra-auto-pairs
      '(("erb" . (("open" "close")))
        ("php" . (("open" "close")
                  ("open" "close")))
        ))

;;Snippet
(setq web-mode-extra-snippets
      '(("erb" . (("name" . ("beg" . "end"))))
        ("php" . (("name" . ("beg" . "end"))
                  ("name" . ("beg" . "end"))))
        ))
(defun web-mode-hook ()
  (setq web-mode-markup-indent-offset 2))
(add-hook 'web-mode-hook 'web-mode-hook)
(setq web-mode-markup-indent-offset 4)
(setq web-mode-css-indent-offset 4)
(setq web-mode-code-indent-offset 4)
(setq web-mode-indent-style 4)
(setq web-mode-style-padding 2)
(setq web-mode-script-padding 2)
(setq web-mode-block-padding 0)
(define-key web-mode-map (kbd "C-.") 'web-mode-comment-or-uncomment)
(define-key web-mode-map (kbd "C-c /") 'web-mode-element-close)
;; (define-key web-mode-map (kbd "C-c <") 'web-mode-element-beginning)

;;================== Rainbow-mode ====================
(require 'rainbow-mode)
(add-hook 'web-mode-hook 'rainbow-mode)

(require 'scss-mode)
(autoload 'scss-mode "scss-mode")
(add-to-list 'auto-mode-alist '("\\.scss\\'" . scss-mode))

(require 'emmet-mode)
(add-hook 'sgml-mode-hook 'emmet-mode) ;; Auto-start on any markup modes
(add-hook 'css-mode-hook  'emmet-mode) ;; enable Emmet's css abbreviation.
(add-hook 'scss-mode-hook 'emmet-mode)
(add-hook 'web-mode-hook 'emmet-mode)

;; Emmet-mode keyblinding
(define-key emmet-mode-keymap (kbd "C-c C-j") 'emmet-expand-line)
(define-key emmet-mode-keymap (kbd "C-j") 'newline-and-indent)
(define-key emmet-mode-keymap (kbd "C-c C-n") 'emmet-next-edit-point)
(define-key emmet-mode-keymap (kbd "C-c C-p") 'emmet-prev-edit-point)
(setq emmet-move-cursor-between-quotes t) ;; default nil
(require 'ac-emmet)

(defun css-syntax-color-hex ()
  "Syntax color hex color spec such as '#ff1100' or '#fff' or 'rgb(1,1,1)' in current buffer."
  (interactive)
  (font-lock-add-keywords
   nil
   '(("#[0-9a-fA-F]\\{6\\}\\|#[0-9a-fA-F]\\{3\\}\\|rgb([ ]*\\([[:digit:]]\\{1,3\\}\\)[ ]*,[ ]*\\([[:digit:]]\\{1,3\\}\\)[ ]*,[ ]*\\([[:digit:]]\\{1,3\\}\\)\\(.*?\\))"
      (0 (css-colorize
          (match-beginning 0)
          (match-end 0)
          )))))
  (font-lock-fontify-buffer)
  )
(defun css-colorize-foreground (color)
  "Colorize foreground based on background luminance."
  (let* ((values (x-color-values color))
	 (r (car values))
	 (g (cadr values))
	 (b (car (cdr (cdr values)))))
    (if (> 128.0 (floor (+ (* .3 r) (* .59 g) (* .11 b)) 256))
	"white" "black")))
(defun css-colorize (beg end)
  (let (str plist len)
    (setq str (buffer-substring-no-properties beg end))
    (setq len (length str))
    (cond
     ((string= (substring str 0 1) "#")
      (setq plist (list :background str
                        :foreground (css-colorize-foreground str)))
      (put-text-property beg end 'face plist))
     ((string= (substring str 0 4) "rgb(")
      (setq str (format "#%02X%02X%02X"
                        (string-to-number (match-string-no-properties 1))
                        (string-to-number (match-string-no-properties 2))
                        (string-to-number (match-string-no-properties 3))))
      (setq plist (list :background str
                        :foreground (css-colorize-foreground str)))
      (put-text-property beg end 'face plist))
     ) ;cond
    ))

(add-hook 'scss-mode-hook 'css-syntax-color-hex)
(add-hook 'css-mode-hook 'css-syntax-color-hex)
