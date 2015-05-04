;;-------------------- cc mode --------------------
;     Setting up the CC mode .                    .
;                                                 .
;     :[Tab-Width]      : 4                       .
;                                                 .
;     & compile         : F9                      .
;     & gdb             : F5                      .
;     & speedbar        : F6                      .
;     & c-indent        : M-`                     .
;                                                 .
;     based on lertsau                            .
;;-------------------------------------------------
(require 'cc-mode)
(require 'smart-compile+)
;;space setting
(setq c-basic-offset 4)
(c-set-offset 'inline-open 0)
(c-set-offset 'friend '-)
(c-set-offset 'substatement-open 0)
(defun my-c-mode-common-hook()
  (setq tab-width 4 indent-tabs-mode nil)
  ;;; hungry-delete and auto-newline
  ;; (c-set-style "gnu")
  (c-toggle-auto-hungry-state 1)
  (define-key c-mode-base-map [(return)] 'newline-and-indent)
  (define-key c-mode-base-map [(f5)] 'gdb)
  (define-key c-mode-base-map [(f6)] 'speedbar)
  (setq c-macro-shrink-window-flag t)
  (setq c-macro-preprocessor "cpp")
  (setq c-macro-cppflags " ")
  (setq c-macro-prompt-flag t)
  (setq abbrev-mode t)
  (delq 'ac-source-yasnippet ac-sources)
  (delq 'ac-source-words-in-same-mode-buffers ac-sources)
  )
(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

(defun my-c++-mode-hook()
  (setq tab-width 4 indent-tabs-mode nil)
  (c-set-style "stroustrup"))

(custom-set-variables
 '(c-offsets-alist (quote ((inline-open . 0) (substatement-open . 0) (cpp-macro . 0) (friend . -))))
 '(scroll-bar-mode nil))
(custom-set-faces
 )
