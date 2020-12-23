;; --------------------------------------------------------------------------
;; Global configuration

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

;; do: M-x package-refresh-contents

(add-to-list 'load-path (expand-file-name "~/.emacs.d/lib"))

(set-language-environment "UTF-8")

;; --------------------------------------------------------------------------
;;; set up package syncing to allow for syncing between different machines

;; list of packages to sync
(setq pfl-packages
        '(
        	; config
            color-theme-sanityinc-solarized
            rainbow-delimiters
            smart-tabs-mode
			; company
            company
            company-quickhelp
			; modes
            markdown-mode
            markdown-mode+
            racket-mode
            emacs-racer
            rust-mode
            cargo-mode
            toml-mode
            yaml-mode
            json-mode
            ))

;; refresh package list if it is not already available
(when (not package-archive-contents) (package-refresh-contents))

;; install packages from the list that are not yet installed
(dolist (pkg pfl-packages)
    (when (and (not (package-installed-p pkg)) (assoc pkg package-archive-contents))
        (package-install pkg)))

;; --------------------------------------------------------------------------
;; Company customization

(add-hook 'after-init-hook 'global-company-mode)

;; --------------------------------------------------------------------------
;; Markdown customization

\(autoload 'markdown-mode "markdown-mode"
   "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

(autoload 'gfm-mode "markdown-mode"
   "Major mode for editing GitHub Flavored Markdown files" t)
(add-to-list 'auto-mode-alist '("README\\.md\\'" . gfm-mode))

;; --------------------------------------------------------------------------
;; Rust customization
;; https://github.com/rust-lang/rust-mode
;; https://github.com/racer-rust/emacs-racer

(autoload 'rust-mode "rust-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))

(add-hook 'rust-mode-hook #'racer-mode)
(add-hook 'racer-mode-hook #'eldoc-mode)
(add-hook 'racer-mode-hook #'company-mode)

(require 'rust-mode)
(define-key rust-mode-map (kbd "TAB") #'company-indent-or-complete-common)
(setq company-tooltip-align-annotations t)


;; --------------------------------------------------------------------------
;; Racket mode customization
;; https://github.com/greghendershott/racket-mode/blob/master/Reference.md

;; do: M-x racket-mode-start-fasterw

(add-hook 'racket-mode-hook
          (lambda ()
            (define-key racket-mode-map (kbd "C-c r") 'racket-run)))

(add-hook 'racket-mode-hook      #'racket-unicode-input-method-enable)
(add-hook 'racket-repl-mode-hook #'racket-unicode-input-method-enable)

(setq tab-always-indent 'complete)

(load "scribble")


;; --------------------------------------------------------------------------
;; custom-set-variables was added by Custom.
;; If you edit it by hand, you could mess it up, so be careful.
;; Your init file should contain only one such instance.
;; If there is more than one, they won't work right.
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages (quote (company racer rust-mode cargo racket-mode))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
