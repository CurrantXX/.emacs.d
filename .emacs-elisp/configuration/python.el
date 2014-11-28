;;-------------------- Python --------------------
(setq py-install-directory "~/.emacs-elisp/")
(add-to-list 'load-path py-install-directory)
(require 'python-mode)

;; (set-face-foreground 'py-variable-name-face "#74E32D")
;; (set-face-foreground 'py-variable-name-face "#fd971f")
;; (set-face-foreground 'py-number-face "#74E32D")
(set-face-foreground 'py-pseudo-keyword-face "#fd971f")
(set-face-foreground 'font-lock-type-face "#C48DFF")
(when (load "flymake" t)
  (defun flymake-pylint-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (list "epylint" (list local-file))))
  (setq flymake-number-of-errors-to-display nil)
  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.py\\'" flymake-pylint-init)))

(add-hook 'python-mode-hook '(lambda ()
                               (flymake-mode t)))
