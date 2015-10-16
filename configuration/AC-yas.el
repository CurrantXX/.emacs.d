;; Yasnippet
;;===============================================================
(require 'yasnippet) ;; not yasnippet-bundle
(yas-global-mode t)
;;===============================================================

(require 'company)
(add-hook 'after-init-hook 'global-company-mode)
