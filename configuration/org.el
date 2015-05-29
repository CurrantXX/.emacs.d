;;------------------------- Org-mode -------------------------
(require 'org-bullets)
(defun insert-loli ()
  "Insert the latest loli into current buffer."
  (interactive)
  (newline)
  (let ((filename (shell-command-to-string
                   "readlink -n ~/loliday/latest")))
    (message filename)
    (insert-image (create-image filename)))
  (start-process "loli-process" "*Messages*"  "~/loliday/loli.sh")
  (newline)
  (newline))
(add-hook 'org-mode-hook
          (lambda ()
            (org-bullets-mode 1)
            (define-key org-mode-map (kbd "C-c a") 'org-agenda)
            (define-key org-mode-map (kbd "C-h 0") `insert-loli)))
(setq org-hide-leading-stars t)
(setq org-log-done 'time)


(add-hook 'eshell-proc-load-hook
          '(lambda nil
             (insert-loli)
             (eshell-send-input "*eshell*")
             ))
(require 'ox-latex)

(defun org-html-src-block (src-block contents info)
  "Transcode a SRC-BLOCK element from Org to HTML.
CONTENTS holds the contents of the item.  INFO is a plist holding
contextual information."
  (if (org-export-read-attribute :attr_html src-block :textarea)
      (org-html--textarea-block src-block)
    (let ((lang (org-element-property :language src-block))
      (caption (org-export-get-caption src-block))
      (code (org-html-format-code src-block info))
      (label (let ((lbl (and (org-element-property :name src-block)
                 (org-export-get-reference src-block info))))
           (if lbl (format " id=\"%s\"" lbl) ""))))
      (if (not lang) (format "<pre class=\"example\"%s>\n%s</pre>" label code)
    (format "<div class=\"org-src-container\">\n%s%s\n</div>"
     (if (not caption) ""
       (format "<label class=\"org-src-name\">%s</label>"
           (org-export-data caption info)))
     (format "\n<pre class=\"src src-%s line-numbers\" data-language=\"%s\" %s><code class=\"language-%s\">%s</code></pre>" lang lang label lang code))))))


(setq org-html-doctype "html5")
(setq org-html-head-include-default-style nil)
(setq org-html-validation-link nil)
(setq org-html-preamble t)
(setq org-html-preamble-format '(("en" "<a class=\"preamble\" href=\"/\">Home</a> | <a class=\"preamble\" href=\"http://override.rocks\">Blog</a> | <a class=\"preamble\" href=\"https://github.com/gallonchoi\">GitHub</a>")))
(setq org-export-with-email t)
(setq org-export-with-section-numbers nil)

(require 'magic-latex-buffer)
(add-hook 'latex-mode-hook 'magic-latex-buffer)

;; ---- xelatex generate pdf -----------------
(add-hook 'org-mode-hook
          (lambda () (setq truncate-lines nil)))

;; 使用xelatex一步生成PDF(必须运行两次该命令用于生成TOC)
(setq org-latex-pdf-process
      '("xelatex -interaction nonstopmode %f"
        "xelatex -interaction nonstopmode %f"))
;; code执行免应答（Eval code without confirm）
(setq org-confirm-babel-evaluate nil)
;; Auctex
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)
(defun org-mode-article-modes ()
  (reftex-mode t)
  (and (buffer-file-name)
       (file-exists-p (buffer-file-name))
       (reftex-parse-all)))
(add-hook 'org-mode-hook
          (lambda ()
            (if (member "REFTEX" org-todo-keywords-1)
                (org-mode-article-modes))))
(unless (boundp 'org-latex-classes)
  (setq org-latex-classes nil))

(add-to-list 'org-latex-classes
             '("cn-article"
               "\\documentclass[10pt,a4paper]{article}
\\usepackage{graphicx}
\\usepackage{xcolor}
\\usepackage[slantfont, boldfont]{xeCJK}
\\usepackage{lmodern}
\\usepackage{verbatim}
\\usepackage{fixltx2e}
\\usepackage{longtable}
\\usepackage{float}
\\usepackage{tikz}
\\usepackage{wrapfig}
\\usepackage{soul}
\\usepackage{textcomp}
\\usepackage{listings}
\\usepackage{geometry}
\\usepackage{algorithm}
\\usepackage{algorithmic}
\\usepackage{marvosym}
\\usepackage{wasysym}
\\usepackage{latexsym}
\\usepackage{natbib}
\\usepackage{fancyhdr}
\\usepackage{titling}
\\usepackage[xetex, colorlinks=true, CJKbookmarks=true, linkcolor=black, urlcolor=blue, menucolor=blue]{hyperref}
\\usepackage{fontspec, xunicode, xltxtra}
\\usepackage{indentfirst}
\\setlength{\\parindent}{2em}
\\setmainfont{Times New Roman}
\\setsansfont{Times New Roman}
\\setmonofont{WenQuanYi Micro Hei Mono}
\\newcommand\\fontnamemono{WenQuanYi Micro Hei Mono}%等宽字体
\\newfontinstance\\MONO{\\fontnamemono}
\\newcommand{\\mono}[1]{{\\MONO #1}}
\\setCJKmainfont[Scale=0.9]{WenQuanYi Zen Hei}%中文字体
\\setCJKmonofont[Scale=0.9]{WenQuanYi Micro Hei Mono}
\\hypersetup{unicode=true}
\\geometry{a4paper, textwidth=6.5in, textheight=10in, marginparsep=7pt, marginparwidth=.6in}
\\definecolor{foreground}{RGB}{220,220,204}%浅灰
\\definecolor{background}{RGB}{62,62,62}%浅黑
\\definecolor{preprocess}{RGB}{250,187,249}%浅紫
\\definecolor{var}{RGB}{239,224,174}%浅肉色
\\definecolor{string}{RGB}{154,150,230}%浅紫色
\\definecolor{type}{RGB}{225,225,116}%浅黄
\\definecolor{function}{RGB}{140,206,211}%浅天蓝
\\definecolor{keyword}{RGB}{239,224,174}%浅肉色
\\definecolor{comment}{RGB}{180,98,4}%深褐色
\\definecolor{doc}{RGB}{175,215,175}%浅铅绿
\\definecolor{comdil}{RGB}{111,128,111}%深灰
\\definecolor{constant}{RGB}{220,162,170}%粉红
\\definecolor{buildin}{RGB}{127,159,127}%深铅绿
\\punctstyle{kaiming}
\\title{}
\\pagestyle{fancy}
\\fancyhf{}
\\fancyfoot[C]{\\bfseries\\thepage}
\\fancyhead[LO]{\\leftmark}
\\fancyhead[RO]{\\thetitle}
\\tolerance=1000
\\setcounter{tocdepth}{2}
\\setcounter{secnumdepth}{0}
[NO-DEFAULT-PACKAGES]
[NO-PACKAGES]"

;; 自动添加结点到TOC
("\\section{%s}" . "\\section{%s}")
("\\subsection{%s}" . "\\subsection{%s}")
("\\subsubsection{%s}" . "\\subsubsection{%s}")
("\\paragraph{%s}" . "\\paragraph{%s}")
("\\subparagraph{%s}" . "\\subparagraph{%s}")
))

(setq org-latex-toc-command "\\tableofcontents\n\\pagebreak\n")

;; 使用Listings宏包格式化源代码(只是把代码框用listing环境框起来，还需要额外的设置)
(setq org-export-latex-listings t)
;; Options for \lset command（reference to listing Manual)
(setq org-export-latex-listings-options
      '(
        ("basicstyle" "\\color{foreground}\\small\\mono")           ; 源代码字体样式
        ("keywordstyle" "\\color{function}\\bfseries\\small\\mono") ; 关键词字体样式
        ("identifierstyle" "\\color{doc}\\small\\mono")
        ("commentstyle" "\\color{comment}\\small\\itshape")         ; 批注样式
        ("stringstyle" "\\color{string}\\small")                    ; 字符串样式
        ("showstringspaces" "false")                                ; 字符串空格显示
        ("numbers" "left")                                          ; 行号显示
        ("numberstyle" "\\color{preprocess}")                       ; 行号样式
        ("stepnumber" "1")                                          ; 行号递增
        ("backgroundcolor" "\\color{background}")                   ; 代码框背景色
        ("tabsize" "4")                                             ; TAB等效空格数
        ("captionpos" "t")                                          ; 标题位置 top or buttom(t|b)
        ("breaklines" "true")                                       ; 自动断行
        ("breakatwhitespace" "true")                                ; 只在空格分行
        ("showspaces" "false")                                      ; 显示空格
        ("columns" "flexible")                                      ; 列样式
        ("frame" "single")                                          ; 代码框：阴影盒
        ("frameround" "tttt")                                       ; 代码框： 圆角
        ("framesep" "0pt")
        ("framerule" "8pt")
        ("rulecolor" "\\color{background}")
        ("fillcolor" "\\color{white}")
        ("rulesepcolor" "\\color{comdil}")
        ("framexleftmargin" "10mm")
        ))
;; Make Org use ido-completing-read for most of its completing prompts.
(setq org-completion-use-ido t)
;; 各种Babel语言支持
(org-babel-do-load-languages
 'org-babel-load-languages
 '((R . t)
   (emacs-lisp . t)
   (matlab . t)
   (C . t)
   (perl . t)
   (sh . t)
   (ditaa . t)
   (python . t)
   (haskell . t)
   (dot . t)
   (latex . t)
   (js . t)
   ))

;; 导出Beamer的设置
;; allow for export=>beamer by placing #+LaTeX_CLASS: beamer in org files
;;-----------------------------------------------------------------------------
(add-to-list 'org-latex-classes
             ;; beamer class, for presentations
             '("beamer"
               "\\documentclass[11pt,professionalfonts]{beamer}
\\mode
\\usetheme{{{{Warsaw}}}}
%\\usecolortheme{{{{beamercolortheme}}}}

\\beamertemplateballitem
\\setbeameroption{show notes}
\\usepackage{graphicx}
\\usepackage{tikz}
\\usepackage{xcolor}
\\usepackage{xeCJK}
\\usepackage{amsmath}
\\usepackage{lmodern}
\\usepackage{fontspec,xunicode,xltxtra}
\\usepackage{polyglossia}
\\setmainfont{Times New Roman}
\\setCJKmainfont{WenQuanYi Micro Hei}
\\setCJKmonofont{WenQuanYi Micro Hei Mono}
\\usepackage{verbatim}
\\usepackage{listings}
\\institute{{{{beamerinstitute}}}}
\\subject{{{{beamersubject}}}}"
               ("\\section{%s}" . "\\section*{%s}")
               ("\\begin{frame}[fragile]\\frametitle{%s}"
                "\\end{frame}"
                "\\begin{frame}[fragile]\\frametitle{%s}"
                "\\end{frame}")))

(setq ps-paper-type 'a4
      ps-font-size 16.0
      ps-print-header nil
      ps-landscape-mode nil)
