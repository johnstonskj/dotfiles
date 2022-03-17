;;; -------------------------------------------------------------------------
;;; Personal init file.
;;; -------------------------------------------------------------------------

;; --------------------------------------------------------------------------
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(color-theme-is-global t)
 '(custom-enabled-themes '(sanityinc-solarized-light))
 '(custom-safe-themes
   '("4cf3221feff536e2b3385209e9b9dc4c2e0818a69a1cdb4b522756bcdf4e00a4" default))
 '(dir-treeview-show-in-side-window t)
 '(echo-keystrokes 0.5)
 '(fill-column 78)
 '(github-notifier-token " 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")
 '(indent-tabs-mode nil)
 '(indicate-empty-lines t)
 '(inhibit-startup-screen t)
 '(ns-alternate-modifier 'meta)
 '(ns-command-modifier 'super)
 '(ns-right-command-modifier 'super)
 '(olivetti-body-width 82)
 '(package-selected-packages
   '(project-explorer diff-hl magit-lfs magit-todos hl-todo forge org-sidebar osx-org-clock-menubar undo-tree company-web focus org-modern easy-jekyll dashboard-project-status dashboard-hackernews dashboard all-the-icons-dired all-the-icons-completion all-the-icons ## yasnippet-snippets yasnippet projectile marginalia selectrum-prescient selectrum dap-mode lsp-ui dir-treeview dired-sidebar github-pullrequest github-explorer git-link magithub magit-filenotify magit github-review github-notifier git-blamed git-attr scribble-mode smog latex-extra latex-math-preview latex-preview-pane lsp-mode flycheck-rust rustic rust-playground rust-auto-use wakatime-mode company rust-mode cargo-mode racket-mode))
 '(pixel-scroll-precision-mode 1)
 '(ring-bell-function 'ignore)
 '(save-place t)
 '(scroll-bar-mode nil)
 '(scroll-margin 1)
 '(scroll-step 1)
 '(sentence-end-double-space nil)
 '(set-language-environment "UTF-8")
 '(tab-always-indent 'complete)
 '(tab-width 4)
 '(tool-bar-mode nil)
 '(wakatime-cli-path "/usr/local/bin/wakatime-cli"))


;; --------------------------------------------------------------------------
;; Package Repository Configuration

