;;-------------------- cc mode --------------------
;;     Setting up the CC mode                     .
;;                                                .
;;    :[Tab-Width]      : 4                       .
;;                                                .
;;    & compile         : F9                      .
;;    & gdb             : F5                      .
;;    & speedbar        : F6                      .
;;    & c-indent        : M-`                     .
;;                                                .
;;    based on lertsau                            .
;;-------------------------------------------------
(require 'cc-mode)
(require 'smart-compile+)
(require 'auto-complete-clang)
(setq ac-clang-flags
      (mapcar (lambda (item)(concat "-I" item))
              (split-string
               "
/usr/include/c++/5.2.0
/usr/include/c++/5.2.0/x86_64-unknown-linux-gnu
/usr/include/c++/5.2.0/backward
/usr/lib/gcc/x86_64-unknown-linux-gnu/5.2.0/include
/usr/local/include
/usr/lib/gcc/x86_64-unknown-linux-gnu/5.2.0/include-fixed
/usr/include
"
               )))
(setq smart-compile-alist
      '(("\\.c$"          . "clang -O2 %f -lm -o %n")
        ("\\.[Cc]+[Pp]*$" . "clang++ -std=c++11 -O2 %f -lm -o %n")
        ("\\.tex$"        . "latex %f")
        (emacs-lisp-mode  . (emacs-lisp-byte-compile))))
;;space setting
(setq c-basic-offset 4)
(c-set-offset 'inline-open 0)
;;(c-set-offset 'friend '-)
(c-set-offset 'substatement-open 0)
(defun my-cc-mode-common-hook()
  (setq tab-width 4 indent-tabs-mode nil)
  ;;; hungry-delete and auto-newline
  ;; (c-set-style "gnu")
  (c-toggle-auto-hungry-state 1)
  (setq gdb-many-windows t)
  (define-key c-mode-base-map [(return)] 'newline-and-indent)
  (define-key c-mode-base-map [(f5)] 'gdb)
  (define-key c-mode-base-map [(f6)] 'speedbar)
  (setq c-macro-shrink-window-flag t)
  (setq c-macro-preprocessor "cpp")
  (setq c-macro-cppflags " ")
  (setq c-macro-prompt-flag t)
  (setq abbrev-mode t)
  (delq 'ac-source-dictionary ac-sources)
  (delq 'ac-source-words-in-same-mode-buffers ac-sources)
  (setq ac-sources (append '(ac-source-clang) ac-sources))
  )
(add-hook 'c-mode-common-hook 'my-cc-mode-common-hook)


(require 'auto-complete-clang-async)

(defun ac-cc-mode-setup ()
  (setq ac-clang-cflags '("-std=c++11"))
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
                          ("nullptr" . 'font-lock-keyword-face)
                          ("\\<[A-Z]+[A-Z0-9_]+\\>" . font-lock-constant-face)
                          ;; hexadecimal numbers
                          ("\\<0[xX][0-9A-Fa-f]+\\>" . font-lock-constant-face)
                          ("\\<[\\-+]*[0-9]*\\.?[0-9]+\\([ulUL]+\\|[eE][\\-+]?[0-9]+\\)?\\>" . font-lock-constant-face)))
