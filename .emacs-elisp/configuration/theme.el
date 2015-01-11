;;-------------------- Color theme --------------------
;;     配色管理。
;;-----------------------------------------------------
(add-to-list 'custom-theme-load-path "~/.emacs-elisp/themes/")
(set-frame-parameter nil 'background-mode 'dark)
(load-theme 'solarized t)
;; (load-theme 'molokai t)
;; background alpha
;;Fonts
(defun frame-setting ()
  (set-default-font "文泉驿等宽正黑-12")
  (set-frame-font "Monaco-12")
  (set-fontset-font "fontset-default" 'han "文泉驿等宽正黑-12")
  ;; (set-frame-parameter (selected-frame) 'alpha '(85 50))
  )
 
(if (and (fboundp 'daemonp) (daemonp))
    (add-hook 'after-make-frame-functions
	      (lambda (frame)
		(with-selected-frame frame
		  (frame-setting))))
  (frame-setting))
