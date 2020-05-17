;; parse repository

(setq myapp--repository-file "myapp-repository")

(defun myapp--get-repository-content ()
  (with-temp-buffer
    (insert-file-contents
     (concat default-directory myapp--repository-file))
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
  (interactive)
  (mylet [files (directory-files default-directory t (rx ".jar" eow))
		m (loop for f in files
			with ret = (a-alist)
			do
			(setq ret (a-assoc ret
					   (file-name-nondirectory f)
					   f))
			return ret)
		chosen-file (ido-completing-read
			     "select file: " (a-keys m))
		label (read-string "label: ")]
	 (myapp--register-new-file label chosen-file)))

;; demo

(defun myapp--run-jar (path)
  (shell-command (concat "java -jar " path)))

(defun myapp-run ()
  (interactive)
  (mylet [coll (myapp--parse)
	       k (ido-completing-read "select app: "
				      (a-keys coll))]
	 (myapp--run-jar (a-get coll k))))

;; add new-file 
(a-get myapp-list "pdfcrop")
