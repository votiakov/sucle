(in-package :sandbox)

(progn
  (defun map-symbol-ascii (hash)
    (dolist (x (quote ((:space 32)
		       (:apostrophe 39)
		       (:comma 44)
		       (:minus 45)
		       (:period 46)
		       (:slash 47)
		       (:0 48)
		       (:1 49)
		       (:2 50)
		       (:3 51)
		       (:4 52)
		       (:5 53)
		       (:6 54)
		       (:7 55)
		       (:8 56)
		       (:9 57)
		       (:semicolon 59)
		       (:equal 61)
		       (:A 97) (:B 98) (:C 99) (:D 100) (:E 101) (:F 102) (:G 103) (:H 104) (:I 105)
		       (:J 106) (:K 107) (:L 108) (:M 109) (:N 110) (:O 111) (:P 112) (:Q 113)
		       (:R 114) (:S 115) (:T 116) (:U 117) (:V 118) (:W 119) (:X 120) (:Y 121)
		       (:Z 122)
		       (:left-bracket 91)
		       (:backslash 92)
		       (:right-bracket 93)
		       (:grave-accent 96))))
      (let ((keyword (pop x))
	    (number (pop x)))
	(setf (gethash keyword hash) number)))
    hash)
  (defparameter *keyword-ascii* (map-symbol-ascii (make-hash-table :test 'eq))))

(defun ascii-control (char)
  (logxor (ash 1 6) char))

(defparameter *shift-keys*
  "`~1!2@3#4$5%6^7&8*9(0)-_=+qQwWeErRtTyYuUiIoOpP[{]}\\|aAsSdDfFgGhHjJkKlL;:'\"zZxXcCvVbBnNmM,<.>/?")

(progn
  (defparameter *shifted-keys* (make-array 128))
  (defparameter *controlled-keys* (make-array 128))
  (defun reset-ascii-tables ()
    (dobox ((offset 0 (length *shift-keys*) :inc 2))
	   (etouq
	    (with-vec-params '((offset down up)) '(*shift-keys*)
	      '(let ((code (char-code down)))
		(setf (aref *shifted-keys* code) (char-code up))
		(setf (aref *controlled-keys* code) (ascii-control code))))))
    (dotimes (x 128)
      (setf (aref *controlled-keys* x)
	    (ascii-control x))))
  (reset-ascii-tables)
  )

(progn
  (defconstant +shift+ 1)
  (defconstant +control+ 2)
  (defconstant +alt+ 4)
  (defconstant +super+ 8)
  (defun convert-char (char mods)
    (if (logtest +shift+ mods)
	(setf char (aref *shifted-keys* char)))
    (let ((meta (logtest +alt+ mods))
	  (control (logtest +control+ mods)))
      (if (or meta control)
	  (setf char (char-code (char-upcase (code-char char)))))
      (if control
	  (setf char (aref *controlled-keys* char)))
      (values char
	      (if meta
		  (etouq (char-code #\esc)))))))
