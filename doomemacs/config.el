;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Matthew O'Gorman"
      user-mail-address "mog@rldn.net"
      git-committer-name "Matthew O'Gorman"
      git-committer-email "mog@rldn.net"
      )

;;(setq exec-path (append exec-path '("/home/mog/code/pepsico/elixir-ls/release")))
(setq lsp-elixir-server-command '("elixir-ls"))
;;(setq lsp-elixir-local-server-command  '("elixir-ls"))
(menu-bar-mode 1)

(global-set-key (kbd "C-c C-t") '+vterm/toggle)
;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))
 (setq doom-font (font-spec :family "Victor Mono" :size 12 :weight 'medium)
       doom-variable-pitch-font (font-spec :family "sans" :size 13))


;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-molokai)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

(setq company-lsp-cache-candidates 'auto)
(setq lsp-elixir-dialyzer-enabled nil)

(defun lsp-elixir-set-configuration ()
  (let ((config `(:elixirLS (:mixEnv "dev" :dialyzerEnabled :json-false))))
    (lsp--set-configuration config)
    ))
(add-hook 'lsp-after-initialize-hook 'lsp-elixir-set-configuration)

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(setq lsp-file-watch-ignored-directories
      (quote
        ("[/\\\\]\\.git$"
        "[/\\\\]\\.elixir_ls$"
        "[/\\\\]_build$"
        "[/\\\\]assets$"
        "[/\\\\]cover$"
        "[/\\\\]deps$"
        "[/\\\\]node_modules$"
        )))

;;; lang/elixir/config.el -*- lexical-binding: t; -*-
;;;
(add-hook 'elixir-mode-hook
          (lambda () (add-hook 'before-save-hook 'elixir-format nil t)))

(use-package! lsp-mode
  :hook (elixir-mode . lsp))
(setq lsp-file-watch-threshold 2000)

(after! projectile
  (add-to-list 'projectile-project-root-files "mix.exs"))


;;
;;; Packages

(use-package! elixir-mode
  :defer t
  :init
  ;; Disable default smartparens config. There are too many pairs; we only want
  ;; a subset of them (defined below).
  (provide 'smartparens-elixir)
  :config
  (set-ligatures! 'elixir-mode
    ;; Functional
    :def "def"
    :lambda "fn"
    ;; :src_block "do"
    ;; :src_block_end "end"
    ;; Flow
    :not "!"
    :in "in" :not-in "not in"
    :and "and" :or "or"
    :for "for"
    :return "return" :yield "use")

  ;; ...and only complete the basics
  (sp-with-modes 'elixir-mode
    (sp-local-pair "do" "end"
                   :when '(("RET" "<evil-ret>"))
                   :unless '(sp-in-comment-p sp-in-string-p)
                   :post-handlers '("||\n[i]"))
    (sp-local-pair "do " " end" :unless '(sp-in-comment-p sp-in-string-p))
    (sp-local-pair "fn " " end" :unless '(sp-in-comment-p sp-in-string-p)))

  ;;(add-hook! lsp-mode (elixir-mode . lsp))
  ;; (add-hook 'elixir-mode-local-vars-hook #'lsp!)
  ;;   (after! lsp-mode
  ;;     (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\_build\\'"))

  (after! highlight-numbers
    (puthash 'elixir-mode
             "\\_<-?[[:digit:]]+\\(?:_[[:digit:]]\\{3\\}\\)*\\_>"
             highlight-numbers-modelist)))


(use-package! flycheck-credo
  :when (featurep! :checkers syntax)
  :after elixir-mode
  :config (flycheck-credo-setup))

(use-package! exunit
  :hook (elixir-mode . exunit-mode)
  :init
  (map! :after elixir-mode
        :localleader
        :map elixir-mode-map
        :prefix ("t" . "test")
        "a" #'exunit-verify-all
        "r" #'exunit-rerun
        "v" #'exunit-verify
        "T" #'exunit-toggle-file-and-test
        "t" #'exunit-toggle-file-and-test-other-window
        "s" #'exunit-verify-single))

(after! doom-modeline
  (setq doom-modeline-major-mode-icon t)
  (setq doom-modeline-buffer-file-name-style 'truncate-except-project)
  ;; Define your custom doom-modeline
(doom-modeline-def-modeline 'my-simple-line
 '(bar buffer-info remote-host  parrot selection-info)
 '(misc-info minor-modes input-method process lsp checker vcs))

;;Add to `doom-modeline-mode-hook` or other hooks
(defun setup-custom-doom-modeline ()
  (doom-modeline-set-modeline 'my-simple-line 'default))
(add-hook 'doom-modeline-mode-hook 'setup-custom-doom-modeline)
)
;; #9370db purple
;;(set-face-attribute 'mode-line nil :background "#9370db")
