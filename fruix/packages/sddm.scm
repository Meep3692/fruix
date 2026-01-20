(define-module (fruix packages sddm)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix build-system copy)
  #:use-module (guix git-download))

(define-public sddm-xdm-theme
  (package
   (name "sddm-xdm-theme")
   (version "bf170f1")
   (source (origin
            (method git-fetch)
            (uri
             (git-reference
              (url "https://github.com/zebreus/sddm-xdm-theme")
              (commit version)))
            (sha256
             (base32 "02hib5d4mw0zsg49gs8290yh7cvbx392lk4fj2vxvvf1m1fcb3z4"))))
   (build-system copy-build-system)
   (arguments (list
    #:install-plan
      #~'(("." "share/sddm/themes/xdm"))))
   (home-page "https://github.com/zebreus/sddm-xdm-theme")
   (synopsis "A sddm theme that looks like xdm")
   (description "A sddm theme that looks like xdm")
   (license license:cc-by-sa3.0)))