(require 'package)

(add-to-list
 'package-archives
 '("melpa" . "http://melpa.org/packages/") t)

(add-to-list
 'package-archives
 '("melpa-stable" . "https://stable.melpa.org/packages/") t)

(setq package-archive-priorities '(("gnu" . 30)
                                   ("nongnu" . 25)
                                   ("melpa-stable" . 20)
                                   ("melpa" . 10)))


(package-initialize)

;; do: M-x package-refresh-contents

(add-to-list 'load-path (expand-file-name "~/.emacs.d/lib"))

(set-language-environment "UTF-8")

;; --------------------------------------------------------------------------
;; Package Sync Configuration
;; set up package syncing to allow for syncing between different machines
;; list of packages to sync
(setq pfl-packages
      '(
        ;; ------------------------------------------------------------------
        ;; Language-neutral customization
        all-the-icons
        all-the-icons-completion
        all-the-icons-dired
        
        color-theme-sanityinc-solarized

        rainbow-delimiters
        hl-todo
        
        smart-tabs-mode

        undo-tree

        ;; ------------------------------------------------------------------
        ;; macOS specifics
        osx-lib
        osx-org-clock-menubar
        osx-plist
        osx-trash
        
        ;; ------------------------------------------------------------------
        ;; Dashboard
        dashboard
        dashboard-hackernews
        dashboard-project-status

        ;; ------------------------------------------------------------------
        ;; Org mode
        org-alert
        org-doing
        org-modern
        org-ql
        org-sidear
        org-super-agenda
        org-timeline
        ob-latex-as-png
        ob-rust

        ;; ------------------------------------------------------------------
        ;; Completion
        company
        company-quickhelp
        company-web

        selectrum
        selectrum-prescient
        marginalia

        yasnippet
        yasnippet-snippets
        
        ;; ------------------------------------------------------------------
        ;; Writing modes
        markdown-mode
        markdown-mode+

        easy-jekyll
        
        olivetti           ; distraction-free writing

        focus
        
        latex-preview-pane ; (latex-preview-pane-enable)
        latex-math-preview ; M-x latex-math-preview-expression
        latex-extra

        smog               ; check writing style: M-x smog-check-buffer

        ;; ------------------------------------------------------------------
        ;; Terminal Stuff
        ;; vterm
        ;; vterm-toggle
        ;; vtm
        ;; multi-vterm
        
        ;; ------------------------------------------------------------------
        ;; Git interfaces
        git-attr
        git-blamed
        git-link
        github-explorer ; M-x github-explorer "txgvnn/github-explorer"
        github-notifier
        github-pullrequest
        github-review
        github
        magit
        magit-lfs
        magit-filenotify
        magit-todos
        forge

        diff-hl

        ;; ------------------------------------------------------------------
        ;; Core out-of-process integrations
        lsp-ui

        dap-mode

        ;; restclient
        
        ;; ------------------------------------------------------------------
        ;; Project support
        projectile
        project-explorer

        ;; ------------------------------------------------------------------
        ;; Rust Development
        cargo
        cargo-mode
        rust-auto-use
        rust-playground
        rustic
        flycheck-rust

        ;; cov

        ;; ------------------------------------------------------------------
        ;; Scheme/Lisp Development
        racket-mode
        scribble-mode
        
        slime
        slime-company
        slime-repl-ansi-color
        elisp-slime-nav

        geiser
        geiser-chez
        geiser-racket

        quack

        scheme-complete

        ;; ------------------------------------------------------------------
        ;; Data/Config file formats
        toml-mode
        yaml-mode
        json-mode

        ;; ------------------------------------------------------------------
        ;; Hosted service integrations
        wakatime-mode
        ))

;; refresh package list if it is not already available
(when (not package-archive-contents) (package-refresh-contents))

;; install packages from the list that are not yet installed
(dolist (pkg pfl-packages)
  (when (and (not (package-installed-p pkg)) (assoc pkg package-archive-contents))
    (package-install pkg)))

;; --------------------------------------------------------------------------
;; Just UI stuff

(color-theme-sanityinc-solarized-light)

(when (display-graphic-p)
  (require 'all-the-icons))

;; M-x all-the-icons-install-fonts

(require 'dashboard)
(setq dashboard-items '((recents  . 10)
                        (projects . 15)
                        (agenda . 10)
                        (bookmarks . 5)
                        (registers . 5)))
(setq dashboard-projects-switch-function 'projectile-persp-switch-project)
(setq dashboard-set-navigator t)
(setq dashboard-set-init-info nil)
(setq dashboard-set-footer nil)
(setq dashboard-set-heading-icons t)
(setq dashboard-set-file-icons t)
(setq dashboard-week-agenda t)

(dashboard-setup-startup-hook)

(setq display-time-string-forms
       '((propertize (concat " " 24-hours ":" minutes " "))))

(display-time-mode t)
(line-number-mode t)
(column-number-mode t)
(display-battery-mode t)

(require 'undo-tree)
(global-undo-tree-mode)

;; --------------------------------------------------------------------------
;; Org mode

(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

;;(require org)
(setq org-todo-keywords
   '((sequence "TODO(t)" "NEXT(n)" "INPROGRESS(p!)" "WAIT(w@/!)" "|" "DONE(d!)" "CANCELED(c@)")
     (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "DONE(d)" "CANCELED(k@)")))

(setq org-log-into-drawer t)

(setq org-priority-highest 1
      org-priority-lowest 5
      org-priority-default 3)

(setq org-directory (expand-file-name "~/Documents/emacs-org"))
(setq org-default-notes-file (concat org-directory "/notes.org"))
(setq org-agenda-files
      (list (concat org-directory "/todo.org")
            (concat org-directory "/birthdays.org")
            (concat org-directory "/holidays.org")))

(defun skj/org-skip-subtree-if-priority (priority)
  "Skip an agenda subtree if it has a priority of PRIORITY.

PRIORITY must be an integer 1 <= p <= 5."
  (let ((subtree-end (save-excursion (org-end-of-subtree t)))
        (pri-current (org-get-priority (thing-at-point 'line t))))
    (if (= priority pri-current)
        subtree-end
      nil)))

(defun skj/org-skip-subtree-if-habit ()
  "Skip an agenda entry if it has a STYLE property equal to \"habit\"."
  (let ((subtree-end (save-excursion (org-end-of-subtree t))))
    (if (string= (org-entry-get nil "STYLE") "habit")
        subtree-end
      nil)))

(setq org-agenda-custom-commands
      '(("N" "ALL Notes"
         ((tags "NOTE"
                ((org-agenda-overriding-header "Notes")
                 (org-tags-match-list-sublevels t)))))
        ("c" "Simple agenda view"
         ((tags "PRIORITY=1"
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "High-priority unfinished tasks:")))
          (agenda "")
          (alltodo ""
                   ((org-agenda-skip-function
                     '(or (skj/org-skip-subtree-if-priority 1)
                          (org-agenda-skip-if nil '(scheduled deadline))))))))
        ("d" "Daily agenda and all TODOs"
         ((tags "PRIORITY=1"
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "High-priority unfinished tasks:")))
          (agenda ""
                  ((org-agenda-span 'day)
                   (org-agenda-overriding-header "Today's tasks:")))
          (alltodo ""
                   ((org-agenda-skip-function
                     '(or (skj/org-skip-subtree-if-habit)
                          (skj/org-skip-subtree-if-priority 1)
                          (org-agenda-skip-if nil '(scheduled deadline))))
                    (org-agenda-overriding-header "ALL normal priority tasks:")))))))

(setq org-tag-alist
      '((:startgroup)
        ("business" . ?B) ("technical" . ?T) ("hr" . ?H)
        (:endgroup)
        (:startgroup)
        ("l6" . ?6) ("l7" . ?7) ("l8" . ?8) ("l10" . ?0) ("l11" . ?1)
        (:endgroup)
        (:startgroup)
        ("@home" . ?H) ("@travel" . ?V) ("@work" . ?W)
        (:endgroup)
        (:startgrouptag)
        ("Things")
        (:grouptags)
        ("idea" . ?i) ("call" . ?c) ("note" . ?n)
        (:endgrouptag)
        (:startgrouptag)
        ("Home")
        (:grouptags)
        ("fix") ("clean") ("garage") ("yard") ("family") ("friends")
        (:endgrouptag)
        (:startgrouptag)
        ("Activities")
        (:grouptags)
        ("diving" . ?d) ("synth" . ?s) ("hacking" . ?h)
        (:endgrouptag)
        (:startgrouptag)
        ("Finance")
        (:grouptags)
        ("bank") ("insurance") ("budget") ("pcrg")
        (:endgrouptag)
        (:startgrouptag)
        ("Work")
        (:grouptags)
        ("coding" . ?o) ("meeting" . ?m) ("planning" . ?p) ("writing" . ?w)
        (:endgrouptag)))

(setq org-agenda-hide-tags-regexp ".")
(setq org-agenda-log-mode-items '(closed clock state))
(setq org-agenda-include-diary t)

(setq org-clock-persist 'history)

;;This damn thing resets 'org-directory
;;(org-clock-persistence-insinuate)

(add-hook 'org-mode-hook #'turn-on-font-lock)

;;(org-babel-do-load-languages
;; 'org-babel-load-languages
;; '((plantuml . t))) ; this line activates plantuml

;;(setq org-plantuml-jar-path
;;      (expand-file-name "/usr/local/Cellar/plantuml/1.2022.2_1/libexec/plantuml.jar"))

;; --------------------------------------------------------------------------
;; Mode Hooks

(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

(add-hook 'prog-mode-hook #'github-notifier-mode)

(add-hook 'LaTeX-mode-hook #'latex-extra-mode)

(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

(global-set-key (kbd "<f9>") 'dir-treeview)

(add-to-list 'auto-mode-alist '("\\.zsh\\'" . sh-mode))

(add-hook 'sh-mode-hook
          (lambda ()
            (if (string-match "\\.zsh$" buffer-file-name)
                (sh-set-shell "zsh"))))

(add-hook 'web-mode-hook
          (lambda ()
            (set (make-local-variable 'company-backends) '(company-web-html))
            (company-mode t)))

;; --------------------------------------------------------------------------
;; Keyboard

(setq mac-command-modifier 'super)        ; make cmd key do Super
(setq mac-right-command-modifier 'super)
(setq mac-option-modifier 'meta)          ; make opt key do Meta
(setq mac-right-option-modifier 'meta)
(setq mac-control-modifier 'control)      ; make Control key do Control
(setq ns-function-modifier 'hyper)        ; make Fn key do Hyper

;; --------------------------------------------------------------------------
;; Mouse in terminal

(require 'mouse)

(xterm-mouse-mode t)

;; mouse wheel
(global-set-key [mouse-4] (lambda ()
                            (interactive)
                            (scroll-down 1)))
(global-set-key [mouse-5] (lambda ()
                            (interactive)
                            (scroll-up 1)))

(setq mouse-wheel-follow-mouse 't)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))

;; --------------------------------------------------------------------------
;; Company customization

(require 'company)
(setq company-tooltip-align-annotations t)

(add-hook 'after-init-hook 'global-company-mode)

;; --------------------------------------------------------------------------
;; Markdown customization

(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

(autoload 'gfm-mode "markdown-mode"
  "Major mode for editing GitHub Flavored Markdown files" t)
(add-to-list 'auto-mode-alist '("README\\.md\\'" . gfm-mode))

;; --------------------------------------------------------------------------
;; Generic dev-tool customization

(require 'lsp)
(setq lsp-eldoc-render-all t)
(setq lsp-idle-delay 0.6)

(require 'lsp-ui)
(setq lsp-ui-peek-always-show t)
(setq lsp-ui-sideline-show-hover t)
(setq lsp-ui-doc-enable nil)

(add-hook 'lsp-mode-hook 'lsp-ui-mode)

(setq lsp-rust-analyzer-server-display-inlay-hints t)
(setq lsp-rust-analyzer-cargo-watch-command "clippy")

;; to make sorting and filtering more intelligent
(selectrum-prescient-mode +1)

;; to save your command history on disk, so the sorting gets more
;; intelligent over time
(prescient-persist-mode +1)

(require 'projectile)
(setq projectile-require-project-root t)
(setq projectile-project-search-path
      '("~/Projects/"
        "~/Projects/idea/"
        "~/Projects/racket/"
        "~/Projects/rust/"
        "~/Projects/Amazon/"))

;; Recommended keymap prefix on macOS
(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)

(projectile-mode +1)

(require 'yasnippet)
(yas-global-mode 1)
(yas-reload-all)
(add-hook 'prog-mode-hook #'yas-minor-mode)

;; --------------------------------------------------------------------------
;; Rust customization
;; https://github.com/rust-lang/rust-mode

(autoload 'rust-mode "rust-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))

(add-hook 'after-init-hook #'global-flycheck-mode)

(with-eval-after-load 'rust-mode
  (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

(require 'rustic)
(setq rustic-format-on-save t)

(define-key rust-mode-map (kbd "TAB") #'company-indent-or-complete-common)

;; --------------------------------------------------------------------------
;; Wakatime customization
;; https://wakatime.com/emacs
;; Set the API key in ~/.wakatime.cfg

(global-wakatime-mode)

;; --------------------------------------------------------------------------
;; Set default mode

(setq-default major-mode 'text-mode)
(add-hook 'text-mode-hook 'auto-fill-mode)

;; --------------------------------------------------------------------------
;; Personal Information

(setq user-mail-address "johnstonskj@gmail.com")
(setq user-full-name "Simon K. Johnston")
(setq user-login-name "simonjo")

;; --------------------------------------------------------------------------
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :extend nil :stipple nil :background "#fdf6e3" :foreground "#657b83" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight light :height 140 :width normal :foundry "nil" :family "Fira Code"))))
 '(focus-unfocused ((t (:inherit font-lock-comment-face :foreground "white"))))
 '(tty-menu-disabled-face ((t (:background "brightgreen" :foreground "lightgray"))))
 '(tty-menu-enabled-face ((t (:background "brightgreen" :foreground "brightwhite" :weight bold))))
 '(tty-menu-selected-face ((t (:background "brightmagenta")))))

;; --------------------------------------------------------------------------
;; One last thing, ...
(require 'server)
(unless (and (fboundp 'server-running)
             (server-running-p))
  (server-start))
