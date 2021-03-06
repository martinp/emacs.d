;;; init-package.el --- configure package management  -*- lexical-binding:t -*-
;;; Commentary:
;;; Code:

;; add melpa repo
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives
             '("nongnu" . "https://elpa.nongnu.org/nongnu/") t)
(when (< emacs-major-version 27)
  (package-initialize))

;; emacs and gnutls has recurring issues with tls 1.3
;; the original bug was supposedly fixed in 26.3, but resurfaced in 27.2 on
;; macos (https://emacsformacosx.com build)
;;
;; https://debbugs.gnu.org/cgi/bugreport.cgi?bug=34341
;; https://www.reddit.com/r/emacs/comments/mk0luk/does_anyone_know_how_to_diagnose_or_fix_emacs_not/
;;
;; disable tls 1.3 if supported by gnutls
(when (>= libgnutls-version 30603)
  (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3"))

(defun mpolden/require-package (package &optional min-version no-refresh)
  "Install given PACKAGE, optionally requiring MIN-VERSION.
If NO-REFRESH is non-nil, the available package lists will not be
re-downloaded in order to locate PACKAGE."
  (if (package-installed-p package min-version)
      t
    (if (or (assoc package package-archive-contents) no-refresh)
        (package-install package)
      (progn
        (package-refresh-contents)
        (require-package package min-version t)))))

(defun mpolden/require-packages (packages)
  "Install a list of PACKAGES."
  (mapcar (lambda (package) (mpolden/require-package package)) packages))

(defvar mpolden/inhibited-features nil "List of features that should not be loaded.")

(define-obsolete-variable-alias 'inhibited-packages 'mpolden/inhibited-features)
(define-obsolete-variable-alias 'mpolden/inhibited-packages 'mpolden/inhibited-features)

(defun mpolden/maybe-require (feature)
  "Load FEATURE if it's not inhibited."
  (unless (memq feature mpolden/inhibited-features)
    (require feature)))

;; install use-package and diminish
(mpolden/require-packages '(use-package diminish))

;; speed up loading of use-package and dependencies
(eval-when-compile
  (require 'use-package))
(require 'diminish)
(require 'bind-key)

(provide 'init-package)

;;; init-package.el ends here
