(add-to-list 'load-path "~/.emacs-elisp/s.el/")
(require 's)
(add-to-list 'load-path "~/.emacs-elisp/scala-mode/scala-mode2/")
(require 'scala-mode2)
(add-to-list 'load-path "~/.emacs-elisp/scala-mode/sbt-mode/")
(require 'sbt-mode)
(add-to-list 'load-path "~/.emacs-elisp/scala-mode/ensime-emacs/")
(require 'ensime)
(defun my-scala-hook ()
  (ensime-scala-mode-hook)
  (local-set-key (kbd "TAB") 'ac-complete-ensime-completions))
;; (add-hook 'scala-mode-hook 'my-scala-hook)
(add-hook 'scala-mode-hook 'ensime-scala-mode-hook)
