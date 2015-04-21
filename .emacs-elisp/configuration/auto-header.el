;;-------------------- Auto Header --------------------
;;     Auto-header defines the following global keys:
;;         C-x C-h m    -- Create header.
;;         C-x C-h c    -- Increase the update counter.
;;         C-x C-h i    -- Insert header field (prompted for in minibuffer).
;;         C-x C-h r    -- Make revision entry.  Turns on auto-fill.
;;         C-x C-h g    -- Goto field within header.  Turns on auto-fill.
;;         C-x C-h f    -- Insert function header.
;;         C-x C-h a    -- Toggle auto-fill-mode for headers.
;;-----------------------------------------------------
(require 'auto-header)
(setq header-gdut-name "Gallon")
(setq header-gdut-sno "3113006352" )
(setq header-email-address "GallonQ@gmail.com")
(setq header-update-on-save '(filename
                              modified
                              counter
                              copyright
                              ))
;; format
(setq header-field-list '(
                          filename
                          version
                          blank     ;blank line
                          description
                          blank
                          ;; text-2 ;author
                          created
                          blank
                          text-1
                          ;;modified_by ;
                          blank
                          status
                          ;;update
                          blank
                          ))
;;setq header-copyright-notic
;;setq header-function-hdrstyle
