(defun pc (&optional event)
"Mark notable days in the calendar window.
If EVENT is non-nil, it's an event indicating the buffer position to
use instead of point."
  (interactive (list last-nonmenu-event))
  (message "Marking productive chain...")
  (setq temp (split-string (buffer-string) "\n" t))
  (calendar)

;  (setq temp
;    (with-temp-buffer
;      (insert-file-contents "F:/ProductiveChain/R_Webpage.txt")
;      (split-string (buffer-string) "\n" t)))

  (dolist (d temp)
    (calendar-mark-visible-date (read (concat "(" d ")")) calendar-holiday-marker))
  (message "Marking productive chain...done"))

(defun get-filename ()
  "Cursor must be inside [[..]] to work."
  (search-backward "[[")
  (re-search-forward "\\[\\[.+\\/\\(.+\\)\\]\\]" nil nil 1)
  (match-string 1))

(defun get-url ()
  (interactive)
  (let ((o (point))
        (s (search-backward "[["))
        (e (search-forward "]]")))
    (goto-char o)
    (setq s (+ s 2))
    (setq e (- e 2))
    (buffer-substring s e)))

(defun myorg-open-at-point ()
  (interactive)
  ;(get-url)
  ;(w32-shell-execute "open" (replace-regexp-in-string "/" "\\" (get-url) t t)))
  ;(message (concat "F:\\app\\imv_light.exe "
  ;  (replace-regexp-in-string "/" "\\" (get-url) t t)))
  ;(w32-shell-execute "open" "F:\\app\\imv_light.exe")
  ;(call-process-shell-command (get-url)))
  (w32-shell-execute "open" "F:\\app\\imv_light.exe"
    (replace-regexp-in-string "/" "\\" (get-url) t t)))
;  (call-process-shell-command (concat "F:\\app\\imv_light.exe " (replace-regexp-in-string "/" "\\" (get-url) t t))))

(defun get-latest-clip ()
"Get latest screen clip filename"
  (car (last (directory-files "F:\\clipboard\\"))))

(defun myorg-get-body ()
"Retrieve body content in org html export without tag <body>."
  (interactive)
  (delete-region (point-min) (search-forward "<body>"))
  (delete-region (search-backward "</body>") (point-max)))

(defun post-to-blogspot ()
  (interactive)
)

(defun myorg-copy-file-local ()
  (interactive)
  (let ((tfn (file-name-sans-extension (buffer-file-name)))
        (u (get-url))
        (f (get-filename)))
    (if (not (file-exists-p tfn))
      (make-directory tfn))
    ;(url-copy-file u (concat tfn "/" f))
    (let ((default-directory tfn))
      (call-process-shell-command "G:\\wget-1.11.4-1-bin\\bin\\wget.exe"
        nil nil nil u))
    (end-of-line)
    (insert (concat "\n[[" tfn "/" f "]]"))))

;    (if (file-exists-p filename)
;      (copy-file tfn filename)
;      (delete-file filename))
;    (insert (concat tfn filename))))

;(global-set-key (kbd "C-q") 'ttt)
(global-set-key (kbd "C-q") 'myorg-copy-file-local)
(global-set-key (kbd "C-o") 'myorg-open-at-point)

; eof
