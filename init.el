;; --------------------------------------------------------------------------
;; Global configuration

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/")
             t)

;; do: M-x package-refresh-contents

(add-to-list 'load-path (expand-file-name "~/.emacs.d/lib"))

(set-language-environment "UTF-8")


;; --------------------------------------------------------------------------
;; Markdown customization

(autoload 'gfm-mode "markdown-mode.el" "Major mode for editing Markdown files" t)

(setq auto-mode-alist (cons '("\\.markdown$" . gfm-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.md$" . gfm-mode) auto-mode-alist))


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
 '(package-selected-packages (quote (racket-mode))))
(custom-set-faces)