;;; comware-router-mode.el --- Major mode for editing Comware configuration files

;; Copyright (C) 2019 Davide Restivo

;; Author: Davide Restivo <davide.restivo@yahoo.it>
;; Maintainer: Davide Restivo <davide.restivo@yahoo.it>
;; Version: 0.1
;; URL: https://github.com/daviderestivo/comware-router-mode
;; Package-Requires: ((emacs "24.3"))
;; Keywords: convenience faces

;;; Commentary:
;;
;;  A major mode for editing Comware router and switches configuration
;;  file.

;;; License:
;;
;; This file is NOT part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;

;;; Change Log:
;; 0.1 - 2019/07/25 - First version
;; 0.2 - 2019/08/04 - Add VRFs, interfaces, route-policies listing functions

;;; Code:


(require 'dash)
(require 'button)

;; Hook
(defvar comware-router-mode-hook nil
  "Hook called by \"comware-router-mode\"")

(defvar comware-router-mode-map
  (let
      ((comware-router-mode-map (make-keymap)))
    (define-key comware-router-mode-map "\C-j"   'newline-and-indent)
    (define-key comware-router-mode-map "\C-c l v" 'comware-router-vrf-list)
    (define-key comware-router-mode-map "\C-c l i" 'comware-router-interfaces-list)
    (define-key comware-router-mode-map "\C-c l r" 'comware-router-route-policies-list)
    comware-router-mode-map)
  "Keymap for Comware router configuration major mode")

;; Font locking definitions
(defvar comware-router-ipadd-face 'comware-router-ipadd-face "Face for IP addresses")
(defface comware-router-ipadd-face
  '((t :inherit font-lock-constant-face))
  "Face for IP addresses"
  :group 'comware-router-mode)

(defvar comware-router-service-command-face 'comware-router-service-command-face "Face for router service commands")
(defface comware-router-service-command-face
  '((t :inherit font-lock-keyword-face))
  "Face for router service commands"
  :group 'comware-router-mode)

(defvar comware-router-command-face 'comware-router-command-face "Face for router commands")
(defface comware-router-command-face
  '((t :inherit font-lock-constant-face))
  "Face for router commands"
  :group 'comware-router-mode)

(defvar comware-router-undo-face 'comware-router-undo-face "Face for \"undo\"")
(defface comware-router-undo-face
  '(
    (t (:underline t))
    )
  "Face for \"undo\""
  :group 'comware-router-mode)

(defconst comware-router-font-lock-keywords
  (let* (
         ;; Define categories of commands
         (comware-router-command '("arp"
                                   "clock"
                                   "domain"
                                   "http"
                                   "https"
                                   "hwtacacs"
                                   "info-center"
                                   "license"
                                   "line"
                                   "local-user"
                                   "ntp-service"
                                   "password-recovery"
                                   "return"
                                   "role"
                                   "scheduler"
                                   "scp"
                                   "sftp"
                                   "snmp-agent"
                                   "ssh"
                                   "sysname"
                                   "user-group"
                                   "version"))
         (comware-router-service-command  '("acl"
                                            "address-family"
                                            "bgp"
                                            "dhcp"
                                            "dhcp policy"
                                            "dhcp server"
                                            "dns"
                                            "interface"
                                            "ip community-list"
                                            "ip prefix-list"
                                            "ip route-static"
                                            "ip vpn-instance"
                                            "nqa"
                                            "ospf"
                                            "rip"
                                            "route-policy"
                                            "rtm"
                                            "vsi"))
         ;; Generate regexp strings for each category of commands
         (comware-router-command-regexp         (concat "^[[:space:]]*"
                                                        (regexp-opt comware-router-command 'word)
                                                        "\\([[:space:][:alnum:][:graph:]]*\\)"))
         (comware-router-service-command-regexp (concat "^[[:space:]]*"
                                                        (regexp-opt comware-router-service-command 'words)
                                                        "\\([[:space:][:alnum:][:graph:]]*\\)")))
    `(
      (,comware-router-command-regexp 1 comware-router-command-face)
      (,comware-router-command-regexp 2 font-lock-function-name-face)
      (,comware-router-service-command-regexp  1 comware-router-service-command-face)
      (,comware-router-service-command-regexp  2 font-lock-function-name-face)
      ("\\<\\(undo [[:space:][:alnum:][:graph:]]*\\)\\>" 1 comware-router-undo-face)
      ("\\<\\([0-9]\\{1,3\\}\\.[0-9]\\{1,3\\}\\.[0-9]\\{1,3\\}\\.[0-9]\\{1,3\\}\\)\\>" 1 comware-router-ipadd-face)
      "Font locking definitions for comware router mode")))

;; Imenu
(defvar comware-router-imenu-expression
  '(
    ("Interfaces"        "^[\t ]*interface *\\(.*\\)" 1)
    ("VRFs"              "^ip vpn-instance *\\(.*\\)" 1)
    ("Routing protocols" "\\(^bgp [0-9]*\\|^ospf [0-9]*\\|^rip [0-9]*\\)" 1)
    ))

;; Indentation
(defun comware-router-indent-line ()
  "Indent current line as comware router config line"
  (indent-relative-first-indent-point))

;; Regexp match
(defun comware-router--match-regexp-in-buffer (regexp regexp-group)
  "Return a list of cons cells matching REGEXP and the given REGEXP-GROUP.
The returned list's elements have the following structure:

(POS . TEXT-PLIST)

E.g.:
((261 . #(\"VRF-1\" 0 5 (fontified t face font-lock-function-name-face)))
 (423 . #(\"VRF-2\" 0 5 (fontified t face font-lock-function-name-face))))

where POS is the position of the match in the original buffer,
and TEXT-PLIST is the matched string with faces information."
  (interactive)
  (let ((matches)
        (-compare-fn '(lambda (ele1 ele2)
                        (equal
                         (substring-no-properties (cdr ele1))
                         (substring-no-properties (cdr ele2))))))
    (save-match-data
      (save-excursion
        (with-current-buffer (current-buffer)
          (save-restriction
            (widen)
            (beginning-of-buffer)
            (while (search-forward-regexp regexp nil t 1)
              (push `(,(point) . ,(match-string regexp-group)) matches))))))
    (reverse (-sort -compare-fn (-uniq matches)))))

(defun comware-router--write-output-in-destination-buffer (texts-plists source-buffer destination-buffer)
  "Write TEXT-PLISTS in DESTINATION-BUFFER, creating a link for
each entry to SOURCE-BUFFER."
  (set-buffer
   (get-buffer-create destination-buffer))
  (dolist (ele texts-plists)
    (comware-router--insert-text-buttons ele source-buffer))
  (set-buffer-modified-p nil)
  (split-window-below)
  (other-window 0)
  (switch-to-buffer destination-buffer)
  (local-set-key (kbd "q") (lambda () (interactive)
                             (kill-this-buffer)
                             (delete-window))))

(defun comware-router--insert-text-buttons (texts-plist source-buffer)
  (insert-button (substring-no-properties (cdr texts-plist))
                 'original-buffer source-buffer
                 'text-plists text-plists
                 'action (lambda (x)
                           (print (button-get x 'source-buffer))
                           (switch-to-buffer (button-get x 'source-buffer))
                           (goto-char (car (button-get x 'texts-plist)))))
  (newline))

;; Show VRFs
(defun comware-router-vrf-list ()
  "List all VRFs in a new buffer called \"*Comware: vpn-instances*\""
  (interactive)
  (comware-router--write-output-in-new-buffer
   (comware-router--match-regexp-in-buffer "^ip vpn-instance \\(.*\\)" 1) ; Matches
   (buffer-name (current-buffer)) ; Source buffer
   "*Comware: vpn-instances*"))   ; Destination buffer

;; Show route policies
(defun comware-router-route-policies-list ()
  "List all route policies in a new buffer called \"*Comware: route-policies*\""
  (interactive)
  (comware-router--write-output-in-new-buffer
   (comware-router--match-regexp-in-buffer "^route-policy \\([[:alnum:]][[:graph:]]*\\) \\(.*\\)" 1) ; Matches
   (buffer-name (current-buffer))  ; Source buffer
   "*Comware: route-policies*"))   ; Destination buffer

;; Show interfaces
(defun comware-router-interfaces-list ()
  "List all interfaces in a new buffer called \"*Comware: interfaces*\""
  (interactive)
  (comware-router--write-output-in-new-buffer
   (comware-router--match-regexp-in-buffer "^interface \\(.*\\)" 1) ; Matches
   (buffer-name (current-buffer)) ; Source buffer
   "*Comware: interfaces*"))      ; Destination buffer

;; Custom syntax table
(defvar comware-router-mode-syntax-table (make-syntax-table)
  "Syntax table for comware router mode")
(modify-syntax-entry ?_  "w" comware-router-mode-syntax-table) ; All _'s are part of words.
(modify-syntax-entry ?:  "w" comware-router-mode-syntax-table) ; All :'s are part of words.
(modify-syntax-entry ?-  "w" comware-router-mode-syntax-table) ; All -'s are part of words.
(modify-syntax-entry ?#  "<" comware-router-mode-syntax-table) ; All #'s start comments.
(modify-syntax-entry ?\n ">" comware-router-mode-syntax-table) ; All newlines end comments.
(modify-syntax-entry ?\r ">" comware-router-mode-syntax-table) ; All linefeeds end comments.

;; Entry point
;;;###autoload
(defun comware-router-mode  ()
  "Major mode for editing Comware routers/switches configuration files"
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table comware-router-mode-syntax-table)
  (use-local-map comware-router-mode-map)
  (set (make-local-variable 'font-lock-defaults) '(comware-router-font-lock-keywords))
  (set (make-local-variable 'indent-line-function) 'comware-router-indent-line)
  (set (make-local-variable 'comment-start) "#")
  (set (make-local-variable 'comment-start-skip) "\\(\\(^\\|[^\\\\\n]\\)\\(\\\\\\\\\\)*\\)#+ *")
  (setq imenu-case-fold-search t)
  (set (make-local-variable 'imenu-generic-expression) comware-router-imenu-expression)
  (imenu-add-to-menubar "Comware")
  (setq major-mode 'comware-router-mode
	mode-name "Comware")
  (run-hooks comware-router-mode-hook))

(add-to-list 'auto-mode-alist '("\\.cmw\\'" . comware-router-mode))

(provide 'comware-router-mode)

;;; comware-router-mode.el ends here
