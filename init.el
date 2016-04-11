;;; init --- Andrew Schwartzmeyer's Emacs init file
;;; Commentary:
;; See readme.

;;; Code:

;;; package setup
(require 'package)
(setq load-prefer-newer t
      package-enable-at-startup nil
      package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("org" . "http://orgmode.org/elpa/")
        ("melpa" . "https://melpa.org/packages/")))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(setq use-package-verbose t
      use-package-always-ensure t)

(eval-when-compile
  (require 'use-package))

;; packages used in init
(use-package bind-key)
(use-package dash)
(use-package f)

;;; system specific packages
;; load Linux configuration
(use-package linux
  :ensure nil
  :load-path "lisp/"
  :if (eq system-type 'gnu/linux))

;; load OS X configurations
(use-package osx
  :ensure nil
  :load-path "lisp/"
  :if (eq system-type 'darwin))

;; load Windows configurations
(use-package windows
  :ensure nil
  :load-path "lisp/"
  :if (eq system-type 'windows-nt))

;;; load local settings
(use-package local
  :ensure nil
  :load-path "site-lisp/")

(use-package auto-compile
  :config
  (auto-compile-on-load-mode)
  (auto-compile-on-save-mode))

;;; files
;; backups
(setq backup-by-copying t
      delete-old-versions t
      kept-new-versions 4
      kept-old-versions 2
      version-control t
      backup-directory-alist `(("." . ,(f-expand
                                        "backups" user-emacs-directory))))
;; 100 MB
(setq large-file-warning-threshold (* 100 1000 1000))

;; recent files
(setq recentf-max-saved-items 256
      recentf-max-menu-items 16)
(recentf-mode)

;; set auto revert of buffers if file is changed externally
(global-auto-revert-mode)

;; symlink version-control follow
(setq vc-follow-symlinks t)

;; dired
(setq dired-dwim-target t ; enable side-by-side dired buffer targets
      dired-recursive-copies 'always ; better recursion in dired
      dired-recursive-deletes 'top
      dired-listing-switches "-lahp")

;; compilation
(setq compilation-ask-about-save nil
      compilation-always-kill t)

;;; bindings
;; evil
(use-package evil
  :defines evil-disable-insert-state-bindings
  :init
  (setq evil-want-C-u-scroll t
        evil-want-fine-undo 'no
        evil-cross-lines t
        evil-disable-insert-state-bindings t)
  (define-key Info-mode-map "g" nil)
  (evil-mode t)
  :config
  (add-hook 'git-commit-mode-hook 'evil-insert-state))

(use-package evil-anzu)

(use-package evil-commentary
  :diminish evil-commentary-mode
  :config (evil-commentary-mode))

(use-package evil-easymotion
  :config (evilem-default-keybindings "<SPC>"))

(use-package ediff
  :ensure nil
  :defer t
  :config (use-package evil-ediff))

(use-package evil-escape
  :diminish evil-escape-mode
  :config
  (global-set-key (kbd "C-g") 'evil-escape)
  (evil-escape-mode))

(use-package evil-matchit
  :config (global-evil-matchit-mode))

(use-package evil-snipe
  :init (evil-snipe-mode))

(use-package evil-surround
  :config (global-evil-surround-mode))

(use-package evil-visualstar
  :init (global-evil-visualstar-mode))

;; miscellaneous
(bind-key "C-c a" 'align-regexp)
(bind-key "C-c l" 'find-library)
(bind-key "C-c x" 'eval-region-or-buffer)
(bind-key "C-c q" 'auto-fill-mode)
(bind-key "C-c v" 'visual-line-mode)
(bind-key* "C-c m" 'man)
(bind-key* "C-c w" 'woman)

;;; navigation
;; Interactively Do Things
(ido-mode)
(setq ido-enable-flex-matching t
      ido-use-virtual-buffers t)

(use-package ido-grid-mode
  :config (ido-grid-mode))

(use-package flx-ido
  :init
  (flx-ido-mode)
  (setq flx-ido-use-faces nil))

(use-package ido-ubiquitous
  :config
  (setq ido-ubiquitous-allow-on-functional-collection t)
  (ido-ubiquitous-mode))

;; ibuffer
(use-package ibuffer
  :ensure nil
  :bind ("C-x C-b" . ibuffer))

(use-package ibuffer-vc
  :config
  (add-hook 'ibuffer-hook
            (lambda ()
              (ibuffer-vc-set-filter-groups-by-vc-root)
              (unless (eq ibuffer-sorting-mode 'alphabetic)
                (ibuffer-do-sort-by-alphabetic)))))
;; smex
(use-package smex
  :bind* (("M-x" . smex)
          ("M-X" . smex-major-mode-commands)
          ("C-c M-x" . execute-extended-command))
  :config (setq smex-history-length 64
                smex-prompt-string "|-/ "))

;;; appearance
(if (display-graphic-p)
    (progn
      (tool-bar-mode 0)
      (scroll-bar-mode 0)))

;; Solarized
;; https://github.com/sellout/emacs-color-theme-solarized/pull/187
(setq color-themes '())
(use-package color-theme-solarized
  :config
  (customize-set-variable 'frame-background-mode 'dark)
  (load-theme 'solarized t))

;; Powerline
(use-package powerline
  :config (powerline-center-evil-theme))

;; highlight changes
(use-package git-gutter
  :diminish git-gutter-mode
  :config (global-git-gutter-mode))

;;; behavior
;; smooth scrolling
(use-package smooth-scroll
  :if (display-graphic-p)
  :diminish smooth-scroll-mode
  :config
  (setq smooth-scroll/vscroll-step-size 8)
  (smooth-scroll-mode))

;; more context when scrolling
(setq next-screen-context-lines 4)

;; y/n for yes/no
(defalias 'yes-or-no-p 'y-or-n-p)

;; start week on Monday
(setq calendar-week-start-day 1)

;; window undo/redo
(winner-mode)

;; tabs are truly evil
(setq-default indent-tabs-mode nil)

;; sentences end with one space
(setq sentence-end-double-space nil)

;;; settings
;; enable all commands
(setq disabled-command-function nil)

;; default truncate lines
(setq-default truncate-lines t)

;; disable bell
(setq ring-bell-function 'ignore
      visible-bell t)

;; increase garbage collection threshold
(setq gc-cons-threshold (* 10 1024 1024))

;; inhibit startup message
(setq inhibit-startup-message t)

;; kill settings
(setq save-interprogram-paste-before-kill t
      kill-append-merge-undo t
      kill-do-not-save-duplicates t
      kill-whole-line t)

;; repeat mark pop
(setq-default set-mark-command-repeat-pop t)

;; set terminfo
(setq system-uses-terminfo nil)

;;; functions
(defun compile-init ()
  "Byte recompile user Emacs directory."
  (interactive)
  (byte-recompile-directory user-emacs-directory))

(defun eval-region-or-buffer ()
  "Evaluate the selection, or, if empty, the whole buffer."
  (interactive)
  (let ((debug-on-error t))
    (cond
     (mark-active
      (call-interactively 'eval-region)
      (setq deactivate-mark t))
     (t
      (eval-buffer)))))

(defun copy-buffer-file-path ()
  "Put current buffer's short path into the kill ring."
  (interactive)
  (when (buffer-file-name)
    (kill-new (f-short (buffer-file-name)))))

(defun copy-buffer-file-name ()
  "Put current buffer's base name into the kill ring."
  (interactive)
  (when (buffer-file-name)
    (kill-new (f-filename (buffer-file-name)))))

;;; extensions
;; adaptive word wrapping
(use-package adaptive-wrap
  :config (adaptive-wrap-prefix-mode))

;; ag - the silver searcher
(use-package ag
  :commands (ag ag-files ag-regexp ag-project ag-dired)
  :config (setq ag-highlight-search t
                ag-reuse-buffers t))

;; browse kill ring
(use-package browse-kill-ring
  :bind ("M-y" . browse-kill-ring))

;; company "complete anything"
(use-package company
  :init (global-company-mode)
  :diminish company-mode
  :commands (company-mode global-company-mode)
  :bind ("<backtab>" . company-complete)
  :config
  (use-package company-c-headers)
  (use-package company-flx
    :config (with-eval-after-load 'company
              (company-flx-mode)))
  (push '(company-clang
          :with company-semantic
          :with company-yasnippet
          :with company-c-headers)
        company-backends)
  (setq company-global-modes '(not gud-mode)))

;; automatic demangling
(use-package demangle-mode
  :commands demangle-mode)

;; dtrt
(use-package dtrt-indent
  :load-path "site-lisp/dtrt-indent"
  :config
  (dtrt-indent-mode)
  (setq dtrt-indent-min-quality 60
        dtrt-indent-verbosity 3))

;; electric spacing
(use-package electric-spacing
  :commands electric-spacing-mode)

;; flycheck
(use-package flycheck
  :diminish flycheck-mode
  :init (global-flycheck-mode))

;; flyspell - use aspell instead of ispell
(use-package flyspell
  :commands (flyspell-mode flyspell-prog-mode)
  :config (setq ispell-program-name (executable-find "aspell")
                ispell-extra-args '("--sug-mode=ultra")))

;; fortune
(use-package fortune-cookie
  :config
  (setq fortune-cookie-fortune-args "-s"
        fortune-cookie-cowsay-args "-f tux")
  (fortune-cookie-mode))

;; ggtags
(use-package ggtags
  :commands ggtags-mode
  :diminish ggtags-mode
  :init
  (evil-define-key 'normal ggtags-mode-map (kbd "g d") 'ggtags-find-tag-dwim))

;; magit
(use-package magit
  :commands (magit-status projectile-vc)
  :config
  (use-package evil-magit)
  (add-to-list 'magit-log-arguments "--no-abbrev-commit")
  (setq magit-popup-use-prefix-argument 'default
        magit-completing-read-function 'magit-ido-completing-read))

(global-git-commit-mode)

;; popwin
(use-package popwin
  :config
  (popwin-mode)
  ;; cannot use :bind for keymap
  (global-set-key (kbd "C-z") popwin:keymap))

;; fix https://github.com/bbatsov/projectile/issues/837
(setq grep-find-ignored-files nil
      grep-find-ignored-directories nil)

;; projectile
(use-package projectile
  :diminish projectile-mode
  :bind-keymap ("M-[" . projectile-command-map)
  :config
  (setq projectile-enable-caching t
        projectile-git-submodule-command nil)
  (projectile-global-mode))

;; regex tool
(use-package regex-tool
  :commands (regex-tool))

;; save kill ring
(use-package savekill)

;; saveplace
(use-package saveplace
  :config
  (setq-default save-place t
                save-place-file (f-expand "saved-places" user-emacs-directory)))
;; scratch
(use-package scratch
  :commands (scratch))

;; slime
(use-package sly
  :commands (sly)
  :config (setq inferior-lisp-program (executable-find "sbcl")))

;; activate smartparens
(use-package smartparens
  :diminish smartparens-mode
  :init
  (use-package evil-smartparens
    :load-path "site-lisp/evil-smartparens"
    :diminish evil-smartparens-mode
    :config (add-hook 'smartparens-enabled-hook #'evil-smartparens-mode))
  (require 'smartparens-config)
  (smartparens-global-mode)
  (show-smartparens-global-mode)
  (smartparens-global-strict-mode))

;; tramp
(use-package tramp
  :config
  (setq tramp-verbose 9
        tramp-default-method "ssh"
        tramp-ssh-controlmaster-options
        (concat "-o ControlPath=/tmp/tramp.%%r@%%h:%%p "
                "-o ControlMaster=auto "
                "-o ControlPersist=no")))

;; try
(use-package try
  :commands try)

;; undo-tree
(use-package undo-tree
  :diminish undo-tree-mode
  :config
  (global-undo-tree-mode)
  (setq undo-tree-history-directory-alist
        `(("." . ,(f-expand "undo-tree" user-emacs-directory)))
        undo-tree-auto-save-history t))

;; unfill autofill
(use-package unfill
  :commands (unfill-region unfill-paragraph toggle-fill-unfill))

;; uniquify
(use-package uniquify
  :ensure nil
  :config (setq uniquify-buffer-name-style 'forward))

;; setup virtualenvwrapper
(use-package virtualenvwrapper
  :commands (venv-workon))

;; which-key
(use-package which-key
  :diminish which-key-mode
  :config (which-key-mode))

;; whitespace
(use-package whitespace
  :commands (whitespace-mode)
  :config
  (setq whitespace-style '(face tabs spaces newline empty
                                trailing tab-mark newline-mark)))

(use-package whitespace-cleanup-mode
  :diminish whitespace-cleanup-mode
  :init (global-whitespace-cleanup-mode))

;; yasnippet
(use-package yasnippet
  :commands (yas-expand yas-insert-snippet)
  :config
  (use-package java-snippets)
  (yas-minor-mode))

;;; syntax support
;; mode mappings
(add-to-list 'auto-mode-alist '("\\.ino\\'" . c-mode))
(add-to-list 'auto-mode-alist '("\\.vcsh\\'" . conf-mode))
(add-to-list 'auto-mode-alist '("\\.zsh\\'" . sh-mode))
(add-to-list 'magic-mode-alist '(";;; " . emacs-lisp-mode))

;; bison
(use-package bison-mode
  :mode ("\\.y\\'" "\\.l\\'"))

;; CMake
(use-package cmake-mode
  :mode ("CMakeLists\\.txt\\'" "\\.cmake\\'"))

;; crontab
(use-package crontab-mode
  :mode "\\.cron\\(tab\\)?\\'")

;; C styles
(c-add-style "work"
             '("bsd"
               (c-basic-offset . 4)
               (c-offsets-alist . ((arglist-intro . +)))))

(add-to-list 'c-default-style '(c-mode . "work"))
(add-to-list 'c-default-style '(c++-mode . "work"))
(add-to-list 'c-default-style '(csharp-mode . "c#"))

(defun work-style ()
  (interactive)
  (ggtags-mode)
  (set-fill-column 90))

;; C#
(use-package csharp-mode
  :mode "\\.cs$"
  :config
  (setq csharp-want-imenu nil)
  (add-hook 'csharp-mode-hook 'work-style))

;; docker
(use-package docker
  :commands docker-mode)

(use-package dockerfile-mode
  :mode "Dockerfile.*\\'")

;; git modes
(use-package gitattributes-mode
  :disabled t)
(use-package gitconfig-mode
  :mode ("/\\.gitconfig\\'" "/\\.git/config\\'" "/git/config\\'" "/\\.gitmodules\\'"))
(use-package gitignore-mode
  :mode ("/\\.gitignore\\'" "/\\.git/info/exclude\\'" "/git/ignore\\'"))

;; gnuplot
(use-package gnuplot
  :commands (gnuplot-mode gnuplot-make-buffer))

;; handlebars
(use-package handlebars-mode
  :mode ("\\.handlebars$" "\\.hbs$"))

;; haskell
(use-package haskell-mode
  :mode "\\.\\(?:[gh]s\\|hi\\)\\'"
  :interpreter ("runghc" "runhaskell"))

;; json
(use-package json-mode
  :mode "\\.json$"
  :config (setq js-indent-level 4))

;; ledger
(use-package ledger-mode
  :mode "\\.ledger\\'"
  :config
  (define-key ledger-mode-map (kbd "C-c c") 'ledger-mode-clean-buffer)
  (setq ledger-post-amount-alignment-at :decimal
        ledger-post-amount-alignment-column 49
        ledger-clear-whole-transactions t)
  (use-package flycheck-ledger))

;; less-css
(use-package less-css-mode
  :mode "\\.less\\'")

;; markdown
(use-package markdown-mode
  :mode ("\\.markdown\\'" "\\.mk?d\\'" "\\.text\\'")
  :init
  (evil-define-key 'normal markdown-mode-map
    (kbd "g d") 'markdown-jump
    (kbd "g x") 'markdown-follow-link-at-point))

;; matlab
(use-package matlab-mode
  :mode "\\.m$")

;; nginx
(use-package nginx-mode
  :mode ("nginx.conf$" "/etc/nginx/.*"))

;; org mode extensions
(use-package org-plus-contrib
  :mode (("\\.org\\'" . org-mode) ("[0-9]\\{8\\}\\'" . org-mode))
  :init
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t) (gnuplot . t) (C . t) (emacs-lisp . t) (haskell . t)
     (latex . t) (ledger . t) (python . t) (ruby . t) (sh . t)))
  (evil-define-key 'normal org-mode-map (kbd "g x") 'org-open-at-point)
  :config
  (use-package evil-org)
  (use-package org-journal
    :commands (org-journal-new-entry))
  (use-package org-pomodoro
    :commands (org-pomodoro))
  (add-hook 'org-mode-hook 'turn-on-auto-fill)
  (setq org-latex-listings t
        org-pretty-entities t
        org-completion-use-ido t
        org-latex-custom-lang-environments '((C "lstlisting"))
        org-entities-user '(("join" "\\Join" nil "&#9285;" "" "" "⋈")
                            ("reals" "\\mathbb{R}" t "&#8477;" "" "" "ℝ")
                            ("ints" "\\mathbb{Z}" t "&#8484;" "" "" "ℤ")
                            ("complex" "\\mathbb{C}" t "&#2102;" "" "" "ℂ")
                            ("models" "\\models" nil "&#8872;" "" "" "⊧"))
        org-export-backends '(html beamer ascii latex md)))

;; pkgbuild
(use-package pkgbuild-mode
  :mode "/PKGBUILD\\'")

;; powershell
(use-package powershell
  :mode ("\\.ps[dm]?1\\'" . powershell-mode)
  :config (add-hook 'powershell-mode-hook 'work-style))

;; processing
(use-package processing-mode
  :mode "\\.pde$"
  :config (use-package processing-snippets))

;; puppet
(use-package puppet-mode
  :mode "\\.pp\\'")

;; ruby
(use-package ruby-mode)

;; rust
(use-package rust-mode
  :mode "\\.rs\\'"
  :config (use-package flycheck-rust))

;; ssh-config
(use-package ssh-config-mode
  :mode ((".ssh/config\\'"       . ssh-config-mode)
         ("sshd?_config\\'"      . ssh-config-mode)
         ("known_hosts\\'"       . ssh-known-hosts-mode)
         ("authorized_keys2?\\'" . ssh-authorized-keys-mode)))

;; toml
(use-package toml-mode
  :mode "\\.toml$")

;; yaml
(use-package yaml-mode
  :mode "\\.ya?ml\'")

;; znc - depends on local
(use-package znc
  :if (bound-and-true-p znc-password)
  :commands znc-erc
  :config
  (setq znc-servers
        `(("schwartzmeyer.com" .
           (46728 t ((freenode . ("andrew/freenode" ,znc-password))))))))

;;; provide init package
(provide 'init)

;;; init.el ends here
