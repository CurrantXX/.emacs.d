;;-------------------- Auto Header --------------------
;;     自动添加文件头
;;     Auto-header defines the following global keys:
;;         C-x C-h m    -- Create header.
;;         C-x C-h c    -- Increase the update counter.
;;         C-x C-h i    -- Insert header field (prompted for in minibuffer).
;;         C-x C-h r    -- Make revision entry.  Turns on auto-fill.
;;         C-x C-h g    -- Goto field within header.  Turns on auto-fill.
;;         C-x C-h f    -- Insert function header.
;;         C-x C-h a    -- Toggle auto-fill-mode for headers.
;;-----------------------------------------------------
(add-to-list 'load-path "~/.emacs-elisp/common/")
(require 'auto-header)
(setq header-gdut-name "Gallon")
(setq header-gdut-sno "3113006352" )
(setq header-email-address "GallonQ@gmail.com")
;; 设置每次保存时要更新的项目
(setq header-update-on-save '(filename
                              modified
                              counter
                              copyright
                              ))
;; 设置文件头的显示格式
(setq header-field-list '(
                          filename  ;;文件名
                          version
                          blank     ;空行，下同
                          description   ;描述
                          blank
                          ;; text-2 ;作者+SNO
                          created   ;创建时间
                          blank
                          text-1
                          ;;modified_by ;更改者
                          blank
                          status    ;状态，是否发布
                          ;;update  ;更新
                          blank
                          ))
;;setq header-copyright-notic
;;setq header-function-hdrstyle
