;;-------------------- Python --------------------
(require 'python-mode)
(require 'python-environment)
(require 'epc)
(require 'jedi)
(setq jedi:setup-keys t)
(autoload 'jedi:setup "jedi" nil t)
(add-hook 'python-mode-hook 'jedi:setup)

(set-face-foreground 'py-number-face "#AE81FF")
(set-face-foreground 'py-decorators-face "#FD971F")
(set-face-foreground 'py-pseudo-keyword-face "#FD971F")
(set-face-foreground 'font-lock-type-face "#C48DFF")

(when (load "flymake" t)
  (defun flymake-pyflakes-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
               'flymake-create-temp-inplace))
       (local-file (file-relative-name
            temp-file
            (file-name-directory buffer-file-name))))
      (list "pyflakes"  (list local-file))))
   (add-to-list 'flymake-allowed-file-name-masks
                '("\\.py\\'" flymake-pyflakes-init)))

(add-hook 'python-mode-hook
          (lambda () (flymake-mode t)))
