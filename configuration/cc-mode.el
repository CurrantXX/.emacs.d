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
(require 'auto-complete-clang-async)


(setq smart-compile-alist
      '(("\\.c$"          . "clang -O2 %f -lm -o %n")
        ("\\.[Cc]+[Pp]*$" . "clang++ -std=c++11 -O2 %f -lm -o %n")
        ("\\.tex$"        . "latex %f")
        (emacs-lisp-mode  . (emacs-lisp-byte-compile))))

(setq c-basic-offset 4)
(c-set-offset 'inline-open 0)
(c-set-offset 'substatement-open 0)
(c-set-offset 'innamespace 0)
(defun my-cc-mode-common-hook()
  (setq tab-width 4 indent-tabs-mode nil)
  (c-toggle-auto-hungry-state 1)
  (setq gdb-many-windows t)
  (helm-gtags-mode t)
  (define-key c-mode-base-map [(return)] 'newline-and-indent)
  (define-key c-mode-base-map [(f5)] 'gdb)
  (define-key c-mode-base-map [(f6)] 'speedbar)
  (define-key c-mode-base-map (kbd "M-.") 'helm-gtags-dwim)
  (setq c-macro-shrink-window-flag t)
  (setq c-macro-preprocessor "cpp")
  (setq c-macro-cppflags " ")
  (setq c-macro-prompt-flag t)
  (setq abbrev-mode t)
  )
(add-hook 'c-mode-common-hook 'my-cc-mode-common-hook)


(defun ac-cc-mode-setup ()
  (setq ac-clang-cflags (list "-std=c++11"))
  (setq ac-clang-complete-executable "~/.emacs.d/lang/c/emacs-clang-complete-async/clang-complete")
  (setq ac-sources '(ac-source-clang-async))
  (ac-clang-launch-completion-process))

(defun my-ac-config ()
  (add-hook 'c-mode-common-hook 'ac-cc-mode-setup)
  (add-hook 'auto-complete-mode-hook 'ac-common-setup)
  (global-auto-complete-mode t))

(my-ac-config)

(require 'flycheck)
(add-hook 'c-mode-common-hook 'global-flycheck-mode)
(add-hook 'c++-mode-hook
          (lambda ()
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
