;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   Filename:    .emacs
;;                
;;   Description: Configuration file of Emacs
;;                
;;   Created at:  Tue Jun 24 02:44:56 2014
;;                
;;   Gallon Choi is a student majoring in Software Engineering,
;;   from the School of Computer, 
;;   Guangdong University of Technology, GZ 510006, P. R. China
;;                
;;   Status:      Experimental, do not distribute.
;;                
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;Personal message
(setq user-full-name "Gallon Choi")
(setq user-mail-address "gallonq@gmail.com")

(add-to-list 'load-path (expand-file-name "~/.emacs-elisp"))
(setq my-auto-lisp (list "~/.emacs-elisp/configuration"))
(require 'load-files)

;;-------------------- Smart Compile --------------------
;;    Load the smart-compile+ .                         .
;;-------------------------------------------------------
(require 'smart-compile+)
(global-set-key [(f9)] 'smart-compile)

;;-------------------- gdb设置 --------------------
;;     多窗口gdb
;; ------------------------------------------------
(setq gdb-many-windows t)
(setq gdb-use-separate-io-buffer t)

;;-------------------- clang-completion-mode --------------------
(load-library "clang-completion-mode")

;;-------------------- 重定义注释方法 --------------------
;; 没有任中任何区域时，注释、反注释作用于当前行，否则作用于
;; 选中区域
;;-----------------------------------------------------
(defadvice comment-or-uncomment-region (before slickcomment activate compile)
  "When called interactively with no active region, toggle comment on current line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))
(global-set-key (kbd "C-.") 'comment-or-uncomment-region)

;;-------------------- 重定义删除行 --------------------
;;     T_T目前不知道作用
;;     When called interactively with no active
;;     region, copy a single line instead.When
;;     called interactively with no active region,
;;     kill a single line instead.”
;;----------------------------------------------------
(defadvice kill-ring-save (before slickcopy activate compile)
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))
(defadvice kill-region (before slickcut activate compile)
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))


;;-------------------- html-helper-mode --------------------
;;    Set up the html-helper-mode.                          .
;;-----------------------------------------------------------
(setq html-helper-build-new-buffer nil)
(setq html-helper-address-string "<a href= \"http://gallon.cc\">G_allon<\\a>")

(global-font-lock-mode 1)  
;;; Also highlight parens  
(setq show-paren-delay 0  
      show-paren-style 'parenthesis)  
(show-paren-mode 1)  
;;; This is the binary name of my scheme implementation  
(setq scheme-program-name "mit-scheme")  

(load "auctex.el" nil t t)
(load "preview-latex.el" nil t t)

;; Include the latex-exporter
(require 'ox-latex)
;; Add minted to the defaults packages to include when exporting.
(add-to-list 'org-latex-packages-alist '("" "minted"))
;; Tell the latex export to use the minted package for source
;; code coloration.
(setq org-latex-listings 'minted)
;; Let the exporter use the -shell-escape option to let latex
;; execute external programs.
;; This obviously and can be dangerous to activate!
(setq org-latex-pdf-process
      '("xelatex -shell-escape -interaction nonstopmode -output-directory %o %f"))

