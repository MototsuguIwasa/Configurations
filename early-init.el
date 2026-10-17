;; -*- lexical-binding: t -*-
;; macOS 27 (Golden Gate) でのlibgccjitによるバージョン誤計算を回避
;; early-init.el
(when (eq system-type 'darwin)
  (setenv "MACOSX_DEPLOYMENT_TARGET" "27.0"))
