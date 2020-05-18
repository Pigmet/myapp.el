;; Registers and runs jar files. 

(setq myapp-data-file "/Users/naka/.emacs.d/mylib/myapp/data.xml")

(defun myapp--new-xml (label content)
  (format "<%s>%s</%s>" label content label))

(defun myapp--coll->string (coll)
  (mylet [s  (with-temp-buffer
	       (loop for (label path) in coll
		     do
		     (insert
		      (myapp--new-xml "file"
				      (concat 
				       (myapp--new-xml "label" label)
				       (myapp--new-xml "path" path)))))
	       (buffer-string))]
	 (myapp--new-xml "data" s)))

(defun myapp--update-data-file (coll)
  "coll -> list of (label path)"
  (with-temp-file myapp-data-file
    (insert (myapp--coll->string coll))))

;;(myapp--update-data-file '(("plot" "path1") ("crop" "path2")))

(defun myapp--parse-data-file()
  (->>  (with-temp-buffer
	  (insert-file-contents "/Users/naka/.emacs.d/mylib/myapp/data.xml")
	  (libxml-parse-xml-region (point-min) (point-max)))
	(-filter 'listp)
	(-filter (-lambda (x) (eq (-first-item x) 'file)))
	(-map  (-lambda ((_ _  a b)) (list (-last-item a) (-last-item b))))
	(-map (-lambda (coll) (-map 's-trim coll)))))

(defun myapp--register-new-file (label path))

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
