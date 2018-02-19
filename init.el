;;; init --- Andrew Schwartzmeyer's Emacs init file
;;; Commentary:
;; See readme.

;;; Code:
(customize-set-variable 'gc-cons-threshold (* 10 1024 1024))

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

;;; Vim:
(use-package evil
  :hook (git-commit-mode . evil-insert-state)
  :custom
  (evil-want-C-u-scroll t)
  (evil-cross-lines t)
  (evil-disable-insert-state-bindings t)
  :config (evil-mode))

;; required by evil
(use-package goto-chg
  :commands (goto-last-change goto-last-change-reverse))

(use-package evil-args
  :after evil
  :bind (;; bind evil-args text objects
         :map evil-inner-text-objects-map
              ("a" . evil-inner-arg)
              :map evil-outer-text-objects-map
              ("a" . evil-outer-arg)

              ;; bind evil-forward/backward-args
              :map evil-normal-state-map
              ("L" . evil-forward-arg)
              ("H" . evil-backward-arg)
              ("L" . evil-forward-arg)
              ("H" . evil-backward-arg)

              ;; bind evil-jump-out-args
              :map evil-normal-state-map
              ("K" . evil-jump-out-args)))

(use-package evil-commentary
  :after evil
  :delight
  :config (evil-commentary-mode))

(use-package evil-escape
  :after evil
  :demand ;; because "jk" isn't in :bind
  :delight
  :bind ("C-c C-g" . evil-escape)
  :custom (evil-escape-key-sequence "jk")
  :config (evil-escape-mode))

;; press % to jump between tags
(use-package evil-matchit
  :after evil
  :config (global-evil-matchit-mode))

(use-package evil-numbers
  :after evil
  :bind (:map evil-normal-state-map
              ("C-c +" . evil-numbers/inc-at-pt)
              ("C-c -" . evil-numbers/dec-at-pt)
              :map evil-visual-state-map
              ("C-c +" . evil-numbers/inc-at-pt)
              ("C-c -" . evil-numbers/dec-at-pt)))

(use-package evil-surround
  :after evil
  :config (global-evil-surround-mode))

(use-package evil-visualstar
  :after evil
  :config (global-evil-visualstar-mode))

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

(use-package evil-magit
  :after (evil magit))

(use-package git-commit
  :config (global-git-commit-mode))

(use-package git-gutter
  :delight
  :config (global-git-gutter-mode))

;;; Interface:

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
   ("C-x l" . counsel-locate)
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
  :demand
  :after (flx hydra)
  :delight
  :bind ("C-c C-r" . ivy-resume)
  :custom
  (ivy-re-builders-alist
   '((t . ivy--regex-fuzzy))
   "Use `flx'-like matching. See: https://oremacs.com/2016/01/06/ivy-flx/")
  (ivy-use-virtual-buffers
   t "Add `recentf-mode' and bookmarks to `ivy-switch-buffer'.")
  (ivy-use-selectable-prompt t "Press `C-p' to use input as-is.")
  (ivy-initial-inputs-alist nil "Don't start with '^'.")
  :config
  (ivy-mode))

(use-package which-key
  :delight
  :config (which-key-mode))

(use-package buffer-move
  :commands (buf-move-up buf-move-down buf-move-left buf-move-right))

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
  :config (dtrt-indent-mode))

(use-package aggressive-indent
  :hook (emacs-lisp-mode . aggressive-indent-mode))

(use-package adaptive-wrap
  :config (adaptive-wrap-prefix-mode))

