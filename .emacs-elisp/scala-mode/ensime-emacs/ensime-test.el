;;; ensime-test.el --- Regression tests for ENSIME
;;
;;;; License
;;
;;     Copyright (C) 2010 Aemon Cannon
;;
;;     This program is free software; you can redistribute it and/or
;;     modify it under the terms of the GNU General Public License as
;;     published by the Free Software Foundation; either version 2 of
;;     the License, or (at your option) any later version.
;;
;;     This program is distributed in the hope that it will be useful,
;;     but WITHOUT ANY WARRANTY; without even the implied warranty of
;;     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;;     GNU General Public License for more details.
;;
;;     You should have received a copy of the GNU General Public
;;     License along with this program; if not, write to the Free
;;     Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
;;     MA 02111-1307, USA.


(eval-and-compile (require 'ensime))

(defvar ensime-testing-buffer "*ensime-tests*"
  "Contains the output of all the tests. Also tracks all the testing-specific
   buffer-local variables.")

(defvar ensime-test-queue '()
  "The queue of tests yet to be run.")
(make-variable-buffer-local 'ensime-test-queue)

(defvar ensime-async-handler-stack '()
  "Asynchronous event handlers waiting for signals. See 'ensime-test-sig'.")
(make-variable-buffer-local 'ensime-async-handler-stack)

(defvar ensime-shared-test-state '()
  "A state dump for anyone who wants to use it. Useful for async tests.")
(make-variable-buffer-local 'ensime-shared-test-state)

(defvar ensime-test-dev-home
  (expand-file-name "~/features")
  "The local development root. This")

(defvar ensime-test-env-classpath '()
  "Extra jars to include on testing classpath")

(defvar ensime-ecukes-callbacks '()
  "Asynchronous callback function indicating end of suite.")
(make-variable-buffer-local 'ensime-ecukes-callbacks)

(defvar ensime--test-had-failures nil)

(defvar ensime--test-exit-on-finish (string= "t" (getenv "ENSIME_RUN_AND_EXIT")))

(put 'ensime-test-assert-failed
     'error-conditions '(error ensime-test-assert-failed))
(put 'ensime-test-assert-failed 'error-message "Assertion Failed")

(put 'ensime-test-interrupted
     'error-conditions '(error ensime-test-interrupted))
(put 'ensime-test-interrupted 'error-message "Test Interrupted")


(defun ensime--extract-scala-library-jar ()
  (with-temp-buffer
    (insert-file-contents
     (ensime--classpath-file ensime--test-scala-version))
    (--first
     (string-match (concat "/scala-library.*\.jar") it )
     (split-string (buffer-string) ensime--classpath-separator 'omit-nulls))))



(defun ensime-test-concat-lines (&rest lines)
  (mapconcat #'identity lines "\n"))


(defun ensime-create-file (file-name contents)
  "Create file named file-name. Write contents to the file. Return file's name."
  (make-directory (file-name-directory file-name) t)
  (with-temp-file file-name
    (insert contents))
  file-name)


(defmacro* ensime-with-tmp-file ((name prefix contents) &rest body)
  "Create temporary file with given prefix. Bind the file to
   name and evaluate body."
  `(let ((,name (make-temp-file ,prefix)))
     (with-temp-file ,name
       (insert ,contents))
     (unwind-protect
         (progn ,@body)
       (delete-file ,name))))

(defvar ensime--test-scala-version
  (getenv "SCALA_VERSION"))

(defun ensime--test-scala-major-version ()
  (mapconcat 'int-to-string
	     (-take 2 (version-to-list ensime--test-scala-version))
	     "."))

(defun ensime-create-tmp-project (src-files &optional extra-config)
  "Create a temporary project directory. Populate with config, source files.
 Return a plist describing the project. Note: Delete such projects with
 ensime-cleanup-tmp-project."
  (let* ((root-dir (file-name-as-directory
                    (make-temp-file "ensime_test_proj_" t)))
         (cache-dir (file-name-as-directory (concat root-dir "cache")))
         (src-dir (file-name-as-directory (concat root-dir "src/main/scala")))
         (target-dir (file-name-as-directory
		      (concat root-dir "target/scala-"
			      (ensime--test-scala-major-version) "/classes" )))
         (test-target-dir (file-name-as-directory (concat root-dir "test-target")))
         (scala-jar (ensime--extract-scala-library-jar))
         (config (append
                  extra-config
                  `(:root-dir ,root-dir
                    :cache-dir ,cache-dir
                    :name "test"
                    :scala-version ,ensime--test-scala-version
                    :java-home ,(getenv "JDK_HOME")
                    :subprojects
                      ((:name "test"
                        :module-name "test"
                        :source-roots (,src-dir)
                        :depends-on-modules nil
                        :compile-deps (,scala-jar)
                        :target ,target-dir
                        :test-target ,test-target-dir)))))
         (conf-file (ensime-create-file
                     (concat root-dir ".ensime")
                     (format "%S" config))))

    (mkdir src-dir t)
    (mkdir cache-dir t)
    (mkdir target-dir t)
    (mkdir test-target-dir t)
    (let* ((src-file-names
            (mapcar
             (lambda (f) (ensime-create-file
                          (concat src-dir (plist-get f :name))
                          (plist-get f :contents)))
             src-files)))
      (list
       :src-files src-file-names
       :root-dir root-dir
       :conf-file conf-file
       :src-dir src-dir
       :target target-dir))))

(defvar ensime-tmp-project-hello-world
  `((:name
     "hello_world.scala"
     :contents ,(ensime-test-concat-lines
                 "package com.helloworld"
                 "class HelloWorld{"
                 "}"
                 "object HelloWorld {"
                 "def main(args: Array[String]) = {"
                 "Console.println(\"Hello, world!\")"
                 "}"
                 "def foo(a:Int, b:Int):Int = {"
                 "a + b"
                 "}"
                 "}"))))

(defun ensime-test-compile-java-proj (proj arguments)
  "Compile java sources of given temporary test project."
  (let* ((root (plist-get proj :root-dir))
         (src-files (plist-get proj :src-files))
         (target (plist-get proj :target))
         (args (append
                arguments
                (list "-d" target)
                src-files)))
    (assert (executable-find "javac"))
    (assert (= 0 (apply 'call-process "javac" nil "*javac*" nil args)))))

(defun ensime-cleanup-tmp-project (proj &optional no-del)
  "Destroy a temporary project directory, kill all buffers visiting
   source files in the project."
  ;; TODO Should delete all buffers that weren't there at the test start
  (let ((src-files (plist-get proj :src-files))
        (root-dir (plist-get proj :root-dir)))
    (dolist (f src-files)
      (cond ((file-exists-p f)
             (let ((buf (find-buffer-visiting f)))
               (when buf
                 (switch-to-buffer buf)
                 (set-buffer-modified-p nil)
                 (kill-buffer nil))))
            ((get-buffer f)
             (progn
               (switch-to-buffer (get-buffer f))
               (kill-buffer nil)))
            (t)))

    (when (not no-del)
      ;; a bit of paranoia..
      (if (and root-dir (integerp (string-match "^/tmp/" root-dir)))
          ;; ..before we wipe away the project dir
          (with-current-buffer ensime-testing-buffer
            (shell-command (format "rm -rf %S" root-dir)))))))

(defun ensime-kill-all-ensime-servers ()
  "Kill all inferior ensime server buffers."
  (dolist (b (buffer-list))
    (when (string-match "^\\*inferior-ensime-server.*" (buffer-name b))
      (kill-buffer b))))

(defmacro ensime-test-var-put (var val)
  "Helper for writing to shared testing state."
  `(with-current-buffer ensime-testing-buffer
     (setq ensime-shared-test-state
           (plist-put ensime-shared-test-state ,var ,val))))

(defmacro ensime-test-var-get (var)
  "Helper for reading from shared testing state."
  `(with-current-buffer ensime-testing-buffer
     (plist-get ensime-shared-test-state ,var)))

(defun ensime-test-sig (event value)
  "Driver for asynchonous tests. This function is invoked from ensime core,
   signaling events to events handlers installed by asynchronous tests."
  (when (buffer-live-p (get-buffer ensime-testing-buffer))
    (message "Received test event: %s with value %s" event value)
    (with-current-buffer ensime-testing-buffer
      (when (not (null ensime-async-handler-stack))
        (let* ((ensime-prefer-noninteractive t)
               (handler (car ensime-async-handler-stack))
               (handler-event (plist-get handler :event))
               (guard-func (plist-get handler :guard-func)))
          (if (and (equal event handler-event)
                   (or (null guard-func) (funcall guard-func value)))
              (let ((handler-func (plist-get handler :func))
                    (is-last (plist-get handler :is-last)))
                (message "Handling test event: %s" event)
                (pop ensime-async-handler-stack)
                (save-excursion
                  (condition-case signal
                      (funcall handler-func value)
                    (ensime-test-interrupted
                     (message
                      "Error executing test: %s, moving to next." signal)
                     (setq is-last t))))
                (when is-last
                  (setq ensime-async-handler-stack nil)
                  (pop ensime-test-queue)
                  (when (not (null ensime-ecukes-callbacks))
                    (dolist (cb ensime-ecukes-callbacks)
                      (progn
                        (message "Handler callback")
                        (funcall cb)))
                    (setq ensime-ecukes-callbacks nil))
                  (ensime-run-next-test)))
            (message "Got %s, expecting %s. Ignoring event."
                     event handler-event))
          (dolist (callback ensime-ecukes-callbacks)
            (let ((event-type (plist-get callback :event))
                  (event-cb (plist-get callback :cb)))
              (message "Processing event %s" event-type)
              (if (equal event-type event)
                  (progn
                    (funcall event-cb)
                    (setq ensime-ecukes-callbacks (delete callback ensime-ecukes-callbacks)))))))))))


(defun ensime-run-suite (suite)
  "Run a sequence of tests."
  (switch-to-buffer ensime-testing-buffer)
  (erase-buffer)
  (setq ensime-test-queue suite)
  (ensime-run-next-test))

(defmacro ensime-test-suite (&rest tests)
  "Define a sequence of tests to execute.
   Tests may be synchronous or asynchronous."
  `(list ,@tests))


(defmacro ensime-test (title &rest body)
  "Define a synchronous test."
  `(list :title ,title :async nil
         :func (lambda ()
                 (ensime-test-run-with-handlers
                  ,title
                  ,@body))))


(defmacro ensime-test-run-with-handlers (context &rest body)
  "Evaluate body in the context of an error handler. Handle errors by
   writing to the testing output buffer."
  `(save-excursion
     (condition-case signal
         (progn ,@body)
       (ensime-test-assert-failed
	(setq ensime--test-had-failures t)
        (message "Assertion failed at '%s': %s" ,context signal)
        (signal
         'ensime-test-interrupted
         (format "Test interrupted: %s." signal))))))


(defmacro* ensime-async-test (title trigger &rest handlers)
  "Define an asynchronous test. Tests have the following structure:
   (ensime-async-test
    title
    trigger-expression
    [handler]*
   )
   Where:
   title is a string that describes the test.
   trigger-expression is some expression that either constitutes the entire
     test, or (as is more common) invokes some process that will yield an
     asynchronous event.
   handler is of the form (head body)
     Where:
     head is of the form (event-type value-name guard-expression?)
        Where:
        event-type is a keyword that identifies the event class
        value-name is the symbol to which to bind the event payload
        guard-expression is an expression evaluated with value-name bound to
          the payload.
     body is an arbitrary expression evaluated with value-name bound to the
       payload of the event.

   When the test is executed, trigger-expression is evaluated. The test then
   waits for an asynchronous test event. When an event is signalled, the next
   handler in line is considered. If the event type of the handler's head
   matches the type of the event and the guard-expression evaluates to true,
   the corresponding handler body is executed.

   Handlers must be executed in order, they cannot be skipped. The test will
   wait in an unfinished state until an event is signalled that matches the
   next handler in line.
   "
  (let* ((last-handler (car (last handlers)))
         (handler-structs
          (mapcar
           (lambda (h)
             (let* ((head (car h))
                    (evt (car head))
                    (val-sym (car (cdr head)))
                    (guard-expr (car (cdr (cdr head))))
                    (func-body (cdr h))
                    (func `(lambda (,val-sym)
                             (ensime-test-run-with-handlers
                              ,title
                              ,@func-body))))
               (list
                :event evt
                :val-sym val-sym
                :guard-func (when guard-expr
                              (list 'lambda (list val-sym) guard-expr))
                :func func
                :is-last (eq h last-handler))))
           handlers))
         (trigger-func
          `(lambda ()
             (ensime-test-run-with-handlers
              ,title
              ,trigger))))
    `(list :title ,title :async t
           :trigger ,trigger-func
           :handlers ',handler-structs)))

(defun ensime-run-next-test ()
  "Run the next test from the test queue."
  (ensime-kill-all-ensime-servers)
  (with-current-buffer ensime-testing-buffer
    (if ensime-test-queue
        (let ((ensime-prefer-noninteractive t)
              (test (car ensime-test-queue)))
          (setq ensime-shared-test-state '())
          (setq ensime-async-handler-stack '())
          (message "\n")
          (message "Starting test: '%s'" (plist-get test :title))
          (if (plist-get test :async)
              ;; Asynchronous test
              (let ((handlers (reverse (plist-get test :handlers))))
                (dolist (h handlers)
                  (push h ensime-async-handler-stack))
                (funcall (plist-get test :trigger)))
            ;; Synchronous test
            (progn
              (pop ensime-test-queue)
              (save-excursion
                (condition-case signal
                    (funcall (plist-get test :func))
                  (ensime-test-interrupted
                   (message "Error executing test, moving to next."))))
              (ensime-run-next-test))))
      (progn
        (goto-char (point-max))
        (let* ((status (if ensime--test-had-failures 1 0))
               (msg (format "Finished suite with status %s." status)))
          (message msg)
          (when ensime--test-exit-on-finish
            (kill-emacs status)))))))

(defmacro ensime-assert (pred)
  `(let ((val ,pred))
     (if (not val)
         (with-current-buffer ensime-testing-buffer
           (signal 'ensime-test-assert-failed
                   (format "Expected truth of %s." ',pred))))))


(defmacro ensime-assert-equal (a b)
  `(let ((val-a ,a)
         (val-b ,b))
     (if (equal val-a val-b) t
       (with-current-buffer ensime-testing-buffer
         (signal 'ensime-test-assert-failed
                 (format "Expected %s to equal %S, but was %S." ',a val-b val-a))))))

(defun ensime-assert-file-contains-string (f str)
  (with-temp-buffer
    (insert-file-contents-literally f)
    (goto-char (point-min))
    (ensime-assert (search-forward str nil t))))

(defun ensime-stop-tests ()
  "Forcibly stop all tests in progress."
  (interactive)
  (with-current-buffer ensime-testing-buffer
    (setq ensime-async-handler-stack nil)
    (setq ensime-test-queue nil))
  (switch-to-buffer ensime-testing-buffer))

(defun ensime-test-eat-label (mark)
  (goto-char (point-min))
  (when (search-forward-regexp (concat "/\\*" mark "\\*/") nil t)
    (kill-backward-chars (+ 4 (length mark)))))

(defun ensime-test-after-label (mark)
  (save-excursion
    (goto-char (point-min))
    (when (search-forward-regexp (concat "/\\*" mark "\\*/") nil t)
      (point))))

(defun ensime-test-before-label (mark)
  (- (ensime-test-after-label mark) (+ 5 (length mark))))


(defmacro* ensime-test-with-proj ((proj-name src-files-name) &rest body)
  "Evaluate body in a context where the current test project is bound
 to proj-name, the src-files of the project are bound to src-files-name,
 and the active buffer is visiting the first file in src-files."
  `(let* ((,proj-name (ensime-test-var-get :proj))
          (,src-files-name (plist-get ,proj-name :src-files))
          (existing (remove-if-not #'file-exists-p ,src-files-name)))
     (when existing
       (find-file (car existing)))
     ,@body))

(defmacro ensime-test-init-proj (proj-name)
  "Store the project in a test var. Load the source files, switch to
 the first source file, and init ensime."
  `(let ((src-files (plist-get ,proj-name :src-files)))
     (ensime-test-var-put :proj ,proj-name)
     (find-file (car src-files))
     (ensime)))

(defmacro ensime-test-cleanup (proj-name &optional no-del)
  "Delete temporary project files. Kill ensime buffers."
  `(progn
     (ensime-cleanup-tmp-project ,proj-name ,no-del)
     (ensime-kill-all-ensime-servers)))

;;;;;;;;;;;;;;;;;;
;; ENSIME Tests ;;
;;;;;;;;;;;;;;;;;;

(defvar ensime-fast-suite

  (ensime-test-suite

   (ensime-test
    "Test loading a simple config."
    (ensime-with-tmp-file
     (file "ensime_test_conf_"
           (format "%S"
                   '( :server-cmd
                      "bin/server.sh"
                      :dependendency-dirs ("hello" "world"))))
     (let ((conf (ensime-config-load file)))
       (ensime-assert (equal (plist-get conf :server-cmd) "bin/server.sh"))
       (ensime-assert (equal (plist-get conf :dependendency-dirs)
                             '("hello" "world")))
       )))

   (ensime-test
    "Test loading a broken(syntactically) config file."
    (ensime-with-tmp-file
     (file "ensime_test_conf_" "(lkjsdfkjskfjs")
     (let ((conf
            (condition-case er
                (ensime-config-load file)
              (error nil))))
       (ensime-assert (null conf)))))

   (ensime-test
    "Test name partitioning..."

    (ensime-with-name-parts
     "java.util.List" (p o n)
     (ensime-assert-equal (list p o n)
                          (list "java.util" nil "List")))

    (ensime-with-name-parts
     "scala.tools.nsc.symtab.Types$Type" (p o n)
     (ensime-assert-equal (list p o n)
                          (list "scala.tools.nsc.symtab" "Types" "Type")))

    (ensime-with-name-parts
     "scala.tools.nsc.symtab.Types" (p o n)
     (ensime-assert-equal (list p o n)
                          (list "scala.tools.nsc.symtab" nil "Types")))

    (ensime-with-name-parts
     "scala.tools.nsc.symtab.Types$Dude$AbsType" (p o n)
     (ensime-assert-equal
      (list p o n)
      (list "scala.tools.nsc.symtab" "Types$Dude" "AbsType")))

    (ensime-with-name-parts
     "scala.tools.nsc.symtab.Types$$Type$" (p o n)
     (ensime-assert-equal (list p o n)
                          (list "scala.tools.nsc.symtab" "Types$" "Type$")))

    (ensime-with-name-parts
     "Types$$Type$" (p o n)
     (ensime-assert-equal (list p o n)
                          (list "" "Types$" "Type$"))))

   (ensime-test
    "Test course name partitioning..."

    (ensime-with-path-and-name
     "java.util.List" (p n)
     (ensime-assert-equal (list p n)
                          (list "java.util" "List")))

    (ensime-with-path-and-name
     "scala.tools.nsc.symtab.Types$Type" (p n)
     (ensime-assert-equal (list p n)
                          (list "scala.tools.nsc.symtab" "Types$Type")))

    (ensime-with-path-and-name
     "scala.tools.nsc.symtab.Types" (p n)
     (ensime-assert-equal (list p n)
                          (list "scala.tools.nsc.symtab" "Types")))

    (ensime-with-path-and-name
     "scala.tools.nsc.symtab.Types$Dude$AbsType" (p n)
     (ensime-assert-equal (list p n)
                          (list "scala.tools.nsc.symtab" "Types$Dude$AbsType")))

    (ensime-with-path-and-name
     "scala.tools.nsc.symtab.Types$$Type$" (p n)
     (ensime-assert-equal (list p n)
                          (list "scala.tools.nsc.symtab" "Types$$Type$")))

    (ensime-with-path-and-name
     "Types$$Type$" (p n)
     (ensime-assert-equal (list p n)
                          (list "" "Types$$Type$")))

    (ensime-with-path-and-name
     "java.uti" (p n)
     (ensime-assert-equal (list p n)
                          (list "java" "uti")))

    (ensime-with-path-and-name
     "uti" (p n)
     (ensime-assert-equal (list p n)
                          (list "" "uti"))))

   (ensime-test
    "Test is source file predicate..."
    (ensime-assert (ensime-source-file-p "dude.scala"))
    (ensime-assert (ensime-source-file-p "dude.java"))
    (ensime-assert (not (ensime-source-file-p "dude.javap"))))

   (ensime-test
    "Test relativization of paths..."
    (ensime-assert-equal
     "./rabbits.txt"
     (ensime-relativise-path "/home/aemon/rabbits.txt" "/home/aemon/"))
    (ensime-assert-equal
     "./a/b/d.txt"
     (ensime-relativise-path "/home/aemon/a/b/d.txt" "/home/aemon/"))
    (ensime-assert-equal
     "./a/b/d.txt"
     (ensime-relativise-path  "c:/home/aemon/a/b/d.txt" "c:/home/aemon/"))
    (ensime-assert-equal
     "c:/home/blamon/a/b/d.txt"
     (ensime-relativise-path  "c:/home/blamon/a/b/d.txt" "c:/home/aemon/")))

   (ensime-test
    "Test ensime-sem-high-internalize-syms in Unix mode"
    (with-temp-buffer
      (let* ((contents "a\nbc\nd\nef\ngh")
             (num-chars (length contents))
             (last-offset num-chars)
             syms
             internalized-syms
             expected)
        (insert contents)
        (dotimes (i last-offset)
          (push (list 'a i last-offset) syms)
          (push (list 'a
                      (ensime-internalize-offset i)
                      (ensime-internalize-offset last-offset))
                expected))
        (setf expected (sort expected (lambda (a b) (< (nth 1 a) (nth 1 b)))))
        (setf internalized-syms
              (sort (ensime-sem-high-internalize-syms syms)
                    (lambda (a b) (< (nth 1 a) (nth 1 b)))))
        (ensime-assert-equal internalized-syms expected))))

   (ensime-test
    "Test ensime-sem-high-internalize-syms in DOS mode"
    (with-temp-buffer
      (setf buffer-file-coding-system 'undecided-dos)
      (let* ((contents "a\nbc\nd\nef\ngh")
             (num-chars (length contents))
             (last-offset (+ 5 num-chars))
             syms
             internalized-syms
             expected)
        (insert contents)
        (dotimes (i last-offset)
          (push (list 'a i last-offset) syms)
          (push (list 'a
                      (ensime-internalize-offset i)
                      (ensime-internalize-offset last-offset))
                expected))
        (setf expected (sort expected (lambda (a b) (< (nth 1 a) (nth 1 b)))))
        (setf internalized-syms
              (sort (ensime-sem-high-internalize-syms syms)
                    (lambda (a b) (< (nth 1 a) (nth 1 b)))))
        (ensime-assert-equal internalized-syms expected))))

   (ensime-test
    "Test ensime-insert-import with no package or import statement"
    (with-temp-buffer
      (set-visited-file-name "/tmp/fake/dir/abc.scala" t)
      (insert (ensime-test-concat-lines
               "class C {"
               "  def f = 1 /*1*/"
               "}"))
      (goto-char (ensime-test-after-label "1"))

      (ensime-insert-import "org.example")
      (set-buffer-modified-p nil)

      (ensime-assert-equal
       (buffer-substring-no-properties (point-min) (point-max))
       (ensime-test-concat-lines
        "import org.example"
        ""
        "class C {"
        "  def f = 1 /*1*/"
        "}"))))

   (ensime-test
    "Test ensime-insert-import with package statement"
    (with-temp-buffer
      (set-visited-file-name "/tmp/fake/dir/abc.scala" t)
      (insert (ensime-test-concat-lines
               "package com.example"
               "class C {"
               "  def f = 1 /*1*/"
               "}"))
      (goto-char (ensime-test-after-label "1"))

      (ensime-insert-import "org.example")
      (set-buffer-modified-p nil)

      (ensime-assert-equal
       (buffer-substring-no-properties (point-min) (point-max))
       (ensime-test-concat-lines
        "package com.example"
        ""
        "import org.example"
        ""
        "class C {"
        "  def f = 1 /*1*/"
        "}"))))

   (ensime-test
    "Test ensime-insert-import with import statement"
    (with-temp-buffer
      (set-visited-file-name "/tmp/fake/dir/abc.scala" t)
      (insert (ensime-test-concat-lines
               "import m"
               ""
               ""
               "import n"
               ""
               "import p"
               "class C {"
               "  def f = 1 /*1*/"
               "}"))
      (goto-char (ensime-test-after-label "1"))

      (ensime-insert-import "org.example")
      (set-buffer-modified-p nil)

      (ensime-assert-equal
       (buffer-substring-no-properties (point-min) (point-max))
       (ensime-test-concat-lines
        "import m"
        ""
        ""
        "import n"
        "import org.example"
        ""
        "import p"
        "class C {"
        "  def f = 1 /*1*/"
        "}"))))

   (ensime-test
    "Test ensime-insert-import stays above point"
    (with-temp-buffer
      (set-visited-file-name "/tmp/fake/dir/abc.scala" t)
      (insert (ensime-test-concat-lines
               "class C {"
               "  import example._ /*1*/"
               "  def f = 1"
               "}"))
      (goto-char (ensime-test-after-label "1"))

      (ensime-insert-import "org.example")
      (set-buffer-modified-p nil)

      (ensime-assert-equal
       (buffer-substring-no-properties (point-min) (point-max))
       (ensime-test-concat-lines
        "class C {"
        "  import org.example"
        "  import example._ /*1*/"
        "  def f = 1"
        "}"))))

   (ensime-test
    "Test completion prefix lexing."
    (with-temp-buffer
      (insert (ensime-test-concat-lines
               "package/*12*/ com.example"
               "class C {"
               "  def main {"
	       "     val rat = dog/*1*/"
	       "     rat ++=/*2*/"
	       "     rat !/*3*/"
	       "     rat CaptainCrun/*4*/"
	       "     rat.++=/*5*/"
	       "     rat.toSt/*6*/"
	       "     x/*7*/"
	       "     /*hello*/dog/*8*/"
	       "     while (moose/*9*/)prin/*10*/"
	       "     case _ =>r/*11*/"
	       "  }"
               "}"))
      (dotimes (i 12)
	(ensime-test-eat-label (int-to-string (1+ i)))
	(ensime-assert-equal
	 (ensime-completion-prefix-at-point)
	 (nth i '("dog"
		  "++="
		  "!"
		  "CaptainCrun"
		  "++="
		  "toSt"
		  "x"
		  "dog"
		  "moose"
		  "prin"
		  "r"
		  "package"
		  ))))
      ))

   (ensime-test
    "Test ensime-short-local-name"
    (ensime-assert-equal (ensime-short-local-name "Junk") "Junk")
    (ensime-assert-equal (ensime-short-local-name "Foo$$Junk") "Junk")
    (ensime-assert-equal (ensime-short-local-name "Foo$$Junk$") "Junk"))

   (ensime-test
    "Test ensime-strip-dollar-signs"
    (ensime-assert-equal (ensime-strip-dollar-signs "com.example.Foo$")
                         "com.example.Foo")
    (ensime-assert-equal (ensime-strip-dollar-signs "com.example.Foo$$Junk")
                         "com.example.Foo.Junk"))


   (ensime-test
    "Test ensime-path-includes-dir-p"
    (unless (find system-type '(windows-nt cygwin))
      (let ((d (make-temp-file "foo" t)))
        (make-directory (concat d "/proj/src/main") t)
        (make-directory (concat d "/proj/src/main/java") t)
        (ensime-create-file (concat d "/proj/src/main/java/Test.java") "import java.util.bla")
        (make-directory (concat d "/tmp/scala_misc") t)
        (ensime-create-file (concat d "/tmp/scala_misc/Test.scala") "import java.util.bla")
        (ensime-create-file (concat d "/tmp/other_misc/Things.scala") "import bla bla")
        (make-symbolic-link (concat d "/tmp/scala_misc") (concat d "/proj/src/main/scala"))
        (make-symbolic-link (concat d "/tmp/other_misc/Things.scala") (concat d "/proj/src/main/scala/Things.scala"))
        (assert (file-exists-p (concat d "/proj/src/main/java/Test.java")))
        (assert (file-exists-p (concat d "/proj/")))
        (assert (ensime-path-includes-dir-p (concat d "/proj/src/main/java/Test.java")
                                            (concat d "/proj")))
        (assert (ensime-path-includes-dir-p (concat d "/proj/src/main/scala/Test.scala")
                                            (concat d "/proj")))
        (assert (ensime-path-includes-dir-p (concat d "/proj/src/main/scala/Test.scala")
                                            (concat d "/proj/src")))
        (assert (ensime-path-includes-dir-p (concat d "/proj/src/main/scala/Test.scala")
                                            (concat d "/proj/src/main")))
        (assert (ensime-path-includes-dir-p (concat d "/proj/src/main/scala/Test.scala")
                                            (concat d "/")))
        (assert (ensime-path-includes-dir-p (concat d "/proj/src/main/scala/Things.scala")
                                            (concat d "/proj/src/main/scala")))
        (assert (ensime-path-includes-dir-p (concat d "/proj/src/main/scala/Things.scala")
                                            (concat d "/proj/src/")))
        (assert (ensime-path-includes-dir-p (concat d "/proj/src/main/scala/Things.scala")
                                            (concat d "/proj/src")))
        (assert (ensime-path-includes-dir-p (concat d "/proj/src/main/scala/Things.scala")
                                            (concat d "/tmp/scala_misc")))
        (assert (not (ensime-path-includes-dir-p (concat d "/proj/src/main/scala/Things.scala")
                                                 (concat d "/proj/x")))))))))

(defun ensime--test-completions ()
  "Helper for completion testing."
  (plist-get (ensime-get-completions 30 nil) :candidates))

(defvar ensime-slow-suite

  (ensime-test-suite

   (ensime-async-test
    "Test inspect type at point."
    (let* ((proj (ensime-create-tmp-project
                  `((:name
                     "test.scala"
                     :contents ,(ensime-test-concat-lines
                                 "package pack.a"
                                 "class A(value:/*1*/String){"
                                 "}"))))))
      (ensime-test-init-proj proj))

    ((:connected connection-info))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-typecheck-current-file)))

    ((:indexer-ready val)
     (ensime-test-with-proj
      (proj src-files)
      (find-file (car src-files))
      (goto-char (ensime-test-after-label "1"))
      (let* ((info (ensime-rpc-inspect-type-at-point)))
        (ensime-assert (not (null info)))
        (ensime-assert-equal (plist-get (plist-get info :type) :name) "String"))
      (ensime-test-cleanup proj))))

   (ensime-async-test
    "Test inspect type in range."
    (let* ((proj (ensime-create-tmp-project
                  `((:name
                     "test.scala"
                     :contents ,(ensime-test-concat-lines
                                 "package pack.a"
                                 "class A {"
                                 " def foo = {"
                                 "  /*1*/this bar 2"
                                 "  val x = 10"
                                 " }"
                                 " def bar(i:Int) = \"dlkjf\""
                                 "}"))))))
      (ensime-test-init-proj proj))

    ((:connected connection-info))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-typecheck-current-file)))

    ((:indexer-ready val)
     (ensime-test-with-proj
      (proj src-files)
      (find-file (car src-files))
      (goto-char (ensime-test-after-label "1"))
      (let ((info (ensime-rpc-inspect-type-at-range
                   (list (ensime-externalize-offset (point))
                         (ensime-externalize-offset (point-at-eol))))))
        (ensime-assert (not (null info)))
        (ensime-assert-equal
         (plist-get (plist-get info :type) :name) "String"))
      (ensime-test-cleanup proj))))

   (ensime-async-test
    "Test completing members."
    (let* ((proj (ensime-create-tmp-project
                  `((:name
                     "hello_world.scala"
                     :contents ,(ensime-test-concat-lines
                                 "package com.helloworld"

                                 "class HelloWorld{"
                                 "  def foo(a:Int, b:Int):Int = {"
                                 "    HelloWorld./*1*/"
                                 "  }"
                                 "  def bar(a:Int, b:Int):Int = {"
                                 "    val v = HelloWorld./*2*/"
                                 "    foo(1,v)"
                                 "  }"
                                 "}"

                                 "object HelloWorld {"
                                 "  def blarg = 5"
                                 "  def add(a:Int, b:Int) = {"
                                 "    System.out.pri/*3*/"
                                 "    a + b"
                                 "  }"
                                 "  def test() {"
                                 "    val dude = \"hello\""
                                 "    System.out.println(dude./*4*/)"
                                 "  }"
                                 "  def test2() = {"
                                 "    val dude = \"hello\""
                                 "    dude.substring(2,2).hea/*5*/"
                                 "  }"
                                 "}")))))
           (src-files (plist-get proj :src-files)))
      (ensime-test-var-put :proj proj)
      (find-file (car src-files))
      (ensime))

    ((:connected connection-info))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-typecheck-current-file)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      ;; object method completion
      (ensime-test-eat-label "1")
      (let* ((candidates (ensime--test-completions)))
        (ensime-assert (member "add" candidates)))

      ;; Try completion when a method begins without target
      ;; on next line.
      (ensime-test-eat-label "2")
      (let* ((candidates (ensime--test-completions)))
        (ensime-assert (member "blarg" candidates)))

      ;; Instance completion with prefix
      (ensime-test-eat-label "3")
      (let* ((candidates (ensime--test-completions)))
        (ensime-assert (member "println" candidates)))

      ;; Complete member of argument
      (ensime-test-eat-label "4")
      (let* ((candidates (ensime--test-completions)))
        (ensime-assert (member "substring" candidates)))

      ;; Chaining of calls
      (ensime-test-eat-label "5")
      (let* ((candidates (ensime--test-completions)))
        (ensime-assert (member "headOption" candidates)))

      (ensime-test-cleanup proj))))

   (ensime-async-test
    "Test completing symbols."
    (let* ((proj (ensime-create-tmp-project
                  `((:name
                     "hello_world.scala"
                     :contents ,(ensime-test-concat-lines
                                 "package com.helloworld"
                                 "import java.io.File"

                                 "class HelloWorld{"

                                 "  def main {"
                                 "    val f = new Fi/*1*/"
                                 "  }"

                                 "  def blarg:Int = 5"

                                 "  def add(a:Int):Int = {"
                                 "    val x = a + bl/*2*/"
				 "    x + blar/*3*/"
                                 "  }"

                                 "}")))))
           (src-files (plist-get proj :src-files)))
      (ensime-test-var-put :proj proj)
      (find-file (car src-files))
      (ensime))

    ((:connected connection-info))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-typecheck-current-file)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)

      ;; constructor completion
      (ensime-test-eat-label "1")
      (let* ((candidates (ensime--test-completions)))
        (ensime-assert (member "File" candidates)))

      ;; local method name completion.
      (ensime-test-eat-label "2")
      (let* ((candidates (ensime--test-completions)))
        (ensime-assert (member "blarg" candidates)))

      ;; exercize emacs CAPF function
      (ensime-test-eat-label "3")
      (completion-at-point)
      (ensime-assert-equal
       "blarg" (buffer-substring-no-properties (- (point) 5) (point)))

      (ensime-test-cleanup proj))))

   (ensime-async-test
    "Test expanding parameter lists."
    (let* ((proj (ensime-create-tmp-project
                  `((:name
                     "hello_world.scala"
                     :contents ,(ensime-test-concat-lines
                                 "package com.helloworld"

                                 "object HelloWorld {"
				 "  private var _field:Int = 1"
				 "  def field = _field"
				 "  def field_=(i:Int) { _field = i}"
                                 "  def add(a:Int, b:Int) = {"
                                 "    a + b"
                                 "  }"
                                 "  def str(i:Int) = {"
                                 "    i.toString"
                                 "  }"
                                 "  def doBlock(block:(Int => String)) = {"
                                 "    block()"
                                 "  }"
                                 "  def doByName(block: => String) = {"
                                 "    block"
                                 "  }"
                                 "  def test() {"
                                 "    val c = ad/*1*/"
				 "    val d = c /*2*/"
				 "    val e = d./*3*/"
				 "    val f = doBlo/*4*/"
				 "    val g = doBlo/*5*/"
				 "    val h = doByNa/*6*/"
				 "    this.fie/*7*/"
				 "    \"kjsdf\".hashCo/*8*/"
				 "    5.toLo/*9*/"
                                 "  }"
                                 "}")))))
           (src-files (plist-get proj :src-files)))
      (ensime-test-var-put :proj proj)
      (find-file (car src-files))
      (ensime))

    ((:connected connection-info))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-typecheck-current-file)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      ;; Expand simple, two argument list.
      (ensime-test-eat-label "1")
      (let* ((candidates (ensime--test-completions))
	     (pt (point)))
        (ensime-assert (member "add" candidates))
	(insert "d")
	(ensime--yasnippet-complete-action (car (member "add" candidates)))
	(insert "2") (yas-next-field) (insert "3") (yas-next-field)
	(ensime-assert-equal
	 (buffer-substring-no-properties pt (point)) "d(2, 3)"))
      (ensime-typecheck-current-file)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      ;; Expand operator.
      (ensime-test-eat-label "2")
      (let* ((candidates (ensime--test-completions))
	     (pt (point)))
        (ensime-assert (member "+" candidates))
	(insert "+")
	(ensime--yasnippet-complete-action (car (member "+" candidates)))
	(insert "5") (yas-next-field)
	(ensime-assert-equal
	 (buffer-substring-no-properties pt (point)) "+ 5"))
      (ensime-typecheck-current-file)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      ;; Expand operator after typing '.'
      (ensime-test-eat-label "3")
      (let* ((candidates (ensime--test-completions))
	     (pt (point)))
        (ensime-assert (member "+" candidates))
	(insert "+")
	(ensime--yasnippet-complete-action (car (member "+" candidates)))
	(insert "8") (yas-next-field)
	(ensime-assert-equal
	 (buffer-substring-no-properties (- pt 1) (point)) " + 8"))
      (ensime-typecheck-current-file)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      ;; Expand a function taking a named function as argument.
      (ensime-test-eat-label "4")
      (let* ((candidates (ensime--test-completions))
	     (pt (point)))
        (ensime-assert (member "doBlock" candidates))
	(insert "ck")
	(ensime--yasnippet-complete-action (car (member "doBlock" candidates)) ?\()
	(insert "str") (yas-next-field)
	(ensime-assert-equal
	 (buffer-substring-no-properties pt (point)) "ck(str)"))
      (ensime-typecheck-current-file)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      ;; Expand a function taking a function block as argument.
      (ensime-test-eat-label "5")
      (let* ((candidates (ensime--test-completions))
	     (pt (point)))
        (ensime-assert (member "doBlock" candidates))
	(insert "ck")
	(ensime--yasnippet-complete-action (car (member "doBlock" candidates)) ?\{)
	(insert "i") (yas-next-field) (insert "str") (yas-next-field)
	(ensime-assert-equal
	 (buffer-substring-no-properties pt (point)) "ck { i => str }"))
      (ensime-typecheck-current-file)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      ;; Expand a function taking a by name block.
      (ensime-test-eat-label "6")
      (let* ((candidates (ensime--test-completions))
	     (pt (point)))
        (ensime-assert (member "doByName" candidates))
	(insert "me")
	(ensime--yasnippet-complete-action (car (member "doByName" candidates)) ?\{)
	(ensime-assert-equal
	 (buffer-substring-no-properties pt (point)) "me { ")
	(insert "\"bla\""))
      (ensime-typecheck-current-file)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      ;; Expand a field assignment
      (ensime-test-eat-label "7")
      (let* ((candidates (ensime--test-completions))
	     (pt (point)))
        (ensime-assert (member "field_=" candidates))
	(insert "ld_=")
	(ensime--yasnippet-complete-action (car (member "field_=" candidates)) ?\{)
	(insert "2") (yas-next-field)
	(ensime-assert-equal
	 (buffer-substring-no-properties pt (point)) "ld = 2"))
      (ensime-typecheck-current-file)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      ;; Expand an empty argument list for java method.
      (ensime-test-eat-label "8")
      (let* ((candidates (ensime--test-completions))
	     (pt (point)))
        (ensime-assert (member "hashCode" candidates))
	(insert "de")
	(ensime--yasnippet-complete-action (car (member "hashCode" candidates)))
	(ensime-assert-equal
	 (buffer-substring-no-properties pt (point)) "de()"))
      (ensime-typecheck-current-file)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      ;; Expand an no argument list for nullary scala method
      (ensime-test-eat-label "9")
      (let* ((candidates (ensime--test-completions))
	     (pt (point)))
        (ensime-assert (member "toLong" candidates))
	(insert "ng")
	(ensime--yasnippet-complete-action (car (member "toLong" candidates)))
	(ensime-assert-equal
	 (buffer-substring-no-properties pt (point)) "ng"))
      (ensime-typecheck-current-file)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-test-cleanup proj))))


   (ensime-async-test
    "Test completing imports."
    (let* ((proj (ensime-create-tmp-project
                  `((:name
                     "hello_world.scala"
                     :contents ,(ensime-test-concat-lines
                                 "package com.helloworld"
                                 "import scala.collection.imm/*1*/"
                                 "import Vec/*3*/"
                                 "import scala.collection.immutable.{ List, Vec/*4*/}"
                                 "class HelloWorld{"
                                 "import sc/*2*/"
                                 "}")))))
           (src-files (plist-get proj :src-files)))
      (ensime-test-var-put :proj proj)
      (find-file (car src-files))
      (ensime))

    ((:connected connection-info))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-typecheck-current-file)))

    ((:indexer-ready status)
     (ensime-test-with-proj
      (proj src-files)

      (find-file (car src-files))

      ;; complete package member
      (ensime-test-eat-label "1")
      (let* ((candidates (ensime--test-completions)))
        (ensime-assert (member "immutable" candidates)))
      (insert "utable.List")
      (ensime-typecheck-current-file)
      ))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      ;; complete package member by class name
      (ensime-test-eat-label "3")
      (let* ((candidates (ensime--test-completions))
             (to-inserts (mapcar (lambda (c) (get-text-property 0 'to-insert c))
				candidates)))
        (ensime-assert (member "scala.collection.immutable.Vector" to-inserts)))
      (ensime-typecheck-current-file)
      ))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      ;; complete package member by class name in name list
      (ensime-test-eat-label "4")
      (let* ((candidates (ensime--test-completions)))
        (ensime-assert (member "Vector" candidates)))
      (ensime-typecheck-current-file)
      ))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      ;; complete scala package in class body
      (ensime-test-eat-label "2")
      (let* ((candidates (ensime--test-completions)))
        (ensime-assert (member "scala" candidates)))

      (ensime-test-cleanup proj))))

   (ensime-async-test
    "Test organize imports refactoring: remove unused import."
    (let* ((proj (ensime-create-tmp-project
                  `((:name
                     "hello_world.scala"
                     :contents ,(ensime-test-concat-lines
                                 "package com.helloworld"
                                 "import scala.collection.immutable.Vector"
                                 "class HelloWorld{"
                                 "}"))))))
      (ensime-test-init-proj proj))

    ((:connected connection-info))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-typecheck-current-file)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-refactor-organize-imports)))

    ((:refactor-at-confirm-buffer val)
     (switch-to-buffer ensime-refactor-info-buffer-name)
     (funcall (key-binding (kbd "c"))))

    ((:refactor-done touched-files)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-assert
       (equal (length touched-files) 1))
      (goto-char (point-min))
      (ensime-assert (null (search-forward "import scala.collection.immutable.Vector" nil t)))
      (ensime-test-cleanup proj))))

   (ensime-async-test
    "Test rename refactoring over multiple files."
    (let* ((proj (ensime-create-tmp-project
                  `((:name
                     "hello_world.scala"
                     :contents ,(ensime-test-concat-lines
                                 "package com.helloworld"
                                 "class /*1*/HelloWorld{"
                                 "}"))
                    (:name
                     "another.scala"
                     :contents ,(ensime-test-concat-lines
                                 "package com.helloworld"
                                 "object Another {"
                                 "def main(args:Array[String]) {"
                                 "val a = new HelloWorld()"
                                 "}"
                                 "}"))))))
      (ensime-test-init-proj proj))

    ((:connected connection-info))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      ;; refactor-rename needs all files to be typechecked
      (ensime-typecheck-all)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-assert (null (ensime-all-notes))))
     (goto-char (ensime-test-after-label "1"))
     (forward-char)
     (ensime-refactor-rename "DudeFace"))

    ((:refactor-at-confirm-buffer val)
     (switch-to-buffer ensime-refactor-info-buffer-name)
     (funcall (key-binding (kbd "c"))))

    ((:refactor-done touched-files)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-assert-file-contains-string (car src-files) "class /*1*/DudeFace")
      (ensime-assert-file-contains-string (cadr src-files) "new DudeFace()")))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      ;; Do a followup refactoring to make sure compiler reloaded
      ;; all touched files after the first rename...
      (find-file (car src-files))
      (goto-char (point-min))
      (search-forward "Dude" nil t)
      (ensime-refactor-rename "Horse")))

    ((:refactor-at-confirm-buffer val)
     (switch-to-buffer ensime-refactor-info-buffer-name)
     (funcall (key-binding (kbd "c"))))

    ((:refactor-done touched-files)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-assert-file-contains-string (car src-files) "class /*1*/Horse")
      (ensime-assert-file-contains-string (cadr src-files) "new Horse()")))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-assert (null (ensime-all-notes)))
      (ensime-test-cleanup proj))))

   (ensime-async-test
    "Test find-references."
    (let* ((proj (ensime-create-tmp-project
                  `((:name
                     "pack/a.scala"
                     :contents ,(ensime-test-concat-lines
                                 "package pack"
                                 "class /*1*/A(value:String){"
                                 "}"))
                    (:name
                     "pack/b.scala"
                     :contents ,(ensime-test-concat-lines
                                 "package pack"
                                 "class B(value:String) extends A(value){"
                                 "}"))))))
      (ensime-test-init-proj proj))

    ((:connected connection-info))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      ;; find-references requires all files to be typechecked
      (ensime-typecheck-all)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-test-eat-label "1")
      (save-buffer)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-show-uses-of-symbol-at-point)))

    ((:references-buffer-shown val)
     (switch-to-buffer ensime-uses-buffer-name)
     (goto-char (point-min))
     (ensime-assert (search-forward "class B(value:String) extends A" nil t))
     (funcall (key-binding (kbd "q")))
     (ensime-test-cleanup proj)))

   (ensime-async-test
    "Test file with package name (this broke when -sourcepath param was used)."
    (let* ((proj (ensime-create-tmp-project
                  `((:name
                     "pack/a.scala"
                     :contents ,(ensime-test-concat-lines
                                 "package pack.a"
                                 "class A(value:String){"
                                 "}"))
                    (:name
                     "pack/b.scala"
                     :contents ,(ensime-test-concat-lines
                                 "package pack.a"
                                 "class B(value:String) extends A(value){"
                                 "}"))))))
      (ensime-test-init-proj proj))

    ((:connected connection-info))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-typecheck-all)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (let* ((notes (ensime-all-notes)))
        (ensime-assert-equal (length notes) 0))
      (ensime-test-cleanup proj))))

   (ensime-async-test
    "Test deleting file and reloading."
    (let* ((proj (ensime-create-tmp-project
                  `((:name
                     "pack/a.scala"
                     :contents ,(ensime-test-concat-lines
                                 "package pack"
                                 "class A(value:String){"
                                 "}"))
                    (:name
                     "pack/b.scala"
                     :contents ,(ensime-test-concat-lines
                                 "package pack"
                                 "class B(value:String) extends A(value){"
                                 "}"))))))
      (ensime-test-init-proj proj))

    ((:connected connection-info))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-typecheck-all)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (let* ((notes (ensime-all-notes)))
        (ensime-assert-equal (length notes) 0))
      (kill-buffer nil)
      (delete-file (car src-files))
      (find-file (cadr src-files))))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-typecheck-all)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (let* ((notes (ensime-all-notes)))
        (ensime-assert (> (length notes) 0)))
      (ensime-test-cleanup proj))))

   (ensime-async-test
    "Test formatting source."
    (let* ((proj (ensime-create-tmp-project
                  `((:name
                     "format_world.scala"
                     :contents ,(ensime-test-concat-lines
                                 "class HelloWorld{"
                                 "def foo:Int=1"
                                 "}"
                                 ""))))))
      (ensime-test-init-proj proj))

    ((:connected connection-info))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-typecheck-current-file)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (find-file (car src-files))
      ;; Formatting became synchronous with protocol 0.8.11 :-(
      (ensime-assert (version< "0.8.10" (ensime-protocol-version) ))
      (ensime-format-source)
      (let ((src (buffer-substring-no-properties
                  (point-min) (point-max))))
        (ensime-assert-equal src (ensime-test-concat-lines
                                  "class HelloWorld {"
                                  "  def foo: Int = 1"
                                  "}"
                                  "")))
      (ensime-test-cleanup proj))))

   (ensime-async-test
    "Get package info for com.helloworld."
    (let* ((proj (ensime-create-tmp-project
                  ensime-tmp-project-hello-world)))
      (ensime-test-init-proj proj))

    ((:connected connection-info))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-typecheck-current-file)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (let ((info (ensime-rpc-inspect-package-by-path
                   "com.helloworld")))
        (ensime-assert (not (null info)))
        (ensime-assert-equal
         (ensime-package-full-name info) "com.helloworld")
        ;; Should be one class, one object
        (ensime-assert-equal
         2 (length (ensime-package-members info))))
      (ensime-test-cleanup proj))))

   (ensime-async-test
    "Verify re-typecheck on save-buffer."
    (let* ((proj (ensime-create-tmp-project
                  ensime-tmp-project-hello-world)))
      (ensime-test-init-proj proj))

    ((:connected connection-info))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-typecheck-current-file)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (let* ((notes (ensime-all-notes)))
        (ensime-assert-equal (length notes) 0)
        (find-file (car src-files))
        (goto-char (point-min))
        (insert "lksdjfldkjf ")

        ;; save-buffer should trigger a recheck...
        (save-buffer))))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (let ((proj (ensime-test-var-get :proj))
            (notes (ensime-all-notes)))
        (ensime-assert (> (length notes) 0))
        (ensime-test-cleanup proj)))))

   (ensime-async-test
    "Test get symbol info at point."
    (let* ((proj (ensime-create-tmp-project
                  `((:name
                     "hello.scala"
                     :contents ,(ensime-test-concat-lines
                                 "package pack"
                                 "class A {"
                                 "  def foo(/*2*/a:Int, b:Int):Int = {"
                                 "    a/*1*/ + b"
                                 "  }"
                                 "}"))))))
      (ensime-test-init-proj proj))

    ((:connected connection-info))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-typecheck-current-file)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (goto-char (ensime-test-before-label "1"))
      (let* ((info (ensime-rpc-symbol-at-point))
             (pos (ensime-symbol-decl-pos info)))
        (ensime-assert-equal
         (ensime-pos-offset pos)
         (ensime-externalize-offset (ensime-test-after-label "2"))))
      (ensime-test-cleanup proj))))

   (ensime-async-test
    "Test get repl config."
    (let* ((proj (ensime-create-tmp-project
                  ensime-tmp-project-hello-world)))
      (ensime-test-init-proj proj))

    ((:connected connection-info))

    ((:compiler-ready status)
     (ensime-test-with-proj
      (proj src-files)
      (let ((conf (ensime-rpc-repl-config)))
        (ensime-assert (not (null conf)))
        (ensime-assert
         (not (null (plist-get conf :classpath)))))

      (ensime-test-cleanup proj))))

   (ensime-async-test
    "Test interactive search."
    (let* ((proj (ensime-create-tmp-project
                  ensime-tmp-project-hello-world)))
      (ensime-test-init-proj proj))

    ((:connected connection-info))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-typecheck-current-file)))

    ((:indexer-ready status)
     (ensime-test-with-proj
      (proj src-files)
      ;; Prevent a previous search from affecting this test
      (setq ensime-search-text "")
      (ensime-search)
      (insert "scala.collection.immutable.Vector")))

    ((:search-buffer-populated val)
     (ensime-test-with-proj
      (proj src-files)

      (with-current-buffer ensime-search-target-buffer-name
        ;; uncomment to see the results (e.g. if they change due to server improvements)
        ;;(message "%s" (buffer-string))
        (goto-char 1)
        (ensime-assert (search-forward-regexp "scala.collection.immutable.Vector[[:space:]]+" nil t))
        (goto-char 1)
        ;; I don't necessarilly agree with these results, indeed they will change when
        ;; we refactor the search backend.
        (ensime-assert (search-forward "scala.collection.immutable.VectorIterator" nil t)))

      (ensime-search-quit)
      (ensime-test-cleanup proj))))

   (ensime-async-test
    "Test add import."
    (let* ((proj (ensime-create-tmp-project
                  `((:name
                     "pack/a.scala"
                     :contents ,(ensime-test-concat-lines
                                 "package pack"
                                 "class A(value:String){"
                                 "def hello(){"
                                 "  println(new /*1*/ListBuffer())"
                                 "}"
                                 "}"))))))
      (ensime-test-init-proj proj))

    ((:connected connection-info))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-typecheck-current-file)))

    ((:indexer-ready status)
     (ensime-test-with-proj
      (proj src-files)
      (goto-char 1)
      (ensime-assert (null (search-forward "import scala.collection.mutable.ListBuffer" nil t)))

      (goto-char (ensime-test-after-label "1"))
      (ensime-import-type-at-point t)

      (goto-char 1)
      (ensime-assert (search-forward "import scala.collection.mutable.ListBuffer" nil t))

      (ensime-test-cleanup proj))))

   (ensime-async-test
    "Test expand-selection."
    (let* ((proj (ensime-create-tmp-project
                  `((:name
                     "pack/a.scala"
                     :contents ,(ensime-test-concat-lines
                                 "package pack"
                                 "class A(value:String){"
                                 "def hello(){"
                                 "  println(/*1*/\"hello\")"
                                 "}"
                                 "}"))))))
      (ensime-test-init-proj proj))

    ((:connected connection-info))

    ((:compiler-ready status)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-test-eat-label "1")
      (ensime-save-buffer-no-hooks)

      ;; Expand once to include entire string
      (let* ((pt (point))
             (range (ensime-rpc-expand-selection
                     buffer-file-name
                     pt pt))
             (start1 (plist-get range :start))
             (end1 (plist-get range :end)))
        (ensime-assert (= start1 pt))
        (ensime-assert (> end1 pt))

        ;; Expand again to include entire println call
        (let* ((range (ensime-rpc-expand-selection
                       buffer-file-name
                       start1 end1))
               (start2 (plist-get range :start))
               (end2 (plist-get range :end)))
          (ensime-assert (< start2 start1))
          (ensime-assert (> end2 end1))))

      (ensime-test-cleanup proj))))

   (ensime-async-test
    "Test semantic highlighting."
    (let* ((proj (ensime-create-tmp-project
                  `((:name
                     "pack/a.scala"
                     :contents ,(ensime-test-concat-lines
                                 "package pack"
                                 "import java.io.File"
                                 "class A(value:String) extends /*9*/Object{"
                                 "case class Dude(name:Integer)"
                                 "val myTick/*7*/ = 0"
                                 "var myTock/*8*/ = 0"
                                 "def hello(){"
                                 "  var tick/*2*/ = 1"
                                 "  val tock/*6*/ = 2"
                                 "  /*5*/println(new /*1*/File(\".\"))"
                                 "  /*3*/tick = /*4*/tick + 1"
                                 "  val d = /*10*/Dude(1)"
                                 "  d match{"
                                 "    case /*11*/Dude(i) => {}"
                                 "    case o:/*12*/Object => {}"
                                 "    case _ => {}"
                                 "  }"
                                 "}"
                                 "}"))))))
      (ensime-test-init-proj proj))

    ((:compiler-ready val)
     (ensime-test-with-proj
      (proj src-files)))

    ((:region-sem-highlighted val)
     (ensime-test-with-proj
      (proj src-files)

      ;; Don't check highlights immediately, as
      ;; overlays might not be rendered yet... (it seems)
      (ensime-typecheck-current-file)))

    ((:full-typecheck-finished val)
     (ensime-test-with-proj
      (proj src-files)
      (let ((check-sym-is (lambda (sym-type)
                            (ensime-assert
                             (memq
                              sym-type
                              (ensime-sem-high-sym-types-at-point))))))
        (goto-char (ensime-test-after-label "1"))
        (funcall check-sym-is 'class)

        (goto-char (ensime-test-before-label "2"))
        (funcall check-sym-is 'var)

        (goto-char (ensime-test-after-label "3"))
        (funcall check-sym-is 'var)

        (goto-char (ensime-test-after-label "4"))
        (funcall check-sym-is 'var)

        (goto-char (ensime-test-after-label "5"))
        (funcall check-sym-is 'functionCall)

        (goto-char (ensime-test-before-label "6"))
        (funcall check-sym-is 'val)

        (goto-char (ensime-test-before-label "7"))
        (funcall check-sym-is 'valField)

        (goto-char (ensime-test-before-label "8"))
        (funcall check-sym-is 'varField)

        (goto-char (ensime-test-after-label "9"))
        (funcall check-sym-is 'class)

        (goto-char (ensime-test-after-label "10"))
        (funcall check-sym-is 'object)

        (goto-char (ensime-test-after-label "11"))
        (funcall check-sym-is 'object)

        (goto-char (ensime-test-after-label "12"))
        (funcall check-sym-is 'class))

      (ensime-test-cleanup proj t))))

   (ensime-async-test
    "Test debugging scala project."
    (let* ((proj (ensime-create-tmp-project
                  `((:name
                     "test/Test.scala"
                     :contents ,(ensime-test-concat-lines
				 "package test"
                                 "object Test {"
                                 "  def main(args: Array[String]) {"
                                 "    val a = \"cat\""
                                 "    val b = \"dog\""
                                 "    val c = \"bird\""
                                 "    println(a + b + c)"
                                 "  }"
                                 "}")))))
           (src-files (plist-get proj :src-files)))
      (ensime-create-file
       (concat (plist-get proj :root-dir) "build.sbt")
       (ensime-test-concat-lines
	"import sbt._"
	""
	"name := \"test\""
	""
	"scalacOptions += \"-g:notailcalls\""
	""
	(concat "scalaVersion := \"" ensime--test-scala-version "\"")
	))
      (assert ensime-sbt-command)
      (let ((default-directory (plist-get proj :root-dir)))
	(assert (= 0 (apply 'call-process ensime-sbt-command nil
			    "*sbt-test-compilation*" nil '("compile")))))
      (assert (directory-files (concat (plist-get proj :target) "/test") nil "class$"))
      (ensime-test-init-proj proj))

    ((:compiler-ready val))
    
    ((:full-typecheck-finished val))

    ((:region-sem-highlighted val))

    ((:indexer-ready val)
     (ensime-test-with-proj
      (proj src-files)
      (ensime-rpc-debug-set-break buffer-file-name 7)
      (ensime-rpc-debug-start "test.Test")))
    
    ((:debug-event evt (equal (plist-get evt :type) 'start)))

    ((:debug-event evt (equal (plist-get evt :type) 'threadStart)))
    
    ((:debug-event evt (equal (plist-get evt :type) 'breakpoint))
     (ensime-test-with-proj
      (proj src-files)
      (let* ((thread-id (plist-get evt :thread-id))
	     (trace (ensime-rpc-debug-backtrace thread-id 0 -1))
             (pc-file (file-truename (car src-files))))
        (when (eql system-type 'windows-nt)
          (aset pc-file 0 (upcase (aref pc-file 0)))
          (setq pc-file (replace-regexp-in-string "/" "\\\\" pc-file)))
	(ensime-assert trace)
	(let* ((frame-zero (nth 0 (plist-get trace :frames)))
	       ;; Remove incidentals...
	       (frame (plist-put frame-zero :this-object-id "NA")))
	  (ensime-assert-equal
	   frame
	   `(:index 0 :locals
		   ((:index 0 :name "args" :summary "Array[]" :type-name "java.lang.String[]")
		    (:index 1 :name "a" :summary "\"cat\"" :type-name "java.lang.String")
		    (:index 2 :name "b" :summary "\"dog\"" :type-name "java.lang.String")
		    (:index 3 :name "c" :summary "\"bird\"" :type-name "java.lang.String"))
		   :num-args 1
		   :class-name "test.Test$"
		   :method-name "main"
		   :pc-location (:file ,pc-file :line 7)
		   :this-object-id "NA"))))
      (ensime-rpc-debug-stop)))

    ((:debug-event evt (equal (plist-get evt :type) 'disconnect))
     (ensime-test-with-proj
      (proj src-files)
      (ensime-test-cleanup proj))))
  ))


(defun ensime-run-all-tests ()
  "Run all regression tests for ensime-mode."
  (interactive)
  ;; HACK: temporarilly disable exiting, to run the fast suite
  (setq ensime--test-exit-on-finish--old ensime--test-exit-on-finish)
  (setq ensime--test-exit-on-finish nil)

  (ensime--update-server
   ensime--test-scala-version
   (lambda() 
     (ensime-run-suite ensime-fast-suite)
     (setq ensime--test-exit-on-finish ensime--test-exit-on-finish--old)
     (when (and ensime--test-had-failures ensime--test-exit-on-finish)
       (kill-emacs 1))
     (ensime-run-suite ensime-slow-suite))))

(defun ensime-run-one-test (key)
  "Run a single test selected by title.
Must run the run-all script first to update the server."
  (interactive "sEnter a regex matching a test's title: ")
  (catch 'done
    (setq ensime--test-had-failures nil)
    (let ((tests (append ensime-fast-suite
                         ensime-slow-suite)))
      (dolist (test tests)
        (let ((title (plist-get test :title)))
          (when (integerp (string-match key title))
            (ensime-run-suite (list test))
            (throw 'done nil)))))))

(provide 'ensime-test)

;; Local Variables:
;; no-byte-compile: t
;; End:

