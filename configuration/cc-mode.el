;;-------------------- cc mode --------------------
;;     Setting up the CC mode                     .
;;                                                .
;;    :[Tab-Width]      : 4                       .
;;                                                .
;;    & compile         : F9                      .
;;    & gdb             : F5                      .
;;    & speedbar        : F6                      .
;;    & jump-to-definition     : M-.              .
;;-------------------------------------------------
(require 'cc-mode)
(require 'smart-compile+)
(require 'helm-gtags)  ;; jump to definition
(require 'sr-speedbar)
(require 'flycheck)

(setq smart-compile-alist
      '(("\\.c$"          . "clang -O2 %f -lm -o %n")
        ("\\.[Cc]+[Pp]*$" . "clang++ -std=c++11 -O2 %f -lm -o %n")
        ("\\.tex$"        . "latex %f")
        (emacs-lisp-mode  . (emacs-lisp-byte-compile))))

(setq c-basic-offset 4)
(c-set-offset 'inline-open 0)
(c-set-offset 'substatement-open 0)
(c-set-offset 'innamespace 0)
(c-set-offset 'topmost-intro-cont '+)
(defun my-cc-mode-common-hook()
  (setq tab-width 4 indent-tabs-mode nil)
  (c-toggle-auto-hungry-state 1)
  (setq gdb-many-windows t)
  (helm-gtags-mode t)
  (define-key c-mode-base-map [(return)] 'newline-and-indent)
  (define-key c-mode-base-map [(f5)] 'gdb)
  (define-key c-mode-base-map [(f6)] 'sr-speedbar-toggle)
  (setq sr-speedbar-right-side nil)
  (setq sr-speedbar-buffer-name "SpeedBar")
  (setq sr-speedbar-skip-other-window-p t)
  (define-key c-mode-base-map (kbd "M-.") 'helm-gtags-dwim)
  (define-key c-mode-base-map (kbd "M-s") 'helm-gtags-select)
  (define-key c-mode-base-map (kbd "C-c <") 'helm-gtags-previous-history)
  (define-key c-mode-base-map (kbd "C-c >") 'helm-gtags-next-history)
  (setq c-macro-shrink-window-flag t)
  (setq c-macro-preprocessor "cpp")
  (setq c-macro-cppflags " ")
  (setq c-macro-prompt-flag t)
  (setq abbrev-mode t)
  (global-flycheck-mode t)
  )
(add-hook 'c-mode-common-hook 'my-cc-mode-common-hook)

(add-hook 'c++-mode-hook
          (lambda ()
            (setq company-backends (delete 'company-semantic company-backends))
            (define-key c-mode-map  [(tab)] 'company-complete)
            (define-key c++-mode-map  [(tab)] 'company-complete)
            (setq company-clang-arguments '("-std=c++11"))
            (setq flycheck-clang-language-standard "c++11")))

;; highlight keyword
(font-lock-add-keywords 'c++-mode
                        '(("constexpr" . 'font-lock-keyword-face)
                          ("final" . 'font-lock-keyword-face)
                          ("override" . 'font-lock-keyword-face)
                          ("noexcept" . 'font-lock-keyword-face)
                          ("nullptr" . 'font-lock-keyword-face)
                          ("\\<[A-Z]+[A-Z0-9_]+\\>" . font-lock-constant-face)
                          ;; hexadecimal numbers
                          ("\\<0[xX][0-9A-Fa-f]+\\>" . font-lock-constant-face)
                          ("\\<[\\-+]*[0-9]*\\.?[0-9]+\\([ulUL]+\\|[eE][\\-+]?[0-9]+\\)?\\>" . font-lock-constant-face)))
