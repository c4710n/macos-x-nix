;;; vterm-tab.el -*- lexical-binding: t; -*-

;;; Code:
(require 'vterm)

(define-minor-mode vterm-tab-mode
  "Toggle vterm-tab mode."
  :init-value nil
  :keymap nil
  (setq-local tab-line-tabs-function 'vterm-tab--buffers-get)
  (setq-local tab-line-new-button-show nil)
  (setq-local tab-line-close-button-show nil))

(defun vterm-tab-toggle()
  (interactive)
  (let* ((recent-buffer (vterm-tab--recent-buffer-get))
         (buffer-window (if recent-buffer (get-buffer-window recent-buffer))))
    (if buffer-window
        (delete-window buffer-window)
      (if recent-buffer
          (switch-to-buffer-other-window recent-buffer)
        (vterm-tab-create t)))))

(defun vterm-tab-create (&optional other-window silent)
  (interactive)
  (let ((buffer (vterm-tab-get-buffer silent)))
    (set-buffer buffer)
    (vterm-tab-setup-buffer buffer)
    (if other-window
        (switch-to-buffer-other-window buffer)
      (switch-to-buffer buffer))))

(defun vterm-tab-rename ()
  (interactive)
  (let* ((name (read-string "Rename current tab with name: "))
         (formatted-name (vterm-tab-format-name name)))
    (rename-buffer formatted-name)))

(defun vterm-tab-switch (direction &optional offset)
  "Switch to buffer accorrding to NAMESPACE, DIRECTION, OFFSET."
  (let* ((buffer-list (vterm-tab--buffers-get))
         (buffer-list-len (length buffer-list))
         (buffer-index (cl-position (current-buffer) buffer-list)))
    (if buffer-index
        (let* ((target-buffer-index (if (eq direction 'NEXT)
                                        (mod (+ buffer-index 1) buffer-list-len)
                                      (mod (- buffer-index 1) buffer-list-len)))
               (target-buffer (nth target-buffer-index buffer-list)))
          (switch-to-buffer target-buffer)))))

(defun vterm-tab-prev-tab ()
  (interactive)
  (vterm-tab-switch 'PREV))

(defun vterm-tab-next-tab ()
  (interactive)
  (vterm-tab-switch 'NEXT))

(defun vterm-tab-setup-buffer (buffer)
  (vterm-mode)
  (vterm-tab-mode)
  (tab-line-mode)
  (vterm-tab--buffers-list-put buffer)
  (add-hook 'kill-buffer-hook #'vterm-tab-cleanup-handler))

(defun vterm-tab-cleanup-handler ()
  (let ((killed-buffer (current-buffer)))
    (vterm-tab--buffers-list-del killed-buffer)))

(defun vterm-tab-change-buffer-handler (_buffer)
  (let ((buffer (current-buffer)))
    (when (with-current-buffer buffer (bound-and-true-p vterm-tab-mode))
      (vterm-tab--recent-buffer-put buffer)))

  (let ((recent-buffer (vterm-tab--recent-buffer-get)))
    (unless (buffer-live-p recent-buffer)
      (vterm-tab--recent-buffer-put nil))))

(add-to-list 'window-buffer-change-functions #'vterm-tab-change-buffer-handler)

(defun vterm-tab-get-buffer (&optional silent)
  (interactive)
  (let* ((name (if silent "general"
                 (read-string "Create vterm tab with name: " "general")))
         (formatted-name (vterm-tab-format-name name)))
    (generate-new-buffer formatted-name)))

(defvar vterm-tab--buffers '()
  "All buffers of vterm-tab.")

(defun vterm-tab--buffers-list-put (buffer)
  (let* ((current-list vterm-tab--buffers)
         (new-list (if (member buffer current-list)
                       current-list
                     (nconc current-list (list buffer)))))
    (setq vterm-tab--buffers new-list)))

(defun vterm-tab--buffers-list-del (buffer)
  (let* ((current-list vterm-tab--buffers)
         (new-list (delete buffer current-list)))
    (setq vterm-tab--buffers new-list)))

(defun vterm-tab--buffers-get ()
  vterm-tab--buffers)

(defvar vterm-tab--recent-buffer nil
  "The recent buffer of vterm-tab.")

(defun vterm-tab--recent-buffer-put (buffer)
  (setq vterm-tab--recent-buffer buffer))

(defun vterm-tab--recent-buffer-get ()
  vterm-tab--recent-buffer)

(defun vterm-tab-format-name (name)
  (format "-* %s *-" name))

(provide 'vterm-tab)
