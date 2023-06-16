;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Matthew O'Gorman"
      user-mail-address "mog@rldn.net"
      git-committer-name "Matthew O'Gorman"
      git-committer-email "mog@rldn.net"
      )
(menu-bar-mode 1)

(global-set-key (kbd "C-c C-t") '+vterm/toggle)
(global-set-key (kbd "C-c C-n") 'multi-vterm)
(global-set-key (kbd "C-c C-d") '+default/diagnostics)
(global-set-key (kbd "C-x w") 'vc-msg-show)
(global-set-key (kbd "C-c C-v") 'vterm-copy-mode)

(setq doom-font (font-spec :family "Victor Mono" :size 12 :weight 'medium)
      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))

(setq doom-theme 'doom-monokai-machine)

(setq display-line-numbers-type t)

(setq org-directory "~/org/")

;;(setq lsp-elixir-server-command '("elixir-ls"))
(setq lsp-elixir-server-command '("/home/mog/code/pepsico/lexical/_build/dev/rel/lexical/start_lexical.sh"))


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

(setq vterm-buffer-name-string "vt:%s")

(defun mog/vterm--set-title (title)
  (message "called")
  "Use TITLE to set the buffer name according to `vterm-buffer-name-string'."
  (if (string-equal (buffer-name) "*doom:vterm-popup:main*")
      (message "not renaming")
    (when vterm-buffer-name-string
      (rename-buffer (format vterm-buffer-name-string title) t))
    ))
(advice-add 'vterm--set-title :override #'mog/vterm--set-title)
