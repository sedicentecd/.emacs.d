;;; osx --- OS X specific configurations

;;; Commentary:
;;; Uses Source Code Pro font
;;; http://sourceforge.net/projects/sourcecodepro.adobe/

;;; Code:

;; pull in path
(use-package "exec-path-from-shell"
  :init
  (progn
    (exec-path-from-shell-copy-envs '("GPG_AGENT_INFO"))
    (exec-path-from-shell-initialize)))

;; set for shell-command-to-string on remote systems
(setq shell-file-name "/bin/zsh")
(setenv "SHELL" "/bin/zsh")
(setenv "TMPDIR" "/tmp")

;; setup tramp
(use-package tramp
  :init
  (progn
    (setq helm-tramp-verbose 9
	  tramp-verbose 9
	  tramp-ssh-controlmaster-options
	  "-o ControlPath=/tmp/tramp.%%r@%%h:%%p -o ControlMaster=auto -o ControlPersist=no")
    (add-to-list 'tramp-default-proxies-alist '("\\`.*\\(schwartzmeyer.com\\|cloudapp.net\\)\\'" "\\`root\\'" "/ssh:%h:"))))

;; add home info manuals
(add-to-list 'Info-additional-directory-list (expand-file-name "~/info"))
(add-to-list 'Info-additional-directory-list (expand-file-name "/Applications/Macaulay2-1.7/share/info"))

(use-package dash-at-point
  :bind ("C-c d" . dash-at-point))

;; Macaulay
(use-package M2
  :load-path "/Applications/Macaulay2-1.7/share/emacs/site-lisp"
  :commands (M2)
  :mode ("\\.m2\\'" . M2-mode))

;; frame size
(add-to-list 'default-frame-alist '(height . 48))
(add-to-list 'default-frame-alist '(width . 90))

;; delete by moving to trash
(setq delete-by-moving-to-trash t)

;; set font
(set-frame-font
 "-*-Source Code Pro-normal-normal-normal-*-*-*-*-*-m-0-iso10646-1" nil t)

;; font size
(set-face-attribute 'default nil :height 120)

;; open file's location in Finder
(defun finder ()
  "Opens file directory in Finder."
  (interactive)
  (let ((file (buffer-file-name)))
    (if file
        (shell-command
         (format "%s %s" (executable-find "open") (file-name-directory file)))
      (error "Buffer is not attached to any file"))))

;; mu4e
(use-package mu4e
  :commands mu4e
  :bind ("C-c m" . mu4e)
  :load-path "/usr/local/Cellar/mu/0.9.9.6/share/emacs/site-lisp/"
  :config
  (progn
    (setq mu4e-mu-binary (executable-find "mu")
	  mu4e-get-mail-command "offlineimap"
	  mu4e-update-interval 300
	  mu4e-maildir (expand-file-name "~/mail/personal")
	  mu4e-sent-folder "/Sent"
	  mu4e-drafts-folder "/Drafts"
	  mu4e-trash-folder "/Trash"
	  mu4e-refile-folder "/Archive")
    (add-hook 'mu4e-view-mode-hook 'visual-line-mode)))

;; org-journal
(use-package org-journal
  :mode ("[0-9]\\{8\\}\\'" . org-mode)
  :bind ("C-c j" . org-journal-new-entry)
  :config (setq org-journal-dir "~/Documents/personal/journal/"))

;; org agenda
(use-package org-agenda
  :bind ("C-c a" . org-agenda)
  :config (setq org-agenda-files '("~/.org")))

;;; provide OS X package
(provide 'osx)

;;; osx.el ends here
