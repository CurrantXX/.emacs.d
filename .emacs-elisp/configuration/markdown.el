;;------------------------- Markdown-mode -------------------------
;; Markdown Mode
;; This version 2 released on March 24, 2013 by JBlevins.
;; I cloned his git repository in my ~/.emacs.d directory.

(add-to-list 'load-path "~/.emacs-lisp")
(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.txt\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("README\\.md\\'" . gfm-mode))

;; Note: the markdown-command points to multimarkdown and was set with 
;; "C-h v markdown-command" after loading a markdown file. There are other 
;; ways to set this variable that involve a "hook" variable that is run 
;; after the mode is loaded.  Initially this was set to "markdown".
;; markdown-open-command is set to ~/bin/mark which in turn is linked to
;; mark -> /Applications/Marked.app/Contents/Resources/mark
