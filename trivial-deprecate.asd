(in-package #:cl-user)

(asdf:defsystem #:trivial-deprecate
  :components ((:file "trivial-deprecate")))

(defpackage #:trivial-deprecate
  (:use #:cl)
  (:export
   #:deprecate
   #:undeprecate
   #:%internal-deprecate
   #:*deprecation-warnings*))
