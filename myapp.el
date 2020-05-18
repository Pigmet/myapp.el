;; Registers and runs jar files. 

;; parse repository

;; TODO: How to set the path automatically in the same directory?

;; try xml 
(setq myapp--repository-file "/Users/naka/.emacs.d/mylib/myapp/myapp-repository")

(defun myapp--get-repository-content ()
  (with-temp-buffer
    (insert-file-contents
     myapp--repository-file)
    (buffer-string)))

(defun myapp--parse
    ()
  "Parses repository file and returns alist."
  (mylet [re (rx bol (group-n 1  (+ word) eol )
		 (+ (or "\n" (+ blank)))
		 (group-n 2 (+ anything) ".jar"))
	     s (myapp--get-repository-content)
	     ret (a-alist)]
	 (loop for (_ k v) in (s-match-strings-all re s)
	       do (setq ret (a-assoc ret k v)))
	 ret))

(defun myapp--register-new-file (label path)
  (with-temp-buffer
    (insert "\n" label "\n" path "\n")
    (write-region (point-min) (point-max) myapp--repository-file t))
  (message "%s was registered." label))

(defun myapp-register()
  "Registers new a jar file in the current directory
 so that it can be executed from myapp-run."
  (interactive)
  (mylet [files (directory-files default-directory t (rx ".jar" ))
		m (a-alist)]
	 (loop for f in files
	       do
	       (setq m (a-assoc m
				(file-name-nondirectory f)
				f)))
	 (mylet [k (ido-completing-read
		    "select file: " (reverse (a-keys m)))
		   label (read-string "label: ")]
		(myapp--register-new-file label (a-get m k)))))

(defun myapp-edit-repository()
  (interactive)
  (find-file myapp--repository-file))

;; run

(defun myapp--run-jar (path)
  (shell-command (concat "java -jar " path)))

(defun myapp-run ()
  (interactive)
  (mylet [coll (myapp--parse)
	       k (ido-completing-read "select app: "
				      (a-keys coll))]
	 (myapp--run-jar (a-get coll k))))

(provide 'myapp)




