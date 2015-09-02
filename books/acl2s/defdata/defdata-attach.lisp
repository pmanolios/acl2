#|$ACL2s-Preamble$;
(include-book ;; Newline to fool ACL2/cert.pl dependency scanner
 "../portcullis")
(acl2::begin-book t);$ACL2s-Preamble$|#

#|
API to attach metadata to a defdata type
author: harshrc
file name: defdata-attach.lisp
date created: [2015-06-09 Tue]
data last modified: [2015-06-09 Tue]
|#

(in-package "DEFDATA")

(include-book "defdata-util")




(defun well-formed-metadata-entry-p (key val wrld)
  (case key
    (:predicate  (allows-arity val 1 wrld))
    (:enumerator (allows-arity val 1 wrld))
    (:enum/acc   (allows-arity val 2 wrld))
    (:equiv (allows-arity val 2 wrld))
    (:equiv-fixer (allows-arity val 1 wrld))
    (:fixer (allows-arity val 1 wrld))
    (:fixer-domain (is-type-predicate val wrld))
    (:lub (predicate-name val))
    (:glb (predicate-name val))
    (:sampling (possible-constant-values-p val))
    (:size (or (eq 't val) (natp val)))
    (:verbose (booleanp val))
    (:theory-name (proper-symbolp val))
    (otherwise t) ;dont be strict.
    ))

(defun ill-formed-metadata-entry-msg1 (key val)
  (declare (ignorable val))
  (case key
    (:predicate        "~x0 should be a 1-arity fn")
    (:enumerator       "~x0 should be a 1-arity fn")
    (:enum/acc         "~x0 should be a 2-arity fn")

    (:equiv            "~x0 should be a 2-arity fn")
    (:equiv-fixer      "~x0 should be a 1-arity fn")
    (:fixer            "~x0 should be a 1-arity fn")
    (:fixer-domain     "~x0 should be a defdata predicate")

    (:lub              "~x0 should be a type name")
    (:glb              "~x0 should be a type name")
    (:sampling         "~x0 should be a list of constants" )
    (:size             "~x0 should be either 't or a natural")
    (:verbose         "~x0 should be a boolean")
    (:theory-name      "~x0 should be a symbol")
    (otherwise         "Unhandled case!")
    ))


(defloop well-formed-type-metadata-p (al wrld)
  (for ((p in al)) (always (well-formed-metadata-entry-p (car p) (cdr p) wrld))))

; TYPE METADATA TABLE

(table type-metadata-table nil nil :clear)


(program)
(defun ill-formed-metadata-entry-msg (key val wrld)
  (and (not (well-formed-metadata-entry-p key val wrld))
       (b* ((x0-str (ill-formed-metadata-entry-msg1 key val))
            ((mv & msg) (acl2::fmt1!-to-string x0-str (acons #\0 val '()) 0)))
         msg)))


(defloop ill-formed-type-metadata-msg (al wrld)
  (for ((p in al)) (thereis (ill-formed-metadata-entry-msg (car p) (cdr p) wrld))))

(logic)

(defconst *defdata-attach-need-override-permission-keywords*
  '(:size :prettyified-def)) ;add more later

(defconst *defdata-attach-keywords* (append '(:test-enumerator ;aliased to :enumerator
                                              :enumerator :enum/acc
                                              :equiv :equiv-fixer
                                              :sampling
                                              :fixer :fixer-domain)
                                            *defdata-attach-need-override-permission-keywords*))


;TODO: The following form is currently quite limited. Extend it later to be more general.
(defmacro defdata-attach  (name &rest keys)
  (b* ((verbosep (let ((lst (member :verbose keys)))
                   (and lst (cadr lst))))
       (override-ok-p (let ((lst (member :override-ok keys)))
                        (and lst (cadr lst))))
       (keys (remove-keywords-from-args '(:verbose :override-ok) keys)))

  `(with-output
    ,@(and (not verbosep) '(:off :all)) :stack :push
    (make-event
        (cons 'progn
              (defdata-attach-fn ',name ',keys ',verbosep ',override-ok-p (w state)))))))



(defun make-enum-uniform-defun-ev (name enum)
  (declare (xargs :guard (symbolp enum)))
  `((defund ,name (m seed)
     (declare (ignorable m))
     (declare (type (unsigned-byte 31) seed))
     (declare (xargs :verify-guards nil ;todo
                     :mode :program ;todo
                     :guard (and (natp m)
                                 (unsigned-byte-p 31 seed))))
; 12 July 2013 - adding uniform random seed distribution to cgen enum
; we will take advantage of the recent addition for an uniform
; interface to both infinite and finite enum (defconsts)
     (mv-let (n seed)
             (random-natural-seed seed)
             (mv (,enum n) (the (unsigned-byte 31) seed))))))

(defun defdata-attach/equiv (name kwd-alist verbosep wrld)
  (declare (ignorable name kwd-alist verbosep wrld))
  (er hard 'defdata-attach/equiv "unimplemented"))

(defun defdata-attach/fixer (name kwd-alist verbosep wrld)
  (declare (ignorable name kwd-alist verbosep wrld))
  (er hard 'defdata-attach/fixer "unimplemented"))

(defun defdata-attach/enum (name enum verbosep wrld)
  (declare (ignorable verbosep))
  (b* ((kwd-alist (cdr (assoc-eq name (table-alist 'type-metadata-table wrld))))
       ((when (eq (get1 :enumerator kwd-alist) enum)) '())

       (ctx 'defdata-attach)
       ((unless (allows-arity enum 1 wrld))
        (er hard? ctx "~|~x0 should be an enumerator function with arity 1~%" enum)))
       ;;TODO: type soundness obligation


    `((DEFTTAG :defdata-attach)
      (DEFATTACH (,(get1 :enumerator kwd-alist) ,enum) :skip-checks t)
      (DEFTTAG nil))))

(defun defdata-attach/enum/acc (name enum2 verbosep wrld)
    (declare (ignorable verbosep))
  (b* ((kwd-alist (cdr (assoc-eq name (table-alist 'type-metadata-table wrld))))
       ((when (eq (get1 :enum/acc kwd-alist) enum2)) '())

       (ctx 'defdata-attach)
       ((unless (allows-arity enum2 2 wrld))
        (er hard? ctx "~|~x0 should be an enum/acc function with arity 1~%" enum2)))
       ;;TODO: type soundness obligation


    `((DEFTTAG :defdata-attach)
      (DEFATTACH (,(get1 :enum/acc kwd-alist) ,enum2) :skip-checks t)
      (DEFTTAG nil))))




(defun defdata-attach-fn (name keys verbosep override-ok-p wrld)
  (declare (xargs :mode :program))
  (b* ((ctx 'defdata-attach)
       ((unless (assoc-eq name (table-alist 'type-metadata-table wrld)))
        (er hard? ctx "~x0 is not a recognized type. Use register-type to register it.~%" name))

       ((mv kwd-alist rest) (extract-keywords ctx *defdata-attach-keywords* keys nil))
       ((when rest) (er hard? ctx "~| Unsupported/Extra args: ~x0~%" rest))



       ;;support the alias to enumerator -- legacy issue
       (test-enumerator (get1 :test-enumerator kwd-alist))
       (kwd-alist (if test-enumerator
                      (put-assoc-eq :enumerator test-enumerator (delete-assoc-eq :test-enumerator kwd-alist))
                    kwd-alist))

       (- (cw? verbosep "~|Got kwd-alist: ~x0~%" kwd-alist))
       ((unless (well-formed-type-metadata-p kwd-alist wrld))
        (er hard? ctx "~| ~s0~%" (ill-formed-type-metadata-msg kwd-alist wrld)))

       ;;check if key is overridable
       ((when (and (subsetp (strip-cars kwd-alist) *defdata-attach-need-override-permission-keywords*)
                   (not override-ok-p)))
        (er hard? ctx "~| ~x0 can only be overriden if :override-ok t is provided.~%" keys)))

    (cond ((get1 :equiv kwd-alist)
           (defdata-attach/equiv name kwd-alist verbosep wrld))
          ((get1 :fixer kwd-alist)
           (defdata-attach/fixer name kwd-alist verbosep wrld))
          ((not (= 1 (len kwd-alist)))
           (er hard? ctx "~|Except for :equiv and :fixer, exactly one keyword argument is allowed at a time.~%"))

          ((get1 :enumerator kwd-alist)
           (defdata-attach/enum name (get1 :enumerator kwd-alist) verbosep wrld))
          ((get1 :enum/acc kwd-alist) ;need override permissions
           (defdata-attach/enum/acc name (get1 :enum/acc kwd-alist) verbosep wrld))

          (t (b* ((existing-kwd-alist (cdr (assoc-eq name (table-alist 'type-metadata-table wrld))))
                  (kwd-alist (union-alist2 kwd-alist existing-kwd-alist)))
               `((TABLE TYPE-METADATA-TABLE ',name ',kwd-alist :put)))))))

(defun defdata-attach/test-subtype-fn (name test-tname wrld)
  (b* ((kwd-alist (cdr (assoc-eq test-tname (table-alist 'type-metadata-table wrld))))
       (test-enum (get1 :enumerator kwd-alist))
       (test-enum/acc (get1 :enum/acc kwd-alist)))
    `((defdata-attach ,name :enumerator ,test-enum)
      (defdata-attach ,name :enum/acc ,test-enum/acc))))


(defmacro defdata-attach/testing-subtype (name test-tname)
  `(defdata-attach/test-subtype-fn ',name ',test-tname (w state)))
