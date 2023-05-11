(in-package :trivial-deprecate)

(defvar *deprecated-functions* (make-hash-table :test 'eq :weakness :key))
(defvar *deprecation-mode* :warn)
(defvar *re-deprecation-mode* :error)

(defun do-deprecation-notice (function)
  "Called when deprecated function is called"
  (case *deprecation-mode*
    (:warn (format *error-output* "Calling deprecated trivial-deprecate function ~A" function))
    (:error (error "Calling deprecated trivial-deprecate function ~A" function))))

(defun do-function-already-deprecated (function) 
  "Called when trying to deprecate already deprecated function"
  (case *re-deprecation-mode*
    (:warn (format *error-output* "Function ~A is already deprecated" function))
    (:error (error "Function ~A is already deprecated" function))))

(defun do-function-wasnt-deprecated (function) 
  "Called when trying to un-deprecate a function that wasn't deprecated"
  (case *re-deprecation-mode*
    (:warn (format *error-output* "Function ~A was not deprecated" function))
    (:error (error "Function ~A was not deprecated" function))))

(defun %internal-undeprecate (fn) 
  (let ((res (gethash fn *deprecated-functions*)))
    (unless res 
      (do-function-wasnt-deprecated fn))
    (setf (gethash fn *deprecated-functions*) nil)
    res))

(defun %internal-deprecate (fn)
  (when (gethash fn *deprecated-functions*)
    (do-function-already-deprecated fn))
  (let ((res (lambda (&rest stuff)
               "Deprecated function"
               (declare (ignorable stuff))
               (do-deprecation-notice fn)
               (funcall fn))))
    (setf (gethash res *deprecated-functions*) fn)
    res))

(define-modify-macro deprecate1 () %internal-deprecate)
(define-modify-macro undeprecate1 () %internal-undeprecate)

(defmacro deprecate (reference)
  "Deprecate a reference"
  (let ((sym (gensym "reference")))
    `(let ((,sym ',reference))
       (if (and (listp ,sym)
                (equalp (first ,sym) 'common-lisp:function))
           (setf (fdefinition (second ,sym))
                 (%internal-deprecate ,reference))
           (deprecate1 ,reference)))))

(defmacro undeprecate (reference)
  (let ((sym (gensym "reference")))
    `(let ((,sym ',reference))
       (if (and (listp ,sym)
                (equalp (first ,sym) 'common-lisp:function))
           (setf (fdefinition (second ,sym))
                 (%internal-undeprecate ,reference))
           (undeprecate1 ,reference)))))
