;;; init --- Andrew Schwartzmeyer's Emacs init file
;;; Commentary:
;; See readme.

;;; Code:
(customize-set-variable 'gc-cons-threshold (* 10 1024 1024))

;; Default to UTF-8 early as this file uses Unicode symbols.
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(setq-default buffer-file-coding-system 'utf-8)

;; used for deprecated functions
(defun call-if-fbound (function &rest args)
  "Call FUNCTION with optional ARGS, only if it is `fbound'."
  "Return t if it is fbound and called without error, and nil otherwise."
  (when (fboundp function) (apply function args) t))

;;; Package:
(require 'package)
(customize-set-variable
 'package-archives
 '(("melpa" . "https://melpa.org/packages/")
   ("gnu" . "https://elpa.gnu.org/packages/")
   ("org" . "https://orgmode.org/elpa/")))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(customize-set-variable 'use-package-always-ensure t)

(eval-when-compile
  (require 'use-package))

(use-package delight)
(use-package bind-key)
(use-package dash)
(use-package f)

(push "~/.emacs.d/lisp" load-path)

;; Save data files consistently:
;; - `save-place-file'
;; - `undo-tree-history-directory-alist'
;; - `backup-directory-alist'
;; - etc.
(use-package no-littering)

(customize-set-variable
 'custom-file (no-littering-expand-var-file-name "custom.el"))

;; Auto-update packages.
(use-package auto-package-update
  :custom
  (auto-package-update-interval 1)
  (auto-package-update-prompt-before-update (not (getenv "CI")))
  (apu--last-update-day-filename
   (no-littering-expand-var-file-name "auto-update-package-last-update-day"))
  :config (auto-package-update-maybe))

;;; Platform:
(use-package linux
  :ensure nil
  :if (eq system-type 'gnu/linux))

(use-package osx
  :ensure nil
  :if (eq system-type 'darwin))

(use-package windows
  :ensure nil
  :if (eq system-type 'windows-nt))

;;; Movement:
(use-package ace-window
  :bind ("M-o" . ace-window))

(use-package buffer-move
  :bind (("<C-S-up>" . buf-move-up)
         ("<C-S-down>" . buf-move-down)
         ("<C-S-left>" . buf-move-left)
         ("<C-S-right>" . buf-move-right)))

(use-package expand-region
  :bind ("C-=" . er/expand-region))

;;; Version control:
(use-package vc-hooks
  :ensure nil
  :custom (vc-follow-symlinks t))

(use-package magit
  :bind ("C-c g" . magit-status)
  :commands (magit-status projectile-vc)
  :custom (magit-completing-read-function 'ivy-completing-read))

(use-package git-commit
  :config (global-git-commit-mode))

(use-package git-gutter
  :delight
  :config (global-git-gutter-mode))

;;; Interface:
(use-package avy
  :bind (("C-'" . #'avy-goto-char)
         ("M-g f" . #'avy-goto-line)))

;; provides sorting for `counsel-M-x'
(use-package smex)

(use-package mb-depth
  :ensure nil
  :custom
  (enable-recursive-minibuffers
   t "Enables using `swiper-query-replace' from `swiper' via `M-q'.")
  :config (minibuffer-depth-indicate-mode))

(use-package counsel
  :after smex
  :delight
  :bind
  ;; note that counsel-mode rebinds most commands
  (("C-s" . counsel-grep-or-swiper)
   ("C-x L" . counsel-locate)
   ("C-c k" . counsel-rg)
   ("C-c i" . counsel-imenu)
   ("C-h L" . counsel-find-library))
  :custom
  (counsel-find-file-at-point t)
  (counsel-find-file-ignore-regexp "\\.DS_Store\\|.git")
  (counsel-grep-base-command
   "rg -i -M 120 --no-heading --line-number --color never '%s' %s")
  :config (counsel-mode))

;; provides sorting for ivy
(use-package flx)

;; used with `C-o' in ivy
(use-package hydra)

(use-package ivy
  :after flx
  :delight
  :bind ("C-c C-r" . ivy-resume)
  :custom
  (ivy-re-builders-alist
   '(;; Use `flx'-like matching. See: https://oremacs.com/2016/01/06/ivy-flx/
     (counsel-M-x . ivy--regex-fuzzy)
     ;; Use regex-plus but without ordering for files.
     (t . ivy--regex-ignore-order)))
  (ivy-use-virtual-buffers
   t "Add `recentf-mode' and bookmarks to `ivy-switch-buffer'.")
  (ivy-use-selectable-prompt t "Press `C-p' to use input as-is.")
  (ivy-initial-inputs-alist nil "Don't start with '^'.")
  :init (ivy-mode))

(use-package ivy-hydra
  :after (ivy hydra))

(use-package which-key
  :delight
  :config (which-key-mode))

;;; Navigation:
(use-package projectile
  :delight '(:eval (concat " " (projectile-project-name)))
  :custom
  (projectile-enable-caching t)
  (projectile-completion-system 'ivy)
  (projectile-indexing-method 'alien "Disable native indexing on Windows.")
  :config (projectile-mode))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

;;; Formatting:
(customize-set-variable 'indent-tabs-mode nil)
(customize-set-variable 'sentence-end-double-space nil)

(use-package dtrt-indent
  :delight
  :custom (dtrt-indent-min-quality 60)
  :config
  (add-to-list
   'dtrt-indent-hook-mapping-list
   '(powershell-mode c/c++/java powershell-indent))
  (dtrt-indent-global-mode))

(use-package aggressive-indent
  :hook (emacs-lisp-mode . aggressive-indent-mode))

(use-package adaptive-wrap
  :config (adaptive-wrap-prefix-mode))

(use-package whitespace
  :commands whitespace-mode)

(use-package ws-butler
  :delight
  :config (ws-butler-global-mode))

;;; Editing:
(use-package autorevert
  :ensure nil
  :delight auto-revert-mode
  :config (global-auto-revert-mode))

(use-package editorconfig
  :config (editorconfig-mode))

(use-package saveplace
  :config
  (or (call-if-fbound 'save-place-mode)
      (call-if-fbound 'save-place)))

(use-package smartparens
  :config
  (require 'smartparens-config)
  (smartparens-global-mode))

(use-package undo-tree
  :delight
  :custom (undo-tree-auto-save-history t)
  :config (global-undo-tree-mode))

(use-package unfill
  :commands (unfill-region unfill-paragraph unfill-toggle))

;;; Completion / syntax / tags:
(use-package company
  :delight
  :bind ("M-/" . company-complete)
  :config (global-company-mode))

(use-package company-statistics
  :after company
  :config (company-statistics-mode))

(use-package flycheck
  :config (global-flycheck-mode))

;; options include irony, cquery, rtags, ggtags, and ycmd
(use-package lsp-mode)

(use-package lsp-ui
  :after lsp-mode
  :hook (lsp-mode . lsp-ui-mode))

(use-package cquery
  :commands lsp-cquery-enable
  :hook (c-mode-common .  lsp-cquery-enable)
  :custom
  (cquery-executable (no-littering-expand-var-file-name
                      "cquery/build/release/bin/cquery"))
  (cquery-extra-init-params '(:completion (:detailedLabel t))))

(use-package company-lsp
  :after (cquery company)
  :custom (company-lsp-enable-recompletion t)
  :config (add-to-list 'company-backends 'company-lsp))

(use-package ivy-xref
  :after ivy
  :custom (xref-show-xrefs-function #'ivy-xref-show-xrefs))

(use-package flyspell
  ;; Disable on Windows because `aspell' 0.6+ isn't available.
  :if (not (eq system-type 'windows-nt))
  :delight
  :hook ((text-mode . flyspell-mode)
         (prog-mode . flyspell-prog-mode))
  :custom
  (ispell-program-name "aspell")
  (ispell-extra-args '("--sug-mode=ultra")))

(use-package flyspell-correct-ivy
  :after (flyspell ivy))

(use-package auto-correct
  :delight
  :hook (flyspell-mode . auto-correct-mode))

;;; Language modes:
(add-to-list 'auto-mode-alist '("\\.ino\\'" . c-mode))
(add-to-list 'auto-mode-alist '("\\.vcsh\\'" . conf-mode))
(add-to-list 'auto-mode-alist '("\\.zsh\\'" . sh-mode))
(add-to-list 'magic-mode-alist '(";;; " . emacs-lisp-mode))

(use-package cmake-mode
  :mode ("CMakeLists\\.txt\\'" "\\.cmake\\'"))

(use-package csharp-mode
  :mode "\\.cs$"
  :custom (csharp-want-imenu nil))

(use-package dockerfile-mode
  :mode "Dockerfile.*\\'")

(use-package fish-mode
  :mode ("\\.fish\\'" "/fish_funced\\..*\\'")
  :interpreter "fish")

(use-package gitattributes-mode
  :mode ("/\\.gitattributes\\'"
         "/info/attributes\\'"
         "/git/attributes\\'"))

(use-package gitconfig-mode
  :mode ("/\\.gitconfig\\'"
         "/\\.git/config\\'"
         "/modules/.*/config\\'"
         "/git/config\\'"
         "/\\.gitmodules\\'"
         "/etc/gitconfig\\'"))

(use-package gitignore-mode
  :mode ("/\\.gitignore\\'"
         "/info/exclude\\'"
         "/git/ignore\\'"))

(use-package json-mode
  :mode ("\\.json$" "\\.jsonld$"))

(use-package markdown-mode
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :custom (markdown-command "multimarkdown"))

(use-package nginx-mode
  :mode ("nginx\\.conf\\'" "/nginx/.+\\.conf\\'"))

(use-package powershell
  :mode ("\\.ps[dm]?1\\'" . powershell-mode))

(use-package protobuf-mode
  :mode "\\.proto\\'")

(use-package puppet-mode
  :mode "\\.pp\\'")

(use-package ruby-mode
  :mode "\\.\\(?:cap\\|gemspec\\|irbrc\\|gemrc\\|rake\\|rb\\|ru\\|thor\\)\\'")

(use-package rust-mode
  :mode "\\.rs\\'"
  :custom (rust-format-on-save t))

(use-package flycheck-rust
  :after (rust-mode flycheck)
  :hook (flycheck-mode . flycheck-rust-setup))

(use-package ssh-config-mode
  :mode (("/\\.ssh/config\\'" . ssh-config-mode)
         ("/sshd?_config\\'" . ssh-config-mode)
         ("/known_hosts\\'" . ssh-known-hosts-mode)
         ("/authorized_keys2?\\'" . ssh-authorized-keys-mode)))

(use-package yaml-mode
  :mode "\\.ya?ml\'")

;;; Tools:
(use-package clang-format
  :after cc-mode
  ;; Does not use `:bind' in order to not delay loading `clang-format' indefinitely.
  :config (bind-key "C-M-\\" 'clang-format-region c-mode-base-map))

(use-package compile
  :ensure nil
  :bind (("C-c c" . compile)
         ("M-O" . show-compilation))
  :custom
  (compilation-ask-about-save nil)
  (compilation-scroll-output t)
  (compilation-always-kill t))

(use-package demangle-mode
  :commands demangle-mode)

(use-package ibuffer
  :bind ("C-x C-b" . ibuffer))

(use-package ibuffer-vc
  :after ibuffer)

(use-package org
  :ensure org-plus-contrib
  :mode (("\\.org\\'" . org-mode) ("[0-9]\\{8\\}\\'" . org-mode))
  :hook (org-mode . turn-on-auto-fill)
  :custom
  (org-startup-indented nil)
  (org-adapt-indentation nil)
  (org-latex-listings t)
  (org-pretty-entities t)
  (org-latex-custom-lang-environments '((C "lstlisting")))
  (org-entities-user '(("join" "\\Join" nil "&#9285;" "" "" "⋈")
                       ("reals" "\\mathbb{R}" t "&#8477;" "" "" "ℝ")
                       ("ints" "\\mathbb{Z}" t "&#8484;" "" "" "ℤ")
                       ("complex" "\\mathbb{C}" t "&#2102;" "" "" "ℂ")
                       ("models" "\\models" nil "&#8872;" "" "" "⊧")))
  (org-export-backends '(html beamer ascii latex md)))

(use-package re-builder
  :ensure nil
  :commands (re-builder regexp-builder)
  :custom (reb-re-syntax 'string))

(use-package restart-emacs
  :bind ("C-c Q" . restart-emacs))

(use-package tramp
  :ensure nil
  :custom
  (tramp-verbose 9)
  (tramp-default-method "ssh")
  (tramp-ssh-controlmaster-options
   (concat "-o ControlPath=/tmp/tramp.%%r@%%h:%%p "
           "-o ControlMaster=auto "
           "-o ControlPersist=no")))

(use-package yasnippet
  :delight
  :config (yas-global-mode))

(use-package yasnippet-snippets
  :after yasnippet)

;;; Appearance:
(if (display-graphic-p)
    (progn
      (tool-bar-mode 0)
      (scroll-bar-mode 0)))

(use-package solarized-theme
  :if (display-graphic-p)
  :custom (solarized-use-variable-pitch nil)
  :config (load-theme 'solarized-dark t))

(if (not (display-graphic-p))
    (load-theme 'tango-dark t))

(use-package hl-todo
  :config (global-hl-todo-mode))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package fortune-cookie
  :if (executable-find "fortune")
  :custom
  (fortune-cookie-fortune-args "-s")
  (fortune-cookie-cowsay-enable (executable-find "cowsay"))
  (fortune-cookie-cowsay-args "-f tux")
  :config (fortune-cookie-mode))

(use-package smooth-scroll
  :if (display-graphic-p)
  :delight
  :custom (smooth-scroll/vscroll-step-size 8)
  :config (smooth-scroll-mode))

(use-package uniquify
  :ensure nil
  :custom (uniquify-buffer-name-style 'forward))

;;; Emacs configuration:

;; Fix annoyances.
(customize-set-variable 'ring-bell-function 'ignore)
(customize-set-variable 'visible-bell t)
(customize-set-variable 'inhibit-startup-screen t)
(customize-set-variable 'load-prefer-newer t)
(defalias 'yes-or-no-p 'y-or-n-p)
(set-variable 'disabled-command-function nil)

;; Default to truncating lines.
(customize-set-variable 'truncate-lines t)

;; Simple is Emacs's built-in miscellaneous package.
(use-package simple
  :ensure nil
  :custom
  ;; Fix kill behavior.
  (save-interprogram-paste-before-kill t)
  (kill-do-not-save-duplicates t)
  (kill-whole-line t)
  :config (column-number-mode))

;; Pop repeatedly.
(customize-set-variable 'set-mark-command-repeat-pop t)

(use-package files
  :ensure nil
  :custom
  (require-final-newline t)
  (backup-by-copying t)
  (delete-old-versions t)
  (kept-new-versions 8)
  (kept-old-versions 4)
  (version-control t)
  (auto-save-file-name-transforms
   `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))
  (large-file-warning-threshold (* 20 1000 1000) "20 megabytes."))

(use-package recentf
  :ensure nil
  :custom (recentf-max-saved-items 256)
  :config (recentf-mode))

(use-package dired
  :ensure nil
  :commands dired
  :custom
  (dired-dwim-target t "Enable side-by-side `dired' buffer targets.")
  (dired-recursive-copies 'always "Better recursion in `dired'.")
  (dired-recursive-deletes 'top)
  (dired-listing-switches "-lahp"))

;; Enables undo/redo of windows configurations with 'C-c <left/right>'.
(winner-mode)

;; Start the Emacs daemon.
(server-start)

;;; provide init package
(provide 'init)

;;; init.el ends here
