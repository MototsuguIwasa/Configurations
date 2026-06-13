;;; init.el --- My init.el  -*- lexical-binding: t; -*-
;; Copyright (C) 2025  Mototsugu Iwasa
;; Author: Mototsugu iwasa
;;; Commentary:
;; My init.el.
;; 注意事項
;; ※ 事事前にターミナルで `pip install pyright` が必要です
;; ※ 事前にターミナルで `pip install ruff` が必要です
;;     M-x pyvenv-workon または M-x pyvenv-activate を実行して、
;;     該当する仮想環境を有効化する

;; =====================================================================
;; 1. 起動・パッケージ管理の初期化 (最優先)
;; =====================================================================
(eval-and-compile
  (customize-set-variable
   'package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                       ("melpa" . "https://melpa.org/packages/")))
  (package-initialize)
  (use-package leaf :ensure t)

  (leaf leaf-keywords
    :ensure t
    :init
    (leaf blackout :ensure t)
    :config
    (leaf-keywords-init)))

(leaf leaf-convert
  :doc "Convert many format to leaf format"
  :ensure t)

(leaf cus-edit
  :doc "tools for customizing Emacs and Lisp packages"
  :custom `((custom-file . ,(locate-user-emacs-file "custom.el"))))

(leaf exec-path-from-shell
  :doc "Get environment variables such as $PATH from the shell"
  :ensure t
  :defun (exec-path-from-shell-initialize)
  :custom ((exec-path-from-shell-check-startup-files . t)
           (exec-path-from-shell-variables . '("PATH" "GOPATH" "JAVA_HOME")))
  :config
  (exec-path-from-shell-initialize))

;; =====================================================================
;; 2. Emacsの見た目・UI・テーマ設定 (起動直後に適用)
;; =====================================================================
(leaf ns
  :doc "next/open/gnustep / macos communication module"
  :when (eq 'ns window-system)
  :custom ((ns-control-modifier . 'control)
           (ns-option-modifier . 'super)
           (ns-command-modifier . 'meta)
           (ns-right-control-modifier . 'control)
           (ns-right-option-modifier . 'hyper)
           (ns-right-command-modifier . 'meta)
           (default-frame-alist . '((ns-appearance . dark)
                                    (ns-transparent-titlebar . t)))))

(leaf all-the-icons
  :ensure t
  :config
  (unless (member "all-the-icons" (font-family-list))
    (all-the-icons-install-fonts t)))

(leaf doom-themes
  :ensure t
  :custom
  (doom-themes-enable-bold . t)
  (doom-themes-enable-italic . t)
  :config
  (load-theme 'doom-one t)
  (doom-themes-visual-bell-config)
  (doom-themes-neotree-config)
  (doom-themes-org-config))

(leaf doom-modeline
  :ensure t
  :hook (after-init-hook . doom-modeline-mode)
  :custom
  (doom-modeline-buffer-file-name-style . 'truncate-with-project)
  (doom-modeline-icon . t)
  (doom-modeline-major-mode-icon . t))

;; =====================================================================
;; 3. Emacs基本挙動・ビルトイン設定
;; =====================================================================
(leaf cus-start
  :doc "define customization properties of builtins"
  :preface
  (defun c/redraw-frame nil
    (interactive)
    (redraw-frame))
  :bind (("M-ESC ESC" . c/redraw-frame))
  :custom '((user-full-name . "Mototsugu Iwasa")
            (user-mail-address . "mototsugu.iwasa@gmail.com")
            (user-login-name . "mototsugu")
            (create-lockfiles . nil)
            (tab-width . 4)
            (debug-on-error . t)
            (init-file-debug . t)
            (frame-resize-pixelwise . t)
            (enable-recursive-minibuffers . t)
            (history-length . 1000)
            (history-delete-duplicates . t)
            (scroll-preserve-screen-position . t)
            (scroll-conservatively . 100)
            (mouse-wheel-scroll-amount . '(1 ((control) . 5)))
            (ring-bell-function . 'ignore)
            (text-quoting-style . 'straight)
            (truncate-lines . t)
            (use-dialog-box . nil)
            (use-file-dialog . nil)
            (menu-bar-mode . t)
            (tool-bar-mode . nil)
            (scroll-bar-mode . nil)
            (indent-tabs-mode . nil))
  :config
  (defalias 'yes-or-no-p 'y-or-n-p)
  (keyboard-translate ?\C-h ?\C-?))

(leaf autorevert
  :doc "revert buffers when files on disk change"
  :global-minor-mode global-auto-revert-mode)

(leaf delsel
  :doc "delete selection if you insert"
  :global-minor-mode delete-selection-mode)

(leaf paren
  :doc "highlight matching paren"
  :global-minor-mode show-paren-mode)

(leaf simple
  :doc "basic editing commands for Emacs"
  :custom ((kill-read-only-ok . t)
           (kill-whole-line . t)
           (eval-expression-print-length . nil)
           (eval-expression-print-level . nil)))

(leaf files
  :doc "file input and output commands for Emacs"
  :global-minor-mode auto-save-visited-mode
  :custom `((auto-save-file-name-transforms . '((".*" ,(locate-user-emacs-file "backup/") t)))
            (backup-directory-alist . '((".*" . ,(locate-user-emacs-file "backup"))
                                        (,tramp-file-name-regexp . nil)))
            (version-control . t)
            (delete-old-versions . t)
            (auto-save-visited-interval . 1)))

(leaf startup
  :doc "process Emacs shell arguments"
  :custom `((auto-save-list-file-prefix . ,(locate-user-emacs-file "backup/.saves-"))))

(leaf savehist
  :doc "Save minibuffer history"
  :custom `((savehist-file . ,(locate-user-emacs-file "savehist")))
  :global-minor-mode t)

;; =====================================================================
;; 4. 検索・強力な補完エコシステム・編集補助 (コア機能群)
;; =====================================================================
(leaf which-key
  :doc "Display available keybindings in popup"
  :ensure t
  :global-minor-mode t)

(leaf vertico
  :doc "VERTical Interactive COmpletion"
  :ensure t
  :global-minor-mode t)

(leaf marginalia
  :doc "Enrich existing commands with completion annotations"
  :ensure t
  :global-minor-mode t)

(leaf orderless
  :doc "Completion style for matching regexps in any order"
  :ensure t
  :custom ((completion-styles . '(orderless))
           (completion-category-defaults . nil)
           (completion-category-overrides . '((file (styles partial-completion))))))

(leaf consult
  :doc "Consulting completing-read"
  :ensure t
  :hook (completion-list-mode-hook . consult-preview-at-point-mode)
  :defun consult-line
  :preface
  (defun c/consult-line (&optional at-point)
    "Consult-line uses things-at-point if set C-u prefix."
    (interactive "P")
    (if at-point
        (consult-line (thing-at-point 'symbol))
      (consult-line)))
  :custom ((xref-show-xrefs-function . #'consult-xref)
           (xref-show-definitions-function . #'consult-xref)
           (consult-line-start-from-top . t))
  :bind (([remap switch-to-buffer] . consult-buffer)
         ([remap project-switch-to-buffer] . consult-project-buffer)
         ([remap goto-line] . consult-goto-line)
         ([remap imenu] . consult-imenu)
         ("M-g f" . consult-flymake)
         ("C-s" . c/consult-line)
         ("C-M-s" . nil)
         ("C-M-s s" . isearch-forward)
         ("C-M-s C-s" . isearch-forward-regexp)
         ("C-M-s r" . consult-ripgrep)
         (minibuffer-local-map
          :package emacs
          ("C-r" . consult-history))))

(leaf affe
  :doc "Asynchronous Fuzzy Finder for Emacs"
  :ensure t
  :custom ((affe-highlight-function . 'orderless-highlight-matches)
           (affe-regexp-function . 'orderless-pattern-compiler))
  :bind (("C-M-s r" . affe-grep)
         ("C-M-s f" . affe-find)))

;; --- Embark 本体 (ミニバッファのアクション) ---
(leaf embark
  :doc "Adaptable tactical actions in Emacs"
  :ensure t
  :bind (("C-." . embark-act)
         ("M-." . embark-dwim)
         ("C-h B" . embark-bindings))
  :config
  (setq prefix-help-command #'embark-prefix-help-command))

;; --- Embark と Consult の架け橋 ---
(leaf embark-consult
  :doc "Consult integration for Embark"
  :ensure t
  :after embark consult
  ;; ↓ :require ではなく :init で確実にパッケージを存在させる
  :init (require 'embark-consult nil t)
  :hook (embark-collect-mode-hook . consult-preview-at-point-mode))

(leaf corfu
  :doc "COmpletion in Region FUnction"
  :ensure t
  :global-minor-mode global-corfu-mode corfu-popupinfo-mode
  :custom ((corfu-auto . t)
           (corfu-auto-delay . 0)
           (corfu-auto-prefix . 1)
           (corfu-popupinfo-delay . nil))
  :bind ((corfu-map
          ("C-s" . corfu-insert-separator))))

(leaf cape
  :doc "Completion At Point Extensions"
  :ensure t
  :config
  (add-to-list 'completion-at-point-functions #'cape-file))

(leaf puni
  :doc "Parentheses Universalistic"
  :ensure t
  :global-minor-mode puni-global-mode
  :bind (puni-mode-map
         ("C-}" . puni-slurp-forward)
         ("C-{" . puni-barf-forward)
         ("C-c ("  . puni-wrap-round)
         ("C-c ["  . puni-wrap-square)
         ("C-c {"  . puni-wrap-curly)
         ("C-c k"  . puni-squeeze)
         ("C-c s"  . puni-splice)
         ("C-c M-r" . puni-raise)
         ("M-K"    . puni-kill-line)
         ("C-c M-u" . puni-splice-killing-backward)))

;; =====================================================================
;; 5. 開発環境・言語別の設定 (LSP / 各種プログラミング言語)
;; =====================================================================

;; --- Flycheck 基盤 ---
(leaf flycheck
  :ensure t
  :defun flycheck-add-next-checker
  :global-minor-mode global-flycheck-mode
  :config
  (with-eval-after-load 'flycheck
    (flycheck-add-next-checker 'haskell-ghc 'haskell-hlint)))

;; --- LSP コアクライアント ---
(leaf lsp-mode
  :ensure t
  :custom ((lsp-keep-workspace-alive . nil)
           (lsp-signature-auto-activate . t)
           (lsp-keymap-prefix . "C-c l")
           (lsp-diagnostics-provider . :flycheck)
           (lsp-completion-provider . :capf)
           (lsp-before-save-hook . nil))
  :bind (:lsp-mode-map
         ("C-c r" . lsp-rename)
         ("C-c a" . lsp-execute-code-action))
  :hook ((haskell-mode-hook . lsp-deferred)
         (python-mode-hook . (lambda ()
                               (add-hook 'before-save-hook #'lsp-format-buffer nil t)
                               (add-hook 'before-save-hook #'lsp-organize-imports nil t)))
         (haskell-mode-hook . (lambda ()
                                (add-hook 'before-save-hook #'lsp-format-buffer nil t)
                                (add-hook 'before-save-hook #'lsp-organize-imports nil t)))))

(leaf lsp-ui
  :ensure t
  :after lsp-mode
  :hook (lsp-mode-hook . lsp-ui-mode)
  :custom ((lsp-ui-doc-enable . t)
           (lsp-ui-peek-enable . t)))

;; --- Haskell 開発環境 ---
(leaf haskell-mode
  :ensure t
  :mode "\\.hs\\'")

(leaf flycheck-haskell
  :doc "Improved Haskell support for Flycheck"
  :ensure t
  :after (flycheck haskell-mode)
  :hook (haskell-mode-hook . flycheck-haskell-setup))

(leaf lsp-haskell
  :ensure t
  :after haskell-mode lsp-mode)

;; --- Python 開発環境 ---
(leaf pyvenv
  :ensure t
  :config
  (add-hook 'pyvenv-post-activate-hook #'lsp-restart-workspace))

(leaf python
  :doc "Python editing mode"
  :tag "builtin" "languages"
  :mode ("\\.py\\'" . python-mode)
  :custom ((python-indent-offset . 4)))

(leaf lsp-pyright
  :doc "LSP client for Python using Pyright"
  :ensure t
  :after lsp-mode python
  :custom ((lsp-pyright-multi-root . t))
  :hook (python-mode-hook . lsp-deferred))

(leaf lsp-ruff
  :doc "LSP client for Python using Ruff"
  :after lsp-mode python
  :require lsp-ruff
  :hook (python-mode-hook . lsp-deferred))

(leaf cape-python
  :after (cape python)
  :config
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

;; --- データベース (MariaDB) ---
(leaf sql
  :doc "SQL mode configuration for MariaDB"
  :tag "builtin" "database"
  :custom
  (sql-connection-alist . '((my-mariadb
                             (sql-product 'mariadb)
                             (sql-user "root")
                             (sql-password "root")
                             (sql-server "localhost")
                             (sql-port 3306))))
  (sql-connection-candidate . 'my-mariadb)
  :config
  (add-to-list 'auto-mode-alist '("\\.sql\\'" . sql-mode)))

;; --- ドキュメント (Markdown) ---
(leaf markdown-mode
  :ensure t
  :mode (("\\.md\\'" . gfm-mode)
         ("\\.markdown\\'" . gfm-mode))
  :hook (markdown-mode-hook . visual-line-mode)
  :custom ((markdown-hide-markup . t)))

;; --- バージョン管理 (Git) ---
(leaf magit
  :doc "A Git porcelain for Emacs"
  :tag "git" "tools"
  :ensure t
  :bind (("C-x g" . magit-status)
         ("C-x M-g" . magit-dispatch)
         ("C-c L" . magit-log-buffer-file))
  :custom (magit-display-buffer-function . 'magit-display-buffer-fullcolumn-most-v1))

;; --- Gemini AI (gptel) の設定 ---
(leaf gptel
  :doc "A versatile LLM client for Emacs"
  :ensure t
  :bind (("C-c g g" . gptel)          ; チャットバッファを開く
         ("C-c g *" . gptel-menu))    ; 選択範囲への指示やメニューを開く
  :config
  (require 'gptel-gemini)
  
  ;; Gemini バックエンドとモデルの設定
  (setq-default 
   ;; 現在安定して利用できる上位モデル（Pro版）を指定
   gptel-model "gemini-2.5-flash" 
   
   gptel-backend
   (gptel-make-gemini "Gemini"
     ;; ↓ 発行した無料枠のAPIキーをここに直接記述します
     :key "" ; ここにAPI Keyをいれる
     :stream t)))

(leaf transient
  :doc "Transient commands (Magit depends on this)"
  :ensure t
  :custom `((transient-history-file . ,(locate-user-emacs-file "transient/history.el"))
            (transient-levels-file  . ,(locate-user-emacs-file "transient/levels.el"))
            (transient-values-file  . ,(locate-user-emacs-file "transient/values.el"))))

;; =====================================================================
;; 最終処理
;; =====================================================================
(provide 'init)

;; Local Variables:
;; indent-tabs-mode: nil
;; End:

;;; init.el ends here
