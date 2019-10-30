;;; yaml-mode-ext.el --- Extension for yaml-mode. -*- lexical-binding: t -*-

;; Author: Takayuki Sato <takayuki.sato.dev@gmail.com>
;; URL: https://github.com/lerouxrgd/yaml-mode-ext
;; Version: 0.1.0
;; Package-Requires: ((emacs "26.2") (yaml-mode "0.0.14"))
;; Keywords: yaml, yaml-mode

;; This file is not part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see
;; <https://www.gnu.org/licenses/>.

;;; Commentary:

;;; Extension for yaml-mode.

;;; Code:

(require 'yaml-mode)

(defun yaml-blank-line-p ()
  "Return non-nil if and only if current line is blank."
  (save-excursion
    (beginning-of-line)
    (looking-at "\\s-*$")))

(defun yaml-comment-line-p ()
  "Return non-nil if and only if current line has only a comment."
  (save-excursion
    (end-of-line)
    (when (eq 'comment (syntax-ppss-context (syntax-ppss)))
      (back-to-indentation)
      (looking-at (rx (or (syntax comment-start) line-end))))))

(defun yaml-beginning-of-block (&optional _arg)
  "Go to the beginning of a block."
  (interactive "p")
  (let ((this-level (current-indentation)))
    (unless (eql 0 this-level)
      (while (and (zerop (forward-line -1))
                  (or (<= this-level (current-indentation))
                      (yaml-comment-line-p)
                      (yaml-blank-line-p)))))
    (back-to-indentation)))

(defun yaml-end-of-block (&optional _arg)
  "Go to the end of a block."
  (interactive "p")
  (let ((this-level (current-indentation)))
    (while (and (zerop (forward-line))
                (or (<= this-level (current-indentation))
                    (yaml-comment-line-p)
                    (yaml-blank-line-p)))))

  (forward-line -1)
  (end-of-line))

(defun yaml-down-block (&optional _arg)
  "Go to the next block down."
  (interactive "p")
  (let ((this-level (current-indentation))
        (orig (point)))
    (while (and (zerop (forward-line))
                (or (yaml-comment-line-p)
                    (yaml-blank-line-p))))
    (if (< this-level (current-indentation))
        (back-to-indentation)
      (goto-char orig))))

(defun yaml-previous-block (&optional _arg)
  "Go to the previous block."
  (interactive "p")
  (let ((this-level (current-indentation))
        (orig (point)))
    (while (and (zerop (forward-line -1))
                (or (< this-level (current-indentation))
                    (yaml-comment-line-p)
                    (yaml-blank-line-p))))
    (if (eql this-level (current-indentation))
        (back-to-indentation)
      (goto-char orig))))

(defun yaml-next-block (&optional _arg)
  "Go to the next block."
  (interactive "p")
  (let ((this-level (current-indentation))
        (orig (point)))
    (while (and (zerop (forward-line))
                (or (< this-level (current-indentation))
                    (yaml-comment-line-p)
                    (yaml-blank-line-p))))
    (if (eql this-level (current-indentation))
        (back-to-indentation)
      (goto-char orig))))

(define-key yaml-mode-map (kbd "M-C-f") 'yaml-next-block)
(define-key yaml-mode-map (kbd "M-C-b") 'yaml-previous-block)
(define-key yaml-mode-map (kbd "M-C-u") 'yaml-beginning-of-block)
(define-key yaml-mode-map (kbd "M-C-d") 'yaml-down-block)
(define-key yaml-mode-map (kbd "M-C-e") 'yaml-end-of-block)

(provide 'yaml-mode-ext)
;;; yaml-mode-ext.el ends here
