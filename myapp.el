(defcustom myapp-list (a-alist) "list")

(defun myapp--add-to-list (&rest kvs)
  (loop for (k v) in (-partition 2 kvs)
	do
	(setq myapp-list (a-assoc myapp-list k v)))
  myapp-list)

(defun myapp--initialize-list ()
  (setq myapp-list (a-alist)))

(defun myapp--run-jar (path)
  (shell-command (concat "java -jar " path)))

(defun myapp-run ()
  (interactive)
  (mylet [k (ido-completing-read "select app: "
				 (a-keys myapp-list))]
	 (myapp--run-jar (a-get myapp-list k))))
