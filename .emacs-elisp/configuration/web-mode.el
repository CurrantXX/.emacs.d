;;------------------- web mode ----------------------
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.jsp\\'" . web-mode)) 
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode)) 
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode)) 
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.php\\'" . web-mode))
;; (add-to-list 'auto-mode-alist '("\\.php\\'" . php-mode))
(add-to-list 'auto-mode-alist '("\\.blade\\.php\\'" . web-mode))
(set-face-attribute 'web-mode-html-tag-face nil :foreground "dodgerblue")
(set-face-attribute 'web-mode-html-tag-bracket-face nil :foreground "white")
(set-face-attribute 'web-mode-html-attr-name-face nil :foreground "#7070f0")
(set-face-attribute 'web-mode-doctype-face nil :foreground "#66d9ef")
(set-face-attribute 'web-mode-block-face nil :background "#1b1d1e")
(set-face-attribute 'web-mode-current-element-highlight-face nil :background "#465457")


(setq web-mode-engines-alist
      '(("php" . "\\.phtml\\'")
        ("blade" . "\\.blade\\."))
      )


;;Auto-pairing
(setq web-mode-disable-auto-pairing t)

;;CSS colorization
(setq web-mode-disable-css-colorization t)
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
  (setq web-mode-markup-indent-offset 2) )
(add-hook 'web-mode-hook 'web-mode-hook)
(setq web-mode-markup-indent-offset 4)
(setq web-mode-css-indent-offset 4)
(setq web-mode-code-indent-offset 4)
(setq web-mode-indent-style 4)
(setq web-mode-style-padding 2)
(setq web-mode-script-padding 2)
(setq web-mode-block-padding 0)
(define-key web-mode-map (kbd "C-.") 'web-mode-comment-or-uncomment)
