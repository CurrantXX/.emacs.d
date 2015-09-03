(require 'rust-mode)
(autoload 'rust-mode "rust-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))

(setq racer-cmd "/home/gallon/.emacs.d/lang/rust/racer/target/release/racer")
(setq racer-rust-src-path "/home/gallon/rustc/src")


;; Reduce the time after which the company auto completion popup opens
(setq company-idle-delay 0.2)

;; Reduce the number of characters before company kicks in
(setq company-minimum-prefix-length 1)             ;; Enable racer

(require 'flycheck-rust)
(require 'racer)
(require 'company-racer)
(add-hook 'rust-mode-hook
          '(lambda ()
             (unless (getenv "RUST_SRC_PATH")
               (setenv "RUST_SRC_PATH" (expand-file-name "/home/gallon/rustc/src")))
             (add-hook 'flycheck-mode-hook #'flycheck-rust-setup)
             (flycheck-mode)
             (company-mode)
             (racer-activate)
             ;; Hook in racer with eldoc to provide documentation
             (racer-turn-on-eldoc)
             ;; Use flycheck-rust in rust-mode
             ;; (add-hook 'flycheck-mode-hook #'flycheck-rust-setup)
             ;; Use company-racer in rust mode
             (set (make-local-variable 'company-backends) '(company-racer))
             ;; Key binding to jump to method definition
             (local-set-key (kbd "M-.") #'racer-find-definition)
             ;; Key binding to auto complete and indent
             ;; (local-set-key (kbd "TAB") #'racer-complete-or-indent)
             ))


;; (add-hook 'rust-mode-hook #'racer-mode)
;; (add-hook 'racer-mode-hook #'eldoc-mode)
;; (add-hook 'racer-mode-hook #'company-mode)

;; (global-set-key (kbd "TAB") #'company-indent-or-complete-common) ;
;; (setq company-tooltip-align-annotations t)
