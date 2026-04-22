;;; init.el --- My init.el  -*- lexical-binding: t; -*-

;; Copyright (C) 2025  Mototsugu Iwasa

;; Author: Mototsugu iwasa

;;; Commentary:

;; My init.el.

;;; Code:

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

(leaf cus-start
  :doc "define customization properties of builtins"
  :preface
  (defun c/redraw-frame nil
    (interactive)
    (redraw-frame))

  :bind (("M-ESC ESC" . c/redraw-frame))
  :custom '((user-full-name . "Mototsugu Iwasa")
            (user-mail-address . "mototsugu.iwasa@gmail.comm")
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

(leaf which-key
  :doc "Display available keybindings in popup"
  :ensure t
  :global-minor-mode t)

(leaf exec-path-from-shell
  :doc "Get environment variables such as $PATH from the shell"
  :ensure t
  :defun (exec-path-from-shell-initialize)
  :custom ((exec-path-from-shell-check-startup-files)
           (exec-path-from-shell-variables . '("PATH" "GOPATH" "JAVA_HOME")))
  :config
  (exec-path-from-shell-initialize))

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

(leaf vertico
  :doc "VERTical Interactive COmpletion"
  :ensure t
  :global-minor-mode t)

(leaf marginalia
  :doc "Enrich existing commands with completion annotations"
  :ensure t
  :global-minor-mode t)

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
  :bind (;; C-c bindings (mode-specific-map)
         ([remap switch-to-buffer] . consult-buffer) ; C-x b
         ([remap project-switch-to-buffer] . consult-project-buffer) ; C-x p b

         ;; M-g bindings (goto-map)
         ([remap goto-line] . consult-goto-line)    ; M-g g
         ([remap imenu] . consult-imenu)            ; M-g i
         ("M-g f" . consult-flymake)

         ;; C-M-s bindings
         ("C-s" . c/consult-line)       ; isearch-forward
         ("C-M-s" . nil)                ; isearch-forward-regexp
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

(leaf orderless
  :doc "Completion style for matching regexps in any order"
  :ensure t
  :custom ((completion-styles . '(orderless))
           (completion-category-defaults . nil)
           (completion-category-overrides . '((file (styles partial-completion))))))

(leaf embark-consult
  :doc "Consult integration for Embark"
  :ensure t
  :bind ((minibuffer-mode-map
          :package emacs
          ("M-." . embark-dwim)
          ("C-." . embark-act))))

(leaf corfu
  :doc "COmpletion in Region FUnction"
  :ensure t
  :global-minor-mode global-corfu-mode corfu-popupinfo-mode
  :custom ((corfu-auto . t)
           (corfu-auto-delay . 0)
           (corfu-auto-prefix . 1)
           (corfu-popupinfo-delay . nil)) ; manual
  :bind ((corfu-map
          ("C-s" . corfu-insert-separator))))

(leaf cape
  :doc "Completion At Point Extensions"
  :ensure t
  :config
  (add-to-list 'completion-at-point-functions #'cape-file))

;; Haskell 基本モード
(leaf haskell-mode
  :ensure t
  :mode "\\.hs\\'")

;; 2. Haskell 用の Flycheck 拡張設定
(leaf flycheck-haskell
  :doc "Improved Haskell support for Flycheck"
  :ensure t
  :after (flycheck haskell-mode)
  :hook (haskell-mode-hook . flycheck-haskell-setup))

;; 3. Flycheck 本体の設定（前回の設定に追加）
(leaf flycheck
  :ensure t
  :global-minor-mode global-flycheck-mode
  :config
  ;; GHC でのチェック後に hlint を実行するようにチェッカーを繋げる設定
  (with-eval-after-load 'flycheck
    (flycheck-add-next-checker 'haskell-ghc 'haskell-hlint)))

;; LSP クライアント本体
(leaf lsp-mode
  :ensure t
  :hook (haskell-mode-hook . lsp-deferred)
  :custom ((lsp-keep-workspace-alive . nil)
           (lsp-signature-auto-activate . t))
  :bind (:lsp-mode-map
         ("C-c r" . lsp-rename)
         ("C-c a" . lsp-execute-code-action))
  :config
  ;; 必要に応じて lsp-ui などの設定をここに追加
  )

;; HLS との連携用ブリッジ
(leaf lsp-haskell
  :ensure t
  :after haskell-mode lsp-mode)

;; (任意) LSP の UI をリッチにする
(leaf lsp-ui
  :ensure t
  :after lsp-mode
  :hook (lsp-mode-hook . lsp-ui-mode)
  :custom ((lsp-ui-doc-enable . t)
           (lsp-ui-peek-enable . t)))

(leaf puni
  :doc "Parentheses Universalistic"
  :ensure t
  :global-minor-mode puni-global-mode
  :bind (puni-mode-map
         ;; default mapping
         ;; ("C-M-f" . puni-forward-sexp)
         ;; ("C-M-b" . puni-backward-sexp)
         ;; ("C-M-a" . puni-beginning-of-sexp)
         ;; ("C-M-e" . puni-end-of-sexp)
         ;; ("M-)" . puni-syntactic-forward-punct)
         ;; ("C-M-u" . backward-up-list)
         ;; ("C-M-d" . backward-down-list)
         ("C-)" . puni-slurp-forward)
         ("C-}" . puni-barf-forward)
         ("M-(" . puni-wrap-round)
         ("M-s" . puni-splice)
         ("M-r" . puni-raise)
         ("M-U" . puni-splice-killing-backward)
         ("M-z" . puni-squeeze))
  :config
  (leaf elec-pair
    :doc "Automatic parenthesis pairing"
    :global-minor-mode electric-pair-mode))

(leaf all-the-icons
  :ensure t
  :config
  ;; フォントが未インストールの場合に自動インストールを促す（任意）
  (unless (member "all-the-icons" (font-family-list))
    (all-the-icons-install-fonts t)))

(leaf doom-themes
  :ensure t
  :custom
  (doom-themes-enable-bold . t)    ; 太字を有効化
  (doom-themes-enable-italic . t)  ; 斜体を有効化
  :config
  ;; 好みのテーマをロード
  (load-theme 'doom-one t)
  ;; モードライン用の修正を有効化
  (doom-themes-visual-bell-config)
  (doom-themes-neotree-config) ; neotreeを使う場合
  (doom-themes-org-config))    ; org-modeを使う場合

(leaf doom-modeline
  :ensure t
  :hook (after-init-hook . doom-modeline-mode)
  :custom
  (doom-modeline-buffer-file-name-style . 'truncate-with-project)
  (doom-modeline-icon . t)      ; アイコンを表示
  (doom-modeline-major-mode-icon . t))

(leaf magit
  :doc "A Git porcelain for Emacs"
  :tag "git" "tools"
  :ensure t
  :bind (("C-x g" . magit-status)
         ("C-x M-g" . magit-dispatch)
         ("C-c L" . magit-log-buffer-file))
  :custom
  ;; ステータスバッファをフルスクリーン（または現在のウィンドウ全体）で開く設定
  ;; 今の設定スタイルに合わせてお好みで
  (magit-display-buffer-function . 'magit-display-buffer-fullcolumn-most-v1))

(leaf transient
  :doc "Transient commands (Magit depends on this)"
  :ensure t
  :custom `((transient-history-file . ,(locate-user-emacs-file "transient/history.el"))
            (transient-levels-file  . ,(locate-user-emacs-file "transient/levels.el"))
            (transient-values-file  . ,(locate-user-emacs-file "transient/values.el"))))

(provide 'init)

;; Local Variables:
;; indent-tabs-mode: nil
;; End:

;;; init.el ends here
