;;-------------------- js2-mode -------------------
(add-to-list 'load-path "~/.emacs-elisp/js2-mode/")
(require 'js2-mode)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

;;------------------- jshint ----------------------
(require 'flymake-jshint)
(add-hook 'js2-mode-hook
          (lambda () (flymake-mode t)))
