;;;; Package --- Emacs Initialization.
;;; Commentary:
;;
;; org-babel based configurations.
;;
;;; Code:

;; is packages managed by Nix?
(defconst *mg/package-managed-by-nix* t)

;; CHECK VERSION
(let ((minver 27))
  (unless (>= emacs-major-version minver)
    (error "Current Emacs is too old -- this config requires v%s or higher" minver)))

;;; INIT PACKAGE SYSTEM
(require 'package)

;; enable TLS for more security when fetching packages
(setq tls-checktrust t)

(if (and (not *mg/package-managed-by-nix*)
         (not package-archive-contents))
    (progn
      (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
      (package-initialize)
      (package-refresh-contents)
      (unless (package-installed-p 'use-package)
        (package-install 'use-package)))
  ;; package-archives is useless, because packages are managed by Nix.
  (setq package-archives '()))

(require 'use-package)

;; debug loading processes of packages imported by use-package
(setq use-package-verbose t)

;;; LOAD CONFIGURATIONS
(defun mg/config-load-org (filename)
  "Load config `FILENAME'."
  (let ((config-file (expand-file-name filename user-emacs-directory)))
    (if (file-exists-p config-file)
        (org-babel-load-file config-file)
      (message "[load config] skip %s" config-file))))

(mg/config-load-org "core.org")

(provide 'init)
;;; init.el ends here
