;;; init.el --- My init.el  -*- lexical-binding: t; -*-
;; Copyright (C) 2025  Mototsugu Iwasa
;; Author: Mototsugu Iwasa
;;; Commentary:
;; My init.el (Debian / macOS 共通・Emacs 31 対応版)
;;
;; ■ 事前準備（OS側のパッケージ導入）
;; [Debian] sudo apt update && sudo apt install ripgrep pandoc git build-essential
;; [macOS]  brew install ripgrep pandoc coreutils
;;          (補足) coreutils は Dired コマンドの中で利用する (macOS での表示崩れを防止するために導入)
;;
;; ■ Python 開発環境の準備
;; ※ 対象の仮想環境内（または pipx 等）で `pip install pyright ruff` が必要です
;; ※ Emacs 上で M-x pyvenv-workon または M-x pyvenv-activate を実行して、
;;    該当する仮想環境を有効化してください
;;
;; ■ Haskell 開発環境の準備
;; ※ ghcup 等で ghc / haskell-language-server (HLS) / hlint の導入が必要です
;; 
;; ■ Org-mode で作成する文書を保管するフォルダを用意する
;;    (GitHub から Org-mode を clone する親フォルダを準備)
;;   [Debian] ~/works
;;   [macOS]  ~/Documents/works/
;;
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
  :custom ((exec-path-from-shell-variables . '("PATH" "GOPATH" "JAVA_HOME")))
  :config
  (exec-path-from-shell-initialize))

;; =====================================================================
;; 2. Emacsの見た目・UI・テーマ設定 (起動直後に適用)
;; =====================================================================
;; --- フォント設定 (Debian / macOS 共通) ---
(leaf font-settings
  :doc "Set default font for avoiding Org-mode table misalignment"
  ;; OSにインストールしたフォント名を指定します
  ;; (HackGen の場合は "HackGen" などに書き換えてください)
  ;; Org-mode の表で罫線が揃うように等幅フォントである「PlemolJP」を導入する。
  ;; 1. GitHub の PlemolJP リリースページ（https://github.com/yuru7/PlemolJP/releases）にアクセスする。
  ;; 2. 「Assets」の中から、最新版の zip ファイル（例：PlemolJP_vX.X.X.zip）をダウンロードして解凍します。
  ;;    (※ Nerd Fonts（アイコン付き）を使いたい場合は PlemolJP_NF_vX.X.X.zip を選んでください)
  ;; 3. ダウンロードしたファイルを解凍する。
  ;;    解凍では、2つのフォルダが作成される (PlemolJP35Console_NF と PlemolJPConsole_NF)
  ;;    ***35*** となっている方は、半角3:全角5の比率で作成されているので「35」という数字がついていない方を使うこと
  ;;
  ;; 4. システムへの取り込み
  ;; [Debian]
  ;;   # フォント用のディレクトリが存在しない場合は作成
  ;;   mkdir -p ~/.local/share/fonts/
  ;;   # 解凍したフォルダの中にある .ttf ファイルをすべてコピー
  ;;   cp -r PlemolJPConsole_NF/*.ttf ~/.local/share/fonts/
  ;;   # フォントキャッシュを更新してOSに認識させる
  ;;   fc-cache -f -v
  ;;
  ;; [macOS]
  ;;   # 解凍した PlemolJP のフォルダがあるディレクトリに移動して実行します
  ;;   cp -r PlemolJPConsole_NF/*.ttf ~/Library/Fonts/
  ;;
  :when (and (display-graphic-p)
             (find-font (font-spec :name "PlemolJP Console NF")))
  :config
  ;; 1. default（サイズ含む）と fixed-pitch を1回ずつで無駄なく設定
  ;;    macOS は 140 (14pt)、それ以外 (Debian) は 120 (12pt) に設定
  (set-face-attribute 'default nil
                      :family "PlemolJP Console NF"
                      :height (if (eq system-type 'darwin) 140 120))
  (set-face-attribute 'fixed-pitch nil
                      :family "PlemolJP Console NF")

  ;; 2. 日本語・漢字すべてに PlemolJP を適用して別フォントの混入を防ぐ
  (dolist (charset '(japanese-jisx0208 japanese-jisx0213.2004-1 katakana-jisx0201 han cjk-misc))
    (set-fontset-font t charset (font-spec :family "PlemolJP Console NF")))

  ;; 3. アイコン領域は Symbols Nerd Font Mono があれば優先し、なければ PlemolJP を使う
  (set-fontset-font t 'symbol
                    (font-spec :family (if (find-font (font-spec :name "Symbols Nerd Font Mono"))
                                           "Symbols Nerd Font Mono"
                                         "PlemolJP Console NF"))
                    nil 'prepend))

;; --- UI 設定 (macOS) ---
(leaf ns
  :doc "next/open/gnustep / macos communication module"
  :when (eq window-system 'ns)
  :custom ((ns-control-modifier . 'control)
           (ns-option-modifier . 'super)
           (ns-command-modifier . 'meta)
           (ns-right-control-modifier . 'control)
           (ns-right-option-modifier . 'hyper)
           (ns-right-command-modifier . 'meta)
           (default-frame-alist . '((ns-appearance . dark)
                                    (ns-transparent-titlebar . t)))))

(leaf nerd-icons
  ;; 初回起動時、Emacs 上で M-x nerd-icons-install-fonts を実行すると
  ;; 必要なフォント (SymbolsNerdFontMono-Regular.ttf) が自動インストールされます。
  ;;
  ;; ※ 手動で導入する場合:
  ;; [Debian]
  ;;   mkdir -p ~/.local/share/fonts && cd ~/.local/share/fonts
  ;;   curl -fLo "SymbolsNerdFontMono-Regular.ttf" https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/NerdFontsSymbolsOnly/SymbolsNerdFontMono-Regular.ttf
  ;;   fc-cache -f -v
  ;;
  ;; [macOS]
  ;;   mkdir -p ~/Library/Fonts && cd ~/Library/Fonts
  ;;   curl -fLo "SymbolsNerdFontMono-Regular.ttf" https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/NerdFontsSymbolsOnly/SymbolsNerdFontMono-Regular.ttf
  ;;   (導入後に反映されない場合は macOS の再起動を試す)
  :ensure t)

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
            (debug-on-error . nil)
            (init-file-debug . nil)
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
            (indent-tabs-mode . nil)
            ;; Emacs 28+ 標準の y/n 短縮回答設定 (macOS の native-comp エラー回避)
            (use-short-answers . t))
  :config
  (keyboard-translate ?\C-h ?\C-?))

(leaf autorevert
  :doc "revert buffers when files on disk change"
  :global-minor-mode global-auto-revert-mode)

(leaf delsel
  :doc "delete selection if you insert"
  :global-minor-mode delete-selection-mode)

(leaf electric-pair-mode
  :doc "Automatically insert matching pairs of parentheses"
  :tag "builtin"
  :global-minor-mode electric-pair-mode)

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

;; --- フォルダ閲覧・ファイル管理 (Dired) ---
(leaf dired
  :doc "Directory editor"
  :tag "builtin"
  :custom
  ;; dired でフォルダを先頭にまとめ、見やすくする
  (dired-listing-switches . "-alFh --group-directories-first")
  :config
  ;; [macOS] 日本語の列幅計算が正確な GNU ls (gls) を使う
  (when (eq system-type 'darwin)
    (let ((gls (executable-find "gls")))
      (when gls
        (setq insert-directory-program gls)))))


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
         ("C-s" . c/consult-line)
         ("C-M-s" . nil)
         ("C-M-s s" . isearch-forward)
         ("C-M-s C-s" . isearch-forward-regexp)
         ("C-M-s c" . consult-ripgrep)
         (minibuffer-local-map
          :package emacs
          ("C-r" . consult-history))))

(leaf consult-flycheck
  :ensure t
  :after (consult flycheck)
  :bind (("M-g f" . consult-flycheck)))

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
  :custom
  ;; Org-mode では Flycheck を動かさない（表示高速化）
  (flycheck-global-modes . '(not org-mode))
  :config
  (with-eval-after-load 'flycheck
    (when (executable-find "hlint")
      (flycheck-add-next-checker 'haskell-ghc 'haskell-hlint))))

;; --- Tree-sitter (構文解析・高度なハイライト) ---
(leaf treesit
  :doc "Built-in Tree-sitter core settings"
  :custom
  ;; 4は最高レベルのハイライト（変数、属性、プロパティまで細かく色付け）
  (treesit-font-lock-level . 4))

(leaf treesit-auto
  :doc "Automatically install and use tree-sitter major modes"
  :ensure t
  :global-minor-mode global-treesit-auto-mode
  :custom
  ;; t にするとOrgのコードブロック表示時に裏でビルドが走り固まるため 'prompt にする
  (treesit-auto-install . 'prompt)
  :config
  ;; 対応しているすべての言語で自動的に ts-mode を有効化する
  (treesit-auto-add-to-auto-mode-alist 'all))

;; --- LSP コアクライアント ---
(leaf lsp-mode
  :ensure t
  :preface
  ;; Org等のコードブロック色付け用一時バッファ（ファイル実体なし）ではLSPや保存時Hookを起動しない関数
  (defun c/lsp-deferred-if-file ()
    "Start `lsp-deferred' only when the buffer is visiting a real file."
    (when buffer-file-name
      (lsp-deferred)))

  (defun c/setup-lsp-save-hooks ()
    "Setup format and organize-imports on save only for real file buffers."
    (when buffer-file-name
      (add-hook 'before-save-hook (lambda () (when (fboundp 'lsp-format-buffer) (lsp-format-buffer))) nil t)
      (add-hook 'before-save-hook (lambda () (when (fboundp 'lsp-organize-imports) (lsp-organize-imports))) nil t)))
  :custom ((lsp-keep-workspace-alive . nil)
           (lsp-signature-auto-activate . t)
           (lsp-keymap-prefix . "C-c l")
           (lsp-diagnostics-provider . :flycheck)
           (lsp-completion-provider . :capf)
           (lsp-before-save-hook . nil))
  :bind ((lsp-mode-map
          ("C-c r"   . lsp-rename)
          ("C-c C-a" . lsp-execute-code-action))) ; C-c a (org-agenda) との競合を回避
  :hook (;; Python / Haskell 用の安全な保存時自動フック（実ファイルのみ対象）
         (python-mode-hook . c/setup-lsp-save-hooks)
         (python-ts-mode-hook . c/setup-lsp-save-hooks)
         (haskell-mode-hook . c/setup-lsp-save-hooks)))

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
  ;; OSに ghc / cabal / stack がある環境でのみ有効化
  :when (or (executable-find "ghc") (executable-find "cabal") (executable-find "stack"))
  :after (flycheck haskell-mode)
  :hook (haskell-mode-hook . (lambda ()
                               ;; Orgの色付け用一時バッファでは実行しない
                               (when buffer-file-name
                                 (flycheck-haskell-setup)))))

(leaf lsp-haskell
  :ensure t
  ;; OSに HLS がある環境でのみ有効化
  :when (or (executable-find "haskell-language-server-wrapper")
            (executable-find "haskell-language-server"))
  :after haskell-mode lsp-mode
  :hook (haskell-mode-hook . c/lsp-deferred-if-file))

;; --- Python 開発環境 ---
(leaf pyvenv
  :ensure t
  :when (executable-find "python3")
  :config
  (add-hook 'pyvenv-post-activate-hook #'lsp-restart-workspace))

(leaf python
  :doc "Python editing mode (mode association handled by treesit-auto)"
  :tag "builtin" "languages"
  :custom ((python-indent-offset . 4)))

;; lsp-pyright や lsp-ruff も ts-mode かつ実ファイルのみで起動させる
(leaf lsp-pyright
  :ensure t
  :when (or (executable-find "pyright") (executable-find "python3"))
  :after lsp-mode
  :custom ((lsp-pyright-multi-root . t))
  :hook ((python-mode-hook python-ts-mode-hook) . c/lsp-deferred-if-file))

(leaf lsp-ruff
  :when (or (executable-find "ruff") (executable-find "python3"))
  :after lsp-mode
  :hook ((python-mode-hook python-ts-mode-hook) .
         (lambda ()
           (when buffer-file-name
             (require 'lsp-ruff nil t)
             (lsp-deferred)))))

(leaf cape-python
  :after cape
  :hook ((python-mode-hook python-ts-mode-hook) .
         (lambda ()
           (when buffer-file-name
             (add-hook 'completion-at-point-functions #'cape-dabbrev nil t)))))

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
  (sql-connection-candidate . 'my-mariadb))

;; --- ドキュメント (Markdown) ---
(leaf markdown-mode
  :ensure t
  :mode (("\\.md\\'" . gfm-mode)
         ("\\.markdown\\'" . gfm-mode))
  :hook (markdown-mode-hook . visual-line-mode)
  :bind ((markdown-mode-map
          ("C-c t" . markdown-toggle-markup-hiding)))
  :custom ((markdown-hide-markup . nil)
           (markdown-fontify-code-blocks-natively . t)
           ;; Debian / macOS 環境でのプレビュー用 (※事前に pandoc のインストールが必要です)
           (markdown-command . "pandoc -f gfm -t html5 -s")))

(leaf markdown-toc
  :ensure t
  :after markdown-mode
  :bind ((markdown-mode-map
          ("C-c C-t" . markdown-toc-generate-or-refresh))))

;; --- Org-mode (シンプルなメモ・タスク管理) ---
;; Markdown 形式で保存する操作手順
;; Markdown に変換したい .org ファイルを開いた状態で以下のショートカットキーを順番に押します。
;;   C-c C-e を押す -> 「Export Dispatcher」メニュー画面がポップアップ
;;   m を押す       -> 「Export to Markdown」を選択
;;   さらに m を押す -> 「To file」が選択され、エクスポートが実行されます。
(leaf org
  :doc "Outline-based notes management and organizer"
  :require ox-md                  ; Markdownへのエクスポート機能を有効化
  :bind (("C-c c" . org-capture)  ; どこからでも一発でメモ・日記を起動
         ("C-c a" . org-agenda))  ; スケジュール・TODO一覧を起動
  :custom
  ((org-startup-indented . t)     ; 見出しの深さに合わせてテキストを字下げして綺麗に表示
   (org-hide-leading-stars . t)   ; 階層の星(*)をすっきり見せる（一番右の星だけ表示）
   (org-log-done . 'time))        ; DONE に切り替えた瞬間に、完了したタイムスタンプを自動記録
  :hook
  (org-mode-hook . visual-line-mode)
  :config
  ;; 日付タイムスタンプ (C-c .) の曜日表記を OS 問わず日本語 (月, 火...) に統一する
  (setq system-time-locale "ja_JP.UTF-8")

  ;; 1. OSごとにGitHubリポジトリ（Orgフォルダ）のパスを切り替える
  (setq org-directory
        (if (eq system-type 'darwin)
            "~/Documents/works/Org-mode/"   ; [macOS]  実際のフォルダパスに変更
            "~/works/Org-mode/"))           ; [Debian] 実際のフォルダパスに変更

  ;; 2. org-directory を基準にファイルパスを自動生成（ここは書き換え不要）
  (setq org-default-notes-file (expand-file-name "diary.org" org-directory))
  (setq org-agenda-files (list org-directory))

  ;; 3. Org-capture のテンプレート（ファイル名だけ書けば自動で org-directory 内を参照します）
  (setq org-capture-templates
        '(("d" "日記 (Diary)" entry
           (file+olp+datetree "diary.org")
           "* %?\n  %U\n" :empty-lines 1)
          ("t" "タスク (TODO)" entry
           (file+headline "diary.org" "Tasks")
           "* TODO %?\n  SCHEDULED: %t\n"))))

;; --- テーブルのピクセル単位補正 (Debian のみ自動 / macOS は手動) ---
(leaf valign
  :doc "Pixel-perfect visual alignment for Org and Markdown tables"
  :ensure t
  :commands (valign-mode)
  :custom
  ;; 縦の罫線(|)を隙間なく綺麗に繋げて表示する（お好みで nil にしてもOKです）
  (valign-fancy-bar . t)
  :init
  ;; [Debian] macOS (darwin) 以外の環境でのみ、Org と Markdown で自動的に valign-mode を有効化する
  ;; [macOS]  表示遅延を防ぐため自動 Hook は外し、必要な時だけ M-x valign-mode で呼ぶ
  (unless (eq system-type 'darwin)
    (add-hook 'org-mode-hook #'valign-mode)
    (add-hook 'markdown-mode-hook #'valign-mode)))

;; --- 集中執筆モード (ブログ特化) ---
(leaf olivetti
  :doc "Minor mode for a nice writing environment"
  :ensure t
  ;; Markdownを開いた時に自動で中央寄せの集中モードにする
  :hook (markdown-mode-hook . olivetti-mode)
  :custom ((olivetti-body-width . 80))) ;; 1行の幅を80文字（日本語なら約40文字）に固定

;; --- バージョン管理 (Git) ---
(leaf magit
  :doc "A Git porcelain for Emacs"
  :tag "git" "tools"
  :ensure t
  :bind (("C-x g" . magit-status)
         ("C-x M-g" . magit-dispatch)
         ("C-c L" . magit-log-buffer-file))
  :custom (magit-display-buffer-function . 'magit-display-buffer-fullcolumn-most-v1))

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
