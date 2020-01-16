;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; refresh' after modifying this file!


;; These are used for a number of things, particularly for GPG configuration,
;; some email clients, file templates and snippets.
(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;(setq doom-font (font-spec :family "monospace" :size 14))
(setq doom-font (font-spec :family "Hack" :size 14))
;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. These are the defaults.
(setq doom-theme 'doom-one)

;; If you intend to use org, it is recommended you change this!
(setq org-directory "~/org/")

;; If you want to change the style of line numbers, change this to `relative' or
;; `nil' to disable it:
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', where Emacs
;;   looks when you load packages with `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.
(add-load-path! "themes")
(load-theme 'ample-base t)

;;;; custom Fx functions
(defun switch-to-user-buffer (arg)
  "Switch to user.clj buffer"
  (interactive "p")
  (switch-to-buffer "user.clj"))

(defun switch-to-repl-buffer (arg)
  "Switch to cider-repl buffer"
  (interactive "p")
  (setq buffer-names (mapcar (function buffer-name) (buffer-list)))
  (let ((buf-name (car (seq-filter (lambda ($x) (string-match "cider-repl" $x)) buffer-names))))
    (switch-to-buffer buf-name)))

(map! "<f6>" #'switch-to-user-buffer)
(map! "<f7>" #'switch-to-repl-buffer)
(map! "C-c 1" #'indent-region)
(map! "C-c 2" #'clojure-align)

;; advices so that vim-style line-ending can be send to CIDER as last-sexp
(defun cider-send-to-repl-and-eval (arg)
    "Send last-sexp to repl and eval"
  (interactive "p")
  (cider-insert-last-sexp-in-repl arg))

(defadvice cider-last-sexp (around evil activate)
  "In normal-state or motion-state, last sexp ends at point."
  (if (or (evil-normal-state-p) (evil-motion-state-p))
      (save-excursion
        (unless (or (eobp) (eolp)) (forward-char))
        ad-do-it)
    ad-do-it))

(defadvice cider-send-to-repl-and-eval (around evil activate)
  "In normal-state or motion-state, last sexp ends at point."
  (if (or (evil-normal-state-p) (evil-motion-state-p))
      (save-excursion
        (unless (or (eobp) (eolp)) (forward-char))
        ad-do-it)
    ad-do-it))

(evil-define-key 'normal 'global (kbd "SPC w e") #'delete-other-windows)
(evil-define-key 'normal clojure-mode-map (kbd "SPC m e t") #'cider-send-to-repl-and-eval)

(use-package! cider
  :config
  (setq cider-repl-pop-to-buffer-on-connect t)
  (set-popup-rule! "^\\*cider-repl" :side 'right :size 0.5)
  (map! (:localleader
          (:map (clojure-mode-map clojurescript-mode-map)
            "SPC m e t" #'cider-send-to-repl-and-eval))))



;; Use clojure mode for other extensions
(add-to-list 'auto-mode-alist '("\\.edn$" . clojure-mode))
(add-to-list 'auto-mode-alist '("\\.boot$" . clojure-mode))
(add-to-list 'auto-mode-alist '("\\.cljs.*$" . clojure-mode))
(add-to-list 'auto-mode-alist '("lein-env" . enh-ruby-mode))
