(setq package-enable-at-startup nil)

(defvar elpaca-installer-version 0.6)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                 ((zerop (call-process "git" nil buffer t "clone"
                                       (plist-get order :repo) repo)))
                 ((zerop (call-process "git" nil buffer t "checkout"
                                       (or (plist-get order :ref) "--"))))
                 (emacs (concat invocation-directory invocation-name))
                 ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                       "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                 ((require 'elpaca))
                 ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar

;; Set up the visible bell
(setq visible-bell t)

(set-face-attribute 'default nil :font "FiraCode Nerd Font Mono" :height 200)

;; (load-theme 'wombat)

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
  (setq elpaca-use-package-by-default t))

(setq evil-want-keybinding nil)

(elpaca-wait)

(use-package ef-themes
  :demand t
  :config
  (load-theme 'ef-elea-dark t))

(use-package vertico
  :elpaca (:files (:defaults "extensions/*"))
  :demand t
  :config
  (vertico-mode 1))

(use-package posframe
  :demand t)

(use-package vertico-posframe
  :after vertico
  :config
  (vertico-posframe-mode 1))

(use-package marginalia
  :after vertico
  :demand t
  :config
  (marginalia-mode 1))

(use-package orderless
  :after vertico
  :demand t
  :config
  (setq completion-styles '(orderless)))

(use-package avy
  :demand t)

(use-package evil
  :demand t
  :config
  (evil-mode 1))

(use-package evil-avy
  :after (avy evil)
  :demand t)

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))
(use-package evil-better-visual-line
  :after evil)

(use-package evil-escape
  :after evil)

(use-package evil-commentary
  :after evil
  :config
  (evil-commentary-mode 1))

;(use-package evil-fringe-mark
;  :after evil)

(use-package evil-leader
  :after evil)

(use-package evil-indent-plus
  :after evil)

(use-package evil-lispy
  :after evil
  :config
  (evil-lispy-mode 1))

(use-package evil-paredit
  :after evil
  :config
  (paredit-mode 1)
  (evil-paredit-mode 1))

(add-hook 'prog-mode-hook 'paredit-mode)
(add-hook 'prog-mode-hook 'evil-paredit-mode)

(use-package evil-textobj-tree-sitter
  :after evil)

(use-package evil-snipe
  :after evil)

(use-package evil-iedit-state
  :after evil)

(use-package evil-easymotion
  :after evil)

(use-package magit
  :demand t)

(use-package geiser
  :demand t)

(use-package geiser-guile
  :demand t)

;(ac-config-default)
;(use-package ac-geiser
;  :demand t)

;(ac-config-default)
;(require 'ac-geiser)
;(add-hook 'geiser-mode-hook 'ac-geiser-setup)
;(add-hook 'geiser-repl-mode-hook 'ac-geiser-setup)
;(eval-after-load "auto-complete"
;  (add-to-list 'ac-modes' geiser-repl-mode))

(use-package which-key
  :demand t
  :config
  (which-key-mode 1))

(use-package eat
  :demand t)

(use-package which-key-posframe
  :after which-key
  :demand t)

(use-package company
  :demand t
  :config
  (global-company-mode 1))

(use-package company-posframe
  :after company
  :demand t)

(use-package dired-posframe
  :demand t)

(use-package tree-sitter
  :demand t)

(use-package tree-sitter-langs
  :after tree-sitter
  :demand t)

(use-package treesit-auto
  :demand t
  :config
  (global-treesit-auto-mode 1))

(use-package consult
  :demand t)

(use-package consult-dir
  :after consult
  :demand t)

(use-package consult-company
  :after consult
  :demand t)

(use-package yasnippet
  :demand t
  :config
  (yas-global-mode 1))

(use-package lsp-bridge
  :after yasnippet
  :elpaca '(lsp-bridge :host github :repo "manateelazycat/lsp-bridge"
		       :files (:defaults "*.el" "*.py" "acm" "core" "langserver" "multiserver" "resources")
		       :build (:not compile))
  :config
  (global-lsp-bridge-mode))

(use-package flycheck
  :demand t
  :config
  (global-flycheck-mode))

(use-package eshell-toggle
  :demand t)

(use-package eshell-git-prompt
  :demand t)

(use-package doom-themes
  :demand t)

(use-package doom-modeline
  :demand t
  :config
  (doom-modeline-mode 1))

(use-package all-the-icons
  :demand t)

(use-package all-the-icons-nerd-fonts
  :demand t)

(use-package git-gutter
  :demand t)

(add-hook 'prog-mode-hook 'git-gutter-mode)
