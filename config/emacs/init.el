;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Files and Directory I/O Setting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; reduce the frequency of garbage collection by making it happen on
;; each 50MB of allocated data (the default is on every 0.76MB)
(setq gc-cons-threshold 50000000)

;; warn when opening files bigger than 100MB
(setq large-file-warning-threshold 100000000)

(setq message-log-max 10000)

;; don't load outdated byte code
(setq load-prefer-newer t)

;; revert buffers automatically when underlying files are changed externally
(global-auto-revert-mode t)

(fset 'yes-or-no-p #'y-or-n-p)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; File Encoding Setting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(prefer-coding-system       'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

(defvar iso-transl-char-map nil)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; File Format Setting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; Opt out from the startup message in the echo area by simply disabling this
;; ridiculously bizarre thing entirely.
(fset 'display-startup-echo-area-message #'ignore)

;; nice scrolling
(setq scroll-margin 0
      scroll-conservatively 100000
      scroll-preserve-screen-position 1)

(setq ring-bell-function #'ignore
      inhibit-startup-screen t
      initial-scratch-message "")

;; mode line settings
(line-number-mode t)
(column-number-mode t)
(size-indication-mode t)

(blink-cursor-mode -1)

;; turn on highlight matching brackets when cursor is on one
(show-paren-mode 1)

;; Emacs modes typically provide a standard means to change the
;; indentation width -- eg. c-basic-offset: use that to adjust your
;; personal indentation width, while maintaining the style (and
;; meaning) of any files you load.
(setq-default indent-tabs-mode nil)   ;; don't use tabs to indent
(setq-default tab-width 4)            ;; but maintain correct appearance

;; Wrap lines at 80 characters
(setq-default fill-column 80)

;; overwrite selected region, including paste
(delete-selection-mode 1)

;; delete trailing whitespace when save
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Newline at end of file
(setq require-final-newline t)

;; enable upcase/downcase-region
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Others
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; quit Emacs directly even if there are running processes
(setq confirm-kill-processes nil)


;; on macOS, ls doesn't support the --dired option while on Linux it is supported.
(when (string= system-type "darwin")
  (defvar dired-use-ls-dired nil))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialize Package and Use-package
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(require 'package)
(setq package-enable-at-startup nil)
(setq package-check-signature nil)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/")
             '("gnu"   . "https://elpa.gnu.org/packages/"))

(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package)
  (setq use-package-verbose t))

(use-package auto-package-update
  :ensure t
  :config
  ;; delete the old version on updates.
  (setq auto-package-update-delete-old-versions t))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Require
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(require 'bind-key)
(require 'subr-x)
(require 'time-date)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; keybind
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; redo/undo
(global-set-key (kbd "C-z") 'undo)
(global-set-key (kbd "C-r") 'redo)

;; navigation word
(global-set-key (kbd "C-f") 'forward-word)
(global-set-key (kbd "C-d") 'backward-word)

;; delete word
;; fork from http://xahlee.info/emacs/emacs/emacs_kill-ring.html
(defun my-delete-word (arg)
  "Delete characters forward until encountering the end of a word.
  With argument, do this that many times.
  This command does not push text to `kill-ring'."
  (interactive "p")
  (delete-region
   (point)
   (progn
     (forward-word arg)
     (point))))

(defun my-backward-delete-word (arg)
  "Delete characters backward until encountering the beginning of a word.
  With argument, do this that many times.
  This command does not push text to `kill-ring'."
  (interactive "p")
  (my-delete-word (- arg)))

(global-set-key (kbd "<M-backspace>") 'my-backward-delete-word)
(global-set-key (kbd "<C-backspace>") 'my-backward-delete-word)

;; move to the beginning of the line
;; fork from https://emacsredux.com/blog/2013/05/22/smarter-navigation-to-the-beginning-of-a-line/
(defun smarter-move-beginning-of-line (arg)
  "Move point back to indentation of beginning of line.

  Move point to the first non-whitespace character on this line.
  If point is already there, move to the beginning of the line.
  Effectively toggle between the first non-whitespace character and
  the beginning of the line.

  If ARG is not nil or 1, move forward ARG - 1 lines first.
  If point reaches the beginning or end of the buffer, stop there."

  (interactive "^p")
  (setq arg (or arg 1))

  ;; Move lines first
  (when (/= arg 1)
    (let ((line-move-visual nil))
      (forward-line (1- arg))))

  (let ((orig-point (point)))
    (back-to-indentation)
    (when (= orig-point (point))
      (move-beginning-of-line 1))))

;; remap C-a to `smarter-move-beginning-of-line'
(global-set-key [remap move-beginning-of-line]
                'smarter-move-beginning-of-line)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cursor and Indent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; highlight the current line
(use-package hl-line
  :config
  (global-hl-line-mode +1))


;; Highlight cursor position in buffer
(use-package beacon
  :ensure t
  :init (beacon-mode 1)
  :config
  (setq beacon-push-mark 35)
  (setq beacon-color "#666600")
  :diminish beacon-mode)


(use-package multiple-cursors
  :ensure t
  :config
  (global-set-key (kbd "C->") 'mc/mark-next-like-this)
  (global-set-key (kbd "C-<") 'mc/mark-previous-like-this))


;; "C-=" <-> "C-- C-="
(use-package expand-region
  :ensure t
  :bind ("C-=" . er/expand-region))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General Package
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(use-package move-text
  :ensure t
  :config
  (move-text-default-bindings))


;; super-save auto-saves your buffers, when certain events happen
;; e.g. you switch between buffers, an Emacs frame loses focus, etc.
(use-package super-save
  :ensure t
  :config
  (super-save-mode +1))


;; Position/matches count for isearch
(use-package anzu
  :ensure t
  :bind
  (([remap query-replace] . anzu-query-replace)
   ([remap query-replace-regexp] . anzu-query-replace-regexp)
   :map isearch-mode-map
   ([remap isearch-query-replace] . anzu-isearch-query-replace)
   ([remap isearch-query-replace-regexp] . anzu-isearch-query-replace-regexp))
  :init (global-anzu-mode)
  :config (setq anzu-cons-mode-line-p nil))


(use-package which-key
  :ensure t
  :config
  (which-key-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Graphical User Interface
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(use-package zenburn-theme
  :ensure t
  :init (load-theme 'zenburn t))
(set-face-attribute 'default nil :height 160)


(use-package all-the-icons
  :ensure t
  :config
  (let ((font-dest (getenv "DOTFILES_FONT_DIR")))
    (unless (file-exists-p (concat font-dest "/all-the-icons.ttf"))
      (all-the-icons-install-fonts t))))


(use-package company
  :ensure t
  :config
  (setq company-idle-delay 0.1)
  (setq company-minimum-prefix-length 1)

  (global-company-mode t))


(use-package ivy
  :ensure t
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  (global-set-key (kbd "C-c C-r") 'ivy-resume))


(use-package counsel
  :ensure t
  :after ivy
  :config (counsel-mode))

(use-package highlight-indent-guides
  :ensure t
  :custom

  (highlight-indent-guides-method 'character)
  (highlight-indent-guides-auto-character-face-perc 60)

  :hook (sh-mode . highlight-indent-guides-mode))


(use-package swiper
  :ensure t
  :after ivy)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Git and Change Tracking
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; Highlight hunks in fringe
(use-package diff-hl
  :ensure t
  :defer t
  :init

  ;; Highlight changes to the current file in the fringe
  (global-diff-hl-mode +1)

  ;; Highlight changed files in the fringe of Dired
  (add-hook 'dired-mode-hook 'diff-hl-dired-mode)

  ;; Fall back to the display margin, if the fringe is unavailable
  (unless (display-graphic-p)
    (diff-hl-margin-mode))

  ;; Refresh diff-hl after Magit operations
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh))


(use-package undo-tree
  :ensure t
  :config
  ;; autosave the undo-tree history
  (setq undo-tree-history-directory-alist
        `((".*" . ,temporary-file-directory)))
  (setq undo-tree-auto-save-history t)
  (global-undo-tree-mode +1))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Coding Syntax
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; Choose wrap prefix automatically
(use-package adaptive-wrap
  :ensure t
  :defer t
  :init (add-hook 'visual-line-mode-hook #'adaptive-wrap-prefix-mode))


;; EditorConfig helps maintain consistent coding styles
;; for multiple developers working on the same project
;; across various editors and IDEs.
(use-package editorconfig
  :ensure t
  :config (editorconfig-mode 1))


(use-package smartparens
  :ensure t)


(use-package flycheck
  :ensure t
  :init (global-flycheck-mode)
  :config

  (global-set-key (kbd "C-c C-p") 'flycheck-previous-error)
  (global-set-key (kbd "C-c C-n") 'flycheck-next-error)
  (global-set-key (kbd "C-c C-l") 'flycheck-list-errors)

  (add-hook 'after-init-hook #'global-flycheck-mode))


(use-package lsp-mode
  :ensure t

  :commands (lsp lsp-deferred)

  :init
  (setq lsp-keymap-prefix "C-c l")
  (setq lsp-signature-auto-activate nil)

  :config
  (defvar lsp-diagnostic-package :none)
  (defvar lsp-prefer-flymake nil) ;; use flycheck, not flymake
  (lsp-enable-which-key-integration t))


(use-package lsp-ui
  :ensure t
  :hook (lsp-deferred . lsp-ui-mode)

  :init
  (setq lsp-ui-doc-enable t
        lsp-ui-doc-use-webkit nil
        lsp-ui-doc-show-with-cursor t
        lsp-ui-doc-delay 0.2
        lsp-ui-doc-include-signature t
        lsp-ui-doc-position 'top
        lsp-ui-doc-border (face-foreground 'default)
        lsp-ui-doc-show-with-mouse nil)

  (setq lsp-ui-sideline-enable t
        lsp-ui-sideline-ignore-duplicate t))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Go
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(use-package go-autocomplete
  :ensure t)


;; go mode
(use-package go-mode
  :ensure t
  :mode (("\\.go\\'" . go-mode))

  :hook ((go-mode . lsp-deferred)
         (go-mode . (lambda () (setq tab-width 4)))
         (go-mode . company-mode)
         (go-mode . smartparens-mode))

  :config

  ;; lsp
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t)

  ;; go imports
  (setq gofmt-command "goimports")
  (add-hook 'before-save-hook 'gofmt-before-save)

  ;; go code
  (require 'go-autocomplete)
  (require 'auto-complete-config)
  (setq ac-auto-start 1)
  (setq ac-auto-show-menu 0.5)

  ;; go def
  (global-set-key (kbd"C-c C-c") 'godef-jump)
  (global-set-key (kbd"C-c C-d") 'godef-jump-other-window))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Clojure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; (use-package clojure-mode
;;   :ensure t
;;   :mode (("\\.clj\\'" . clojure-mode)
;;          ("\\.edn\\'" . clojure-mode))
;;   :init
;;   (add-hook 'clojure-mode-hook #'linum-mode)
;;   (add-hook 'clojure-mode-hook #'subword-mode)
;;   (add-hook 'clojure-mode-hook #'smartparens-mode)
;;   (add-hook 'clojure-mode-hook #'eldoc-mode))


;; (use-package cider
;;   :ensure t
;;   :defer t
;;   :diminish subword-mode
;;   :config
;;   (defvar cider-prompt-save-file-on-load 'always-save)
;;   (setq cider-repl-display-in-current-window t
;;         cider-repl-use-clojure-font-lock t
;;         cider-font-lock-dynamically '(macro core function var)
;;         nrepl-hide-special-buffers t
;;         cider-overlays-use-font-lock t))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; python
;;
;; - dependencies
;;   - `pip3 install flake8 pylint`
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defun python-mode-config ()
  ((lambda ()
    (setq flycheck-flake8-maximum-line-length 160)
    (setq python-indent-offset 4))))

(add-hook 'python-mode-hook #'python-mode-config)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; html, css, js and ts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; https://stackoverflow.com/questions/137043/can-emacs-re-indent-a-big-blob-of-html-for-me
;; https://emacs.stackexchange.com/questions/5452/before-save-hook-for-cc-mode
(defun reformat-xml ()
  "Reformats xml to make it readable (respects current selection)."
  (interactive)
  (save-excursion
    (let ((beg (point-min))
          (end (point-max)))
      (if (and mark-active transient-mark-mode)
          (progn
            (setq beg (min (point) (mark)))
            (setq end (max (point) (mark))))
        (widen))
      (setq end (copy-marker end t))
      (goto-char beg)
      (while (re-search-forward ">\\s-*<" end t)
        (replace-match ">\n<" t t))
      (goto-char beg)
      (indent-region beg end nil))))

(defun nxml-mode-config ()
  (lsp-deferred)
  ((lambda () (add-hook 'before-save-hook #'reformat-xml nil 'local)))
  (smartparens-mode)
  (company-mode)
  (highlight-indent-guides-mode))

(add-hook 'nxml-mode-hook #'nxml-mode-config)
(add-to-list 'auto-mode-alist '("\\.html?\\'" . nxml-mode))


(use-package tide
  :ensure t
  :after (company flycheck)
  :hook (before-save . tide-format-before-save))


(use-package web-mode
  :ensure t
  :after (smartparens company)
  :hook ((web-mode . lsp-deferred)
         (web-mode . smartparens-mode)
         (web-mode . tide-setup)
         (web-mode . tide-hl-identifier-mode)
         (web-mode . company-mode))
  :mode (;; ("\\.html?\\'"  . web-mode)
         ;; ("\\.jsonc?\\'" . web-mode)
         ("\\.jsx\\'"    . web-mode)
         ("\\.tsx?\\'"   . web-mode))
  :config
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-code-indent-offset 2))


(use-package js2-mode
  :ensure t
  :after (smartparens company flycheck)
  :hook ((js2-mode . lsp-deferred)
         (js2-mode . smartparens-mode)
         (js2-mode . tide-setup)
         (js2-mode . eldoc-mode)
         (js2-mode . tide-hl-identifier-mode)
         (js2-mode . company-mode))
  :mode ("\\.js\\'" . js2-mode)
  :init
  (setq-default js-indent-level 2
                js2-basic-indent 2
                js2-auto-indent-p t
                js2-cleanup-whitespace t
                js2-enter-indents-newline t
                js2-indent-on-enter-key t
                js2-global-externs (list "window" "module" "require" "buster" "sinon" "assert" "refute"
                                         "setTimeout" "clearTimeout" "setInterval" "clearInterval"
                                         "location" "__dirname" "console" "JSON" "jQuery" "$"))
  (add-hook 'js2-mode-hook
            (lambda ()
              (push '("function" . ?ƒ) prettify-symbols-alist)))

  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (setq company-tooltip-align-annotations t))


(use-package json-mode
  :ensure t
  :mode "\\.jsonc?\\'"
  :init
  (add-hook 'json-mode-hook
            (lambda ()
              (make-local-variable 'js-indent-level)
              (setq js-indent-level 4))))


(use-package css-mode
  :ensure t
  :after (smartparens company)
  :hook ((css-mode . lsp-deferred)
         (css-mode . smartparens-mode)
         (css-mode . company-mode))

  :mode "\\.css\\'"
  :config
  (setq css-indent-offset 2))


(use-package scss-mode
  :ensure t
  :mode "\\.scss\\'")


(with-eval-after-load 'flycheck
  ;; (flycheck-add-mode 'html-tidy 'web-mode)
  (flycheck-add-mode 'css-csslint 'css-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; File mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; ;; clojure-mode
;; (add-to-list 'auto-mode-alist '("\\.clj\\'" . clojure-mode))
;; (add-to-list 'auto-mode-alist '("\\.edn\\'" . clojure-mode))


;; config mode
(add-to-list 'auto-mode-alist '("\\.gitconfig\\'" . config-mode))


;; ;; css-mode
;; (add-to-list 'auto-mode-alist '("\\.css\\'" . css-mode))


;; dockerfile-mode
(use-package dockerfile-mode
  :ensure t
  :mode ("Dockerfile\\'" . dockerfile-mode))


;; emacs-lisp-mode
(add-to-list 'auto-mode-alist '("\\.el\\.local\\'" . emacs-lisp-mode))


;; ;; go-mode
;; (add-to-list 'auto-mode-alist '("\\.go\\'" . go-mode))


;; ;; js2-mode
;; (add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))


;; ;; json-mode
;; (add-to-list 'auto-mode-alist '("\\.jsonc?\\'" . json-mode))


;; markdown-mode
(use-package markdown-mode
  :ensure t
  :mode ("\\.md$" . markdown-mode)
  :init (add-hook 'markdown-mode-hook 'auto-fill-mode))


;; nxml-mode (built-in)
;; (add-to-list 'auto-mode-alist '("\\.html?\\'" . nxml-mode))


;; python-mode (built-in)
;; (add-to-list 'auto-mode-alist '("\\.py?\\'" . python-mode))


;; ;; scss-mode
;; (add-to-list 'auto-mode-alist '("\\.scss\\'" . scss-mode))


;; shell mode
(add-to-list 'auto-mode-alist '("\\.sh\\'"                . sh-mode))
(add-to-list 'auto-mode-alist '("\\.bash\\'"              . sh-mode))
(add-to-list 'auto-mode-alist '("\\.zsh\\'"               . sh-mode))
(add-to-list 'auto-mode-alist '("\\.zshenv\\'"            . sh-mode))
(add-to-list 'auto-mode-alist '("\\.env\\'"               . sh-mode))


;; vimrc-mode
(use-package vimrc-mode
  :ensure t
  :mode ("\\.vimrc\\'" . vimrc-mode))

;; ;; web-mode
;; (add-to-list 'auto-mode-alist '("\\.jsx\\'"   . web-mode))
;; (add-to-list 'auto-mode-alist '("\\.tsx?\\'"  . web-mode))


;; yaml-mode
(use-package yaml-mode
  :ensure t
  :mode ("\\.ya?ml\\'" . yaml-mode))
