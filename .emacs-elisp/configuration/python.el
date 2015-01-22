;;-------------------- Python --------------------
(setq py-install-directory "~/.emacs-elisp/python-mode")
(add-to-list 'load-path py-install-directory)
(require 'python-mode)
(require 'python-environment)
(require 'epc)
(setq jedi:setup-keys t)
(autoload 'jedi:setup "jedi" nil t)
(add-hook 'python-mode-hook 'jedi:setup)
(setq jedi:key-goto-definition (kbd "C-c C-.")) ;; change keybinds
(define-key python-mode-map (kbd "C-c C-a") 'py-pep8-run)

;;; (set-face-foreground 'py-variable-name-face "#74E32D")
;; (set-face-foreground 'py-variable-name-face "#FF7F50")
(set-face-foreground 'py-number-face "#AE81FF")
(set-face-foreground 'py-decorators-face "#FD971F")
(set-face-foreground 'py-pseudo-keyword-face "#FD971F")
(set-face-foreground 'font-lock-type-face "#C48DFF")
;; (when (load "flymake" t)
;;   (defun flymake-pylint-init ()
;;     (let* ((temp-file (flymake-init-create-temp-buffer-copy
;;                        'flymake-create-temp-inplace))
;;            (local-file (file-relative-name
;;                         temp-file
;;                         (file-name-directory buffer-file-name))))
;;       (list "epylint" (list local-file))))
;;   (setq flymake-number-of-errors-to-display nil)
;;   (add-to-list 'flymake-allowed-file-name-masks
;;                '("\\.py\\'" flymake-pylint-init)))

;; (add-hook 'python-mode-hook '(lambda ()
;;                                (flymake-mode t)))
