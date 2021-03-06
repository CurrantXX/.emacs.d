;;-------------------- 字体解码顺序 --------------------
;;     设置默认解码顺序
;;     from 王垠
;;----------------------------------------------------
(setq font-encoding-alist
      (append '(("MuleTibetan-0" (tibetan . 0))
                ("GB2312" (chinese-gb2312 . 0))
                ("BIG5" (big5 . 0))
                ("JISX0208" (japanese-jisx0208 . 0))
                ("JISX0212" (japanese-jisx0212 . 0))
                ("VISCII" (vietnamese-viscii-lower . 0))
                ("KSC5601" (korean-ksc5601 . 0))
                ("MuleArabic-0" (arabic-digit . 0))
                ("MuleArabic-1" (arabic-1-column . 0))
                ("MuleArabic-2" (arabic-2-column . 0))) font-encoding-alist))
;;写文件的编码方式
(set-buffer-file-coding-system 'utf-8)
;;新建文件的编码方式
(setq default-buffer-file-coding-system 'utf-8)
;;读取或写入文件名的编码方式
(setq file-name-coding-system 'utf-8)

(defun my-write-file-hook ()
  (whitespace-cleanup)
  (delete-blank-lines))

(add-hook 'write-file-hooks 'my-write-file-hook)
(add-hook 'before-save-hook
          (lambda ()
            (untabify (point-min) (point-max))))  ; untabify all buffer before save
