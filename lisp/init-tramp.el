(require 'tramp)

;; use ssh as transfer method
(setq tramp-default-method "ssh")

;; make sudo:remote-host work as expected
(add-to-list 'tramp-default-proxies-alist '(nil "\\`root\\'" "/ssh:%h:"))
(add-to-list 'tramp-default-proxies-alist
             '((regexp-quote (system-name)) nil nil))

;; workaround for long ControlPath on darwin
;; https://trac.macports.org/ticket/29794
(when (eq system-type 'darwin)
  (setq tramp-ssh-controlmaster-options
        "-o ControlPath=/tmp/%%r@%%h:%%p -o ControlMaster=auto -o ControlPersist=no"))

(defun sudo-prefix-p (prefix)
  "Return t if PREFIX is a sudo prefix."
  (or (string-equal prefix "/sudo") (string-equal prefix "/sudo:")))

(defun ssh-prefix-p (prefix)
  "Return t if PREFIX is a ssh prefix."
  (string-equal prefix "/ssh"))

(defun sudo-file-name (filename)
  "Return FILENAME with a sudo prefix.

If FILENAME already has a sudo prefix, do nothing. If FILENAME is
accessed over SSH, prefix it with \"/sudo:\". Otherwise, assume
FILENAME is a local path and prefix it with \"/sudo::\"."
  (let* ((splitname (split-string filename ":"))
         (prefix (car splitname))
         (ssh-p (ssh-prefix-p prefix))
         (sudo-p (sudo-prefix-p prefix)))
    (if sudo-p
        filename
      (let ((sudo-prefix (if ssh-p "/sudo" "/sudo:"))
            (components (if ssh-p (cdr splitname) splitname)))
        (mapconcat 'identity (cons sudo-prefix components) ":")))))

(defun sudo-find-file (&optional arg)
  "Find file and open it with sudo.
With a prefix ARG prompt edit currently visited file using sudo."
  (interactive "P")
  (if arg
      (find-alternate-file (sudo-file-name buffer-file-name))
    (find-file (sudo-file-name (ido-read-file-name "Find file with sudo: ")))))

(global-set-key (kbd "C-x +") 'sudo-find-file)
(global-set-key (kbd "C-x !") (lambda () (interactive) (sudo-find-file t)))

(provide 'init-tramp)
