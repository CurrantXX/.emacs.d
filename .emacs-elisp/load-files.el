;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   Filename:    load-files.el
;;   Version:     1.0
;;                
;;   Description: Load configuration files in the given directory or file
;;                
;;   Created at:  Mon Jun 23 22:26:24 2014
;;                
;;   Gallon Choi is a student majoring in Software Engineering,
;;   from the School of Computer, 
;;   Guangdong University of Technology, GZ 510006, P. R. China
;;                
;;   Status:      Experimental, do not distribute.
;;                
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun load-file-or-dir (file-dir)
  "load this file or files in the directory"
  (if (file-exists-p file-dir)
      (if (file-directory-p file-dir)
          (mapc 'load-file-or-dir
                (directory-files file-dir t "^[a-zA-z0-9].*"))
        (safe-load file-dir))))

(defun safe-load (file)
  "only load *.el file"
  (if (and (file-regular-p file)
           (file-readable-p file)
           (equal (file-name-extension file)
                  "el"))
      (load file)))

(defun load-files (file-list)
  "load all files or directories of file-list"
  (mapc 'load-file-or-dir file-list))

(defcustom my-auto-lisp nil
  "Auto load lisp files or directories list")

(load-files my-auto-lisp)
(provide 'load-files)
