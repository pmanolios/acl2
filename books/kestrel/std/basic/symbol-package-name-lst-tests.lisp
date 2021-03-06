; Std/basic - Basic definitions
;
; Copyright (C) 2019 Kestrel Institute (http://www.kestrel.edu)
;
; License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
;
; Author: Alessandro Coglio (coglio@kestrel.edu)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "ACL2")

(include-book "misc/assert" :dir :system)

(include-book "symbol-package-name-lst")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(assert-equal (symbol-package-name-lst nil)
              nil)

(assert-equal (symbol-package-name-lst '(symbolp))
              (list *main-lisp-package-name*))

(assert-equal (symbol-package-name-lst '(symbol-listp define std::deflist cons))
              (list "ACL2" "ACL2" "STD" *main-lisp-package-name*))
