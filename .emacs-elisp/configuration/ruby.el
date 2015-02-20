(add-to-list 'load-path "~/.emacs-elisp/ruby-mode/")
(require 'robe)
(require 'inf-ruby)
(autoload 'enh-ruby-mode "enh-ruby-mode" "Major mode for ruby files" t)
(require 'enh-ruby-mode)
(add-hook 'ruby-mode-hook 'robe)
(add-hook 'ruby-mode-hook 'enh-ruby-mode)
;; (add-hook 'enh-ruby-mode-hook 'robe)
;; (add-hook 'robe-mode-hook 'ac-robe-setup)
(remove-hook 'enh-ruby-mode-hook 'erm-define-faces)
(defun my-ruby-faces ()
   (defface erm-syn-errline
   '((t (:box (:line-width 1 :color "red"))))
   "Face used for marking error lines."
   :group 'enh-ruby)

 (defface erm-syn-warnline
   '((t (:box (:line-width 1 :color "orange"))))
   "Face used for marking warning lines."
   :group 'enh-ruby))
(add-hook 'enh-ruby-mode-hook 'my-ruby-faces)
(add-hook 'enh-ruby-mode-hook 'auto-complete-mode)
