;; -*- lexical-binding: t -*-
;; macOSでのlibgccjitによるバージョン誤計算を回避
;; 起動時のコンパイルエラーに対応
;; early-init.el
(when (eq system-type 'darwin)
  (setenv "MACOSX_DEPLOYMENT_TARGET"
          (or (getenv "MACOSX_DEPLOYMENT_TARGET")
              (string-trim (shell-command-to-string "sw_vers -productVersion")))))
