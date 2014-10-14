;;------------------------- Org-mode -------------------------
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
