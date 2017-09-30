;;; mew-mule3.el --- Environment of Mule version 3 for Mew

;; Author:  Kazu Yamamoto <Kazu@Mew.org>
;; Created: Mar 20, 1997

;;; Code:

;; must be here
(if (fboundp 'find-coding-system)
    (defun mew-coding-system-p (cs)
      (if (null cs) t (find-coding-system cs)))
  (defun mew-coding-system-p (cs)
    (if (null cs) t (coding-system-p cs))))

;; In the context of Mew, 'charset' means MIME charset.
;; 'cs' means the internal representation of Emacs (was known as Mule).

;;
;; User CS definitions
;;

;; iso-2022-7bit-ss2 is iso-2022-jp-2

(cond
 (mew-xemacs-p
  (copy-coding-system 'no-conversion      'mew-cs-text)
  (copy-coding-system 'no-conversion-unix 'mew-cs-text-lf)
  (copy-coding-system 'no-conversion-dos  'mew-cs-text-crlf)
  (copy-coding-system 'no-conversion-mac  'mew-cs-text-cr)
  (copy-coding-system 'no-conversion-dos  'mew-cs-text-net)
  (defun mew-cs-raw-p (cs)
    (memq cs '(no-conversion no-conversion-unix no-conversion-dos no-conversion-mac))))
 (t
  (define-coding-system-alias 'mew-cs-text      'raw-text)
  (define-coding-system-alias 'mew-cs-text-lf   'raw-text-unix)
  (define-coding-system-alias 'mew-cs-text-crlf 'raw-text-dos)
  (define-coding-system-alias 'mew-cs-text-cr   'raw-text-mac)
  (define-coding-system-alias 'mew-cs-text-net  'raw-text-dos)
  (defun mew-cs-raw-p (cs)
    (memq cs '(raw-text raw-text-unix raw-text-dos raw-text-mac)))))

(defvar mew-cs-dummy          'binary)
(defvar mew-cs-binary         'binary)
(defvar mew-cs-text-for-read  'mew-cs-text)
(defvar mew-cs-text-for-write 'mew-cs-text-lf)
(defvar mew-cs-text-for-net   'mew-cs-text-net)
(defvar mew-cs-autoconv       'undecided)
;; ctext for consistency --unibyte, -unix for XEmacs's ^M
(defvar mew-cs-m17n (if (mew-coding-system-p 'ctext-unix) 'ctext-unix 'ctext))

(defvar mew-cs-eol "\n")
(defun mew-eol-fix-for-read () ())
(defun mew-eol-fix-for-write () ())

;; Latin 0 -- Nickname of Latin 9
;; Latin 1 -- ISO-8859-1   West European
;; Latin 2 -- ISO-8859-2   East European
;; Latin 3 -- ISO-8859-3   South European
;; Latin 4 -- ISO-8859-4   North European
;; Latin 5 -- ISO-8859-9   Turkish
;; Latin 6 -- ISO-8859-10  Nordic
;; Latin 7 -- ISO-8859-13  Baltic Rim
;; Latin 8 -- ISO-8859-14  Celtic
;; Latin 9 -- ISO-5589-15  New West European

;; ISO-8859-1  -- Latin 1  West European
;; ISO-8859-2  -- Latin 2  East European
;; ISO-8859-3  -- Latin 3  South European
;; ISO-8859-4  -- Latin 4  North European
;; ISO-8859-5  --          Cyrillic
;; ISO-8859-6  --          Arabic
;; ISO-8859-7  --          Greek
;; ISO-8859-8  --          Hebrew
;; ISO-8859-9  -- Latin 5  Turkish
;; ISO-8859-10 -- Latin 6  Nordic
;; ISO-8859-11 --          Thai
;; ISO-8859-12 --
;; ISO-8859-13 -- Latin 7  Baltic Rim
;; ISO-8859-14 -- Latin 8  Celtic
;; ISO-8859-15 -- Latin 9  New West European  (or Latin 0)

(defvar mew-charset-utf-8-encoding "base64")
(defvar mew-charset-utf-8-header-encoding "B")

(defvar mew-cs-database-for-encoding
  `(((ascii)                    nil         "7bit"             "7bit")
    ;; West European (Latin 1)
    ((ascii latin-iso8859-1)    iso-8859-1  "quoted-printable" "Q")
    ;; East European (Latin 2)
    ((ascii latin-iso8859-2)    iso-8859-2  "quoted-printable" "Q")
    ;; South European (Latin 3)
    ((ascii latin-iso8859-3)    iso-8859-3  "quoted-printable" "Q")
    ;; North European (Latin 4)
    ((ascii latin-iso8859-4)    iso-8859-4  "quoted-printable" "Q")
    ;; Cyrillic
    ((ascii cyrillic-iso8859-5) koi8-r      "quoted-printable" "Q")
    ;; Arabic
    ((ascii arabic-iso8859-6)   iso-8859-6  "base64"           "B")
    ;; Greek
    ((ascii greek-iso8859-7)    iso-8859-7  "base64"           "B")
    ;; Hebrew
    ((ascii hebrew-iso8859-8)   iso-8859-8  "base64"           "B")
    ;; Turkish (Latin 5)
    ((ascii latin-iso8859-9)    iso-8859-9  "quoted-printable" "Q")
    ;; Celtic (Latin 8)
    ((ascii latin-iso8859-14)   iso-8859-14 "quoted-printable" "Q") ;; xxx
    ;; New West European (Latin 9 or Latin 0)
    ((ascii latin-iso8859-15)   iso-8859-15 "quoted-printable" "Q")
    ((ascii thai-tis620 composition) ;; composition for Emacs 20
                                tis-620     "base64"           "B")
    ((ascii thai-xtis) ;; thai-xtis for XEmacs
                                tis-620     "base64"           "B")
    ((ascii latin-jisx0201 japanese-jisx0208 japanese-jisx0208-1978)
                               iso-2022-jp "7bit"             "B")
    ((ascii korean-ksc5601)     euc-kr     "8bit"             "B")
    ((ascii chinese-gb2312)     cn-gb-2312 "base64"           "B")
    ((ascii chinese-big5-1 chinese-big5-2)
                              chinese-big5 "base64"           "B")
    ((ascii japanese-jisx0208 japanese-jisx0213-1 japanese-jisx0213-2)
                             iso-2022-jp-3 "7bit"             "B")
    (nil utf-7 "7bit" "Q") ;; xxx
    (nil utf-8 ,mew-charset-utf-8-encoding ,mew-charset-utf-8-header-encoding)
    (nil iso-2022-jp-2 "7bit" "B")))

(defvar mew-cs-database-for-arg
  '((iso-2022-jp . euc-jp)
    (iso-2022-kr . euc-kr)))

(if (and (not (mew-coding-system-p 'chinese-big5))
	 (mew-coding-system-p 'big5))
    (define-coding-system-alias 'chinese-big5 'big5))

(defvar mew-cs-database-for-decoding
  '(("us-ascii"        . nil)
    ("iso-8859-1"      . iso-8859-1)
    ("iso-8859-2"      . iso-8859-2)
    ("iso-8859-3"      . iso-8859-3)
    ("iso-8859-4"      . iso-8859-4)
    ("iso-8859-5"      . iso-8859-5)
    ("iso-8859-6"      . iso-8859-6)
    ("iso-8859-7"      . iso-8859-7)
    ("iso-8859-8"      . iso-8859-8)
    ("iso-8859-9"      . iso-8859-9)
    ("iso-8859-15"     . iso-8859-15)
    ("iso-2022-cn"     . iso-2022-cn)
    ("iso-2022-cn-ext" . iso-2022-cn-ext)
    ("gb2312"          . cn-gb-2312) ;; should be before cn-gb
    ("cn-gb"           . cn-gb-2312)
    ("hz-gb-2312"      . hz-gb-2312)
    ("big5"            . chinese-big5)
    ("cn-big5"         . chinese-big5)
    ("iso-2022-kr"     . iso-2022-kr)
    ("euc-kr"          . euc-kr)
    ("ks_c_5601-1987"  . euc-kr)
    ("iso-2022-jp"     . iso-2022-jp)
    ("iso-2022-jp-2"   . iso-2022-jp-2)
    ("iso-2022-jp-3"   . iso-2022-jp-3)
    ("euc-jp"          . euc-japan)
    ("shift_jis"       . shift_jis)
    ("koi8-r"          . koi8-r)
    ("windows-1250"    . cp1250)
    ("windows-1251"    . cp1251)
    ("windows-1252"    . cp1252)
    ("windows-1253"    . cp1253)
    ("windows-1254"    . cp1254)
    ("windows-1255"    . cp1255)
    ("windows-1256"    . cp1256)
    ("windows-1257"    . cp1257)
    ("windows-1258"    . cp1258)
    ("tis-620"         . tis-620)
    ("iso-2022-int-1"  . iso-2022-int-1)
    ("utf-7"           . utf-7)
    ("utf-8"           . utf-8)))

;;
;; CS
;;

(defalias 'mew-find-cs-region 'find-charset-region)

;; to internal
(defun mew-cs-decode-region (beg end cs)
  (if cs (decode-coding-region beg end cs)))

;; to extenal
(defun mew-cs-encode-region (beg end cs)
  (if cs (encode-coding-region beg end cs)))

;; to internal
;;(defun mew-cs-decode-string (str cs)
;;  (if cs (decode-coding-string str cs) str))

;; This code should be obsoleted when Mule 4.1 goes away.
(defun mew-cs-decode-string (str cs)
  (if (null cs)
      str
    (let ((post-conv (coding-system-post-read-conversion cs)))
      (if (null post-conv)
	  (decode-coding-string str cs)
	;; Mule 4.1 (Emacs 20.7 + Mule-UCS-0.84) has a bug.
	;; It applys post-conv just to a buffer, not to a string.
	;; So, we should use a buffer.
	(with-temp-buffer
	  ;; The old base64-decode-string() returns a multibyte string.
	  ;; The new base64-decode-string() returns a unibyte string.
	  (mew-set-buffer-multibyte (mew-multibyte-string-p str))
	  (insert str)
	  (or (mew-multibyte-string-p str) (mew-set-buffer-multibyte t))
	  (decode-coding-region (point-min) (point-max) cs)
	  (buffer-substring (point-min) (point-max))))))) ;; xxx

;; to external
(defun mew-cs-encode-string (str cs)
  (if cs (encode-coding-string str cs) str))

;;
;; Process environment
;;

(defsubst mew-set-process-cs (process read write)
  (set-process-coding-system process read write))

(defsubst mew-set-buffer-cs (write)
  (setq buffer-file-coding-system write))

(defmacro mew-plet (&rest body)
  `(let ((coding-system-for-read  'binary)
	 (coding-system-for-write 'binary))
     ,@body))

(defmacro mew-piolet (read write &rest body)
  `(let ((coding-system-for-read  ,read)
	 (coding-system-for-write ,write))
     ,@body))

(defmacro mew-flet (&rest body)
  `(let ((coding-system-for-read  'binary)
	 (coding-system-for-write 'binary)
	 (format-alist nil)
	 (auto-image-file-mode nil)
	 (jka-compr-inhibit t))
     ,@body))

(defmacro mew-frwlet (read write &rest body)
  `(let ((coding-system-for-read  ,read)
	 (coding-system-for-write ,write)
	 (format-alist nil)
	 (auto-image-file-mode nil)
	 (jka-compr-inhibit t))
     ,@body))

(defmacro mew-alet (&rest body)
  `(let ((default-file-name-coding-system nil)
	 (file-name-coding-system nil))
     ,@body))

;;
;;
;;

(defun mew-substring (str width &optional cnt nopad)
  (let ((sw (if (null str) 0 (string-width str)))
	(i 0) (w 0) cw safe-w)
    (condition-case nil
	(cond
	 ((= sw width)
	  str)
	 ((< sw width)
          (if nopad
              str
            (concat str (make-string (- width sw) 32))))
	 (t
	  (if cnt (setq width (- width 2)))
	  (catch 'loop
	    (while t
	      (setq cw (char-width (aref str i)))
	      (if (> (+ w cw) width)
		  (throw 'loop t))
	      (setq w (+ w cw))
	      (setq i (+ i 1))))
	  (cond
	   ((= w width)
	    (if cnt
		(concat (substring str 0 i) "..")
	      (substring str 0 i)))
	   (t
	    ;; workaround for the bug of Emacs 20.7
	    (setq safe-w (logand (- width w) 255))
	    (if cnt
		(concat (substring str 0 i) (make-string safe-w 32) "..")
	      (concat (substring str 0 i) (make-string safe-w 32)))))))
      (error
       (if (> (length mew-error-broken-string) width)
	   (substring mew-error-broken-string 0 width)
	 mew-error-broken-string)))))
    
;;
;; Language specific
;;

(defvar mew-lc-kana 'katakana-jisx0201)
(defvar mew-lc-jp   'japanese-jisx0208)

;;
;; Stolen from mule-cmd.el
;;

(cond
 (mew-xemacs-p
  (defsubst mew-set-coding-priority (pri) (set-coding-priority-list pri))
  (defsubst mew-coding-category-list () (coding-priority-list))
  (defsubst mew-coding-category-system (cat) (coding-category-system cat)))
 (t
  (defsubst mew-set-coding-priority (pri) (set-coding-priority pri))
  (defsubst mew-coding-category-list () coding-category-list)
  (defsubst mew-coding-category-system (cat) (eval cat))))

(defun mew-reset-coding-systems (priority categories)
  (let ((rest-ctgs categories) checked-ctgs)
    (while priority
      (cond
       (mew-xemacs-p
	(unless (memq (car rest-ctgs) checked-ctgs)
	  (when (car priority)
	    (set-coding-category-system (car rest-ctgs) (car priority)))
	  (setq checked-ctgs (cons (car rest-ctgs) checked-ctgs))))
       (t
	(set (car rest-ctgs) (car priority))))
      (setq priority (cdr priority) rest-ctgs (cdr rest-ctgs)))
    (cond
     (mew-xemacs-p
      (setq categories (nreverse checked-ctgs)))
     (t
      (update-coding-systems-internal)))
    (mew-set-coding-priority categories)))

(defun mew-set-language-environment-coding-systems (language-name)
  (let ((priority (get-language-info language-name 'coding-priority)))
    (when priority
      (let* ((categories (mapcar 'coding-system-category priority))
	     (orig-ctg (mew-coding-category-list))
	     (orig-pri (mapcar 'mew-coding-category-system orig-ctg)))
	(mew-reset-coding-systems priority categories)
	(cons orig-pri orig-ctg)))))

;;
;;
;;

(require 'mew-mule)
(provide 'mew-mule3)

;;; Copyright Notice:

;; Copyright (C) 1997-2003 Mew developing team.
;; All rights reserved.

;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions
;; are met:
;; 
;; 1. Redistributions of source code must retain the above copyright
;;    notice, this list of conditions and the following disclaimer.
;; 2. Redistributions in binary form must reproduce the above copyright
;;    notice, this list of conditions and the following disclaimer in the
;;    documentation and/or other materials provided with the distribution.
;; 3. Neither the name of the team nor the names of its contributors
;;    may be used to endorse or promote products derived from this software
;;    without specific prior written permission.
;; 
;; THIS SOFTWARE IS PROVIDED BY THE TEAM AND CONTRIBUTORS ``AS IS'' AND
;; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;; PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE TEAM OR CONTRIBUTORS BE
;; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
;; BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
;; WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
;; OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
;; IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

;;; mew-mule3.el ends here