;;------------------------- Org-mode -------------------------
(add-to-list 'load-path "~/.emacs-elisp/org-bullets")
(require 'org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
(setq org-hide-leading-stars t)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done 'time)

(defun insert-loli ()
  "Insert the latest loli into current buffer."
  (interactive)
  (newline)
  (let ((filename (shell-command-to-string
                   "readlink -n ~/loliday/latest")))
    (message filename)
    (insert-image (create-image filename)))
  (start-process "loli-process" "*Messages*"  "~/loliday/loli.sh")
  (newline)
  (newline))
(global-set-key (kbd "C-h 0") `insert-loli)

(add-hook 'eshell-proc-load-hook
          '(lambda nil
             (insert-loli)
             (eshell-send-input "*eshell*")
             ))

(load "auctex.el" nil t t)
(load "preview-latex.el" nil t t)

;; Programming language highlight when exporting pdf format
;; Include the latex-exporter
(require 'ox-latex)
;; Add minted to the defaults packages to include when exporting.
(add-to-list 'org-latex-packages-alist '("" "minted"))
;; Tell the latex export to use the minted package for source
;; code coloration.
(setq org-latex-listings 'minted)
;; Let the exporter use the -shell-escape option to let latex
;; execute external programs.
;; This obviously and can be dangerous to activate!
(setq org-latex-pdf-process
      '("xelatex -shell-escape -interaction nonstopmode -output-directory %o %f"))

(require 'magic-latex-buffer)
(add-hook 'latex-mode-hook 'magic-latex-buffer)
