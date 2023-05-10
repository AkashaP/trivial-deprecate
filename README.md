# trivial-deprecate

Deprecations separate from function declaration. Modifies at runtime and not source.
mainly wanted something different than a defun-deprecated macro or something.

E.g:
```lisp
(in-package :dont-touch-their-actual-source)
(defun the-function ()
  (print "Hello world"))

(in-package :my-personal-project)
(trivial-deprecate:deprecate #'dont-touch-their-actual-source:the-function)
```
