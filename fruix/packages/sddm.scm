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

(define-public sddm-commonality-theme
  (package
   (name "sddm-commonality-theme")
   (version "92b859b8dd84bac7f1a8c72b8428fee98405f06a")
   (source (origin
            (method git-fetch)
            (uri
              (git-reference
              (url "https://www.opencode.net/phob1an/commonality.git")
              (commit version)))
            (sha256
              (base32 "15ckhbdd4zsma4xn4rsdndvi5j6aaqm8w12l4cdfyi2v9s1vhwv0"))))
   (build-system copy-build-system)
   (arguments (list
    #:install-plan
      #~'(("./sddm/themes" "share/sddm/themes"))))
   (home-page "https://github.com/zebreus/sddm-xdm-theme")
   (synopsis "Remembering CDE")
   (description "An sddm theme made to resemble xdm on a CDE system.")
   (license license:gpl3)))

(define-public sddm-commonality-sol-theme
  (package
   (name "sddm-commonality-sol-theme")
   (version "92b859b8dd84bac7f1a8c72b8428fee98405f06a")
   (source (origin
            (method git-fetch)
            (uri
              (git-reference
              (url "https://www.opencode.net/phob1an/commonality.git")
              (commit version)))
            (sha256
              (base32 "15ckhbdd4zsma4xn4rsdndvi5j6aaqm8w12l4cdfyi2v9s1vhwv0"))))
   (build-system copy-build-system)
   (arguments (list
    #:install-plan
      #~'(("./SOL/sddm/themes" "share/sddm/themes"))))
   (home-page "https://github.com/zebreus/sddm-xdm-theme")
   (synopsis "Remembering CDE")
   (description "An sddm theme made to resemble xdm on a CDE system.")
   (license license:gpl3)))

sddm-commonality-sol-theme