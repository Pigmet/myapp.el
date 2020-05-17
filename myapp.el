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
  (mylet [re (rx bow (group-n 1  (+ alnum) eow )
		 (+ (or "\n" (+ blank)))
		 (group-n 2 (+ anything) ".jar"))
	     s (myapp--get-repository-content)
	     ret (a-alist)]
	 (loop for (_ k v) in (s-match-strings-all re s)
	       do (setq ret (a-assoc ret k v)))
	 ret))

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