(use-package whitespace
  :commands whitespace-mode
  :custom
  (whitespace-style
   '(face tabs spaces newline empty trailing tab-mark newline-mark)))

(use-package ws-butler
  :delight
  :config (ws-butler-global-mode))

;;; Editing:
(use-package smartparens
  :config
  (require 'smartparens-config)
  (smartparens-global-mode)
  (smartparens-global-strict-mode))

(use-package evil-smartparens
  :delight
  :hook (smartparens-enabled . evil-smartparens-mode))

(use-package highlight-parentheses
  :delight
  :config (global-highlight-parentheses-mode))

(use-package hungry-delete
  :delight
  :config (global-hungry-delete-mode))

(use-package autorevert
  :ensure nil
  :delight auto-revert-mode
  :config (global-auto-revert-mode))

(use-package saveplace
  :custom (save-place-file (f-expand ".emacs-places" user-emacs-directory))
  :config (save-place-mode))

(use-package undo-tree
  :delight
  :custom
  (undo-tree-history-directory-alist
   `(("." . ,(f-expand "undo-tree" user-emacs-directory))))
  (undo-tree-auto-save-history t)
  :config (global-undo-tree-mode))

(use-package unfill
  :commands (unfill-region unfill-paragraph unfill-toggle))

;;; Completion / syntax / tags:
(use-package company
  :delight
  :config (global-company-mode))

(use-package company-statistics
  :after company
  :config (company-statistics-mode))

(use-package flycheck
  :delight
  :config (global-flycheck-mode))

;; options include irony, cquery, rtags, ggtags, and ycmd
(use-package lsp-mode)

(use-package cquery
  :after lsp-mode
  :hook (c++-mode . lsp-cquery-enable)
  :custom
  (cquery-executable (f-expand "cquery/build/release/bin/cquery" user-emacs-directory))
  (cquery-extra-init-params '(:enableComments 2 :cacheFormat "msgpack"))
  :config (require 'lsp-flycheck))

(use-package company-lsp
  :after (lsp-mode company)
  :config (push 'company-lsp company-backends))

(use-package ycmd
  :commands ycmd-mode
  :hook (ycmd-mode . ycmd-eldoc-setup)
  :config
  (let ((x (f-expand "ycmd/ycmd" user-emacs-directory)))
    (customize-set-variable
     'ycmd-server-command
     (if (eq system-type 'windows-nt)
         (list "python.exe" "-u" x)
       (list "python" x))))
  (require 'ycmd-eldoc))

(use-package company-ycmd
  :after (ycmd company)
  :config (company-ycmd-setup))

(use-package flycheck-ycmd
  :after (ycmd flycheck)
  :config (flycheck-ycmd-setup))

(use-package flyspell
  ;; Disable on Windows because `aspell' 0.6+ isn't available.
  :if (not (eq system-type 'windows-nt))
  :delight
  :hook ((text-mode . flyspell-mode)
         (prog-mode . flyspell-prog-mode))
  :bind (:map flyspell-mode-map
              ("C-;" . #'flyspell-correct-previous-word-generic))
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
  :config (setq csharp-want-imenu nil))

(use-package dockerfile-mode
  :mode "Dockerfile.*\\'")

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
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :config
  (setq markdown-command "multimarkdown")
  (evil-define-key 'normal markdown-mode-map
    (kbd "g d") 'markdown-jump
    (kbd "g x") 'markdown-follow-link-at-point))

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
  :config
  (use-package flycheck-rust)
  (setq rust-format-on-save t))

(use-package ssh-config-mode
  :mode (("/\\.ssh/config\\'" . ssh-config-mode)
         ("/sshd?_config\\'" . ssh-config-mode)
         ("/known_hosts\\'" . ssh-known-hosts-mode)
         ("/authorized_keys2?\\'" . ssh-authorized-keys-mode)))

(use-package yaml-mode
  :mode "\\.ya?ml\'")

;;; Tools:
(use-package clang-format
  :ensure nil
  :config (evil-define-key 'visual c++-mode-map "=" 'clang-format-region))

(setq compilation-ask-about-save nil
      compilation-scroll-output t
      compilation-always-kill t)

(use-package demangle-mode
  :commands demangle-mode)

(use-package ibuffer
  :bind ("C-x C-b" . ibuffer)
  :config (use-package ibuffer-vc))

(use-package org-plus-contrib
  :mode (("\\.org\\'" . org-mode) ("[0-9]\\{8\\}\\'" . org-mode))
  :config
  (use-package evil-org)
  (add-hook 'org-mode-hook 'turn-on-auto-fill)
  (setq org-startup-indented nil
        org-adapt-indentation nil)
  (setq org-latex-listings t
        org-pretty-entities t
        org-latex-custom-lang-environments '((C "lstlisting"))
        org-entities-user '(("join" "\\Join" nil "&#9285;" "" "" "⋈")
                            ("reals" "\\mathbb{R}" t "&#8477;" "" "" "ℝ")
                            ("ints" "\\mathbb{Z}" t "&#8484;" "" "" "ℤ")
                            ("complex" "\\mathbb{C}" t "&#2102;" "" "" "ℂ")
                            ("models" "\\models" nil "&#8872;" "" "" "⊧"))
        org-export-backends '(html beamer ascii latex md)))

(use-package restart-emacs
  :bind ("C-c Q" . restart-emacs))

(use-package tramp
  :config
  (setq tramp-verbose 9
        tramp-default-method "ssh"
        tramp-ssh-controlmaster-options
        (concat "-o ControlPath=/tmp/tramp.%%r@%%h:%%p "
                "-o ControlMaster=auto "
                "-o ControlPersist=no")))

;;; Appearance:
(if (display-graphic-p)
    (progn
      (tool-bar-mode 0)
      (scroll-bar-mode 0)))

(use-package solarized-theme
  :config
  (setq solarized-use-variable-pitch nil)
  (load-theme 'solarized-dark t))

(use-package hl-todo
  :config (global-hl-todo-mode))

(use-package fortune-cookie
  :config
  (setq fortune-cookie-fortune-args "-s"
        fortune-cookie-cowsay-enable t
        fortune-cookie-cowsay-args "-f tux")
  (fortune-cookie-mode))

(use-package smooth-scroll
  :if (display-graphic-p)
  :delight
  :config
  (setq smooth-scroll/vscroll-step-size 8)
  (smooth-scroll-mode))

(use-package uniquify
  :ensure nil
  :config (setq uniquify-buffer-name-style 'forward))

(setq ring-bell-function 'ignore
      visible-bell t)

(setq inhibit-startup-message t)

;;; Emacs configuration:
(setq next-screen-context-lines 4)
(defalias 'yes-or-no-p 'y-or-n-p)
(setq calendar-week-start-day 1) ; Monday
(winner-mode)
(setq disabled-command-function nil)
(setq-default truncate-lines t)
(setq save-interprogram-paste-before-kill t
      kill-do-not-save-duplicates t
      kill-whole-line t)
(setq-default set-mark-command-repeat-pop t)
(setq system-uses-terminfo nil)
(setq custom-file (f-expand "custom.el" user-emacs-directory))
(setq backup-by-copying t
      delete-old-versions t
      kept-new-versions 4
      kept-old-versions 2
      version-control t
      backup-directory-alist `(("." . ,(f-expand
                                        "backups" user-emacs-directory))))
(setq large-file-warning-threshold (* 20 1000 1000)) ; 20 MB
(setq recentf-max-saved-items 256
      recentf-max-menu-items 16)
(recentf-mode)
(use-package autorevert
  :ensure nil
  :delight auto-revert-mode
  :config (global-auto-revert-mode))
(setq dired-dwim-target t ; enable side-by-side dired buffer targets
      dired-recursive-copies 'always ; better recursion in dired
      dired-recursive-deletes 'top
      dired-listing-switches "-lahp")

;;; provide init package
(provide 'init)

;;; init.el ends here
