;; Registers and runs jar files. 

(setq myapp-data-file "/Users/naka/.emacs.d/mylib/myapp/data.xml")

(defun myapp--new-xml (label content)
  (format "<%s>%s</%s>" label content label))

(defun myapp--coll->string (coll)
  (mylet [s (with-temp-buffer
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
  "coll -> list of (label path)
Updates data file by writing the content of coll."
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

(defun myapp--register-impl (label path)
  (myapp--update-data-file (cons  (list label path) (myapp--parse-data-file))))

(defun myapp--valid-label-p (label)
  (not (-some (-lambda (s) (equal s label))
	      (-map '-first-item (myapp--parse-data-file)))))

(defun myapp-register()
  "Registers new a jar file in the current directory
 so that it can be executed from myapp-run."
  (interactive)
  (mylet [files (directory-files default-directory t (rx ".jar" ))
		coll-name (-map 'file-name-nondirectory files)
		choice (ido-completing-read
			"choose file: " coll-name)
		path (-first
		      (-lambda (s) (equal choice (file-name-nondirectory s)))
		      files)
		label (read-string "Enter label: ")]
	 (if (myapp--valid-label-p label)
	     (myapp--register-impl label path)
	   (error "%s already exists." label))))

(defun myapp-edit-repository()
  (interactive)
  (find-file myapp--repository-file))

;; delete

(defun myapp-delete-jar ()
  (interactive)
  (mylet [cur-coll (myapp--parse-data-file)
		   ret (ido-completing-read "choose: " (-map '-first-item cur-coll))
		   coll (-filter
			 (-lambda ((label path)) (not (equal label ret)))
			 cur-coll)]
	 (myapp--update-data-file coll)
	 (message "%s was deleted." ret)))

;; run

(defun myapp--run-jar (path)
  (shell-command (concat "java -jar " path)))

(defun myapp-run ()
  (interactive)
  (mylet [coll (myapp--parse-data-file)
	       k (ido-completing-read "select app: " (-map '-first-item coll))
	       (_ path) (-first (-lambda ((label path)) (equal label k)) coll)]
	 (myapp--run-jar path)))

(provide 'myapp)
