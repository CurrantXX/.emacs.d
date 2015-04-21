;;-------------------- js2-mode -------------------
(add-to-list 'load-path "~/.emacs-elisp/lang/js/js2-mode/")
(require 'js2-mode)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

;;------------------- jshint ----------------------
(add-to-list 'load-path "~/.emacs-elisp/lang/js/")
(require 'flymake-jshint)
(add-hook 'js2-mode-hook
          (lambda () (flymake-mode t)))
