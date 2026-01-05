(define-module (fruix packages dev)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (gnu packages emulators)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages sdl)
  #:use-module (gnu packages compression))

(define-public cc65-git
  (package
   (inherit cc65)
   (name "cc65-git")
   (version "1e1e8a686")
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/cc65/cc65.git")
                  (commit version)))
            (sha256
             (base32
              "0jkr9swwifv513dlmfjzl5521nc5f78v62nmxcibdd9rlwdpwrz9"))))
   (arguments
      (substitute-keyword-arguments
        (package-arguments cc65)
        ((#:make-flags flags ''())
         #~(list "BUILD_ID=Git 1e1e8a686"
             (string-append "PREFIX=" (assoc-ref %outputs "out"))))))))

(define-public gametank-emulator
  (package
   (name "gametank-emulator")
   (version "ac3fe38")
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/clydeshaffer/GameTankEmulator")
                  (commit version)
                  (recursive? #t)))
            (sha256
             (base32
              "0ih3ayyxc1j9qqahszi7s5im2a2y2csvz1g2p459a55bzrlhbrv4"))))
   (build-system gnu-build-system)
   (arguments
    (list
     #:tests? #f
     #:make-flags
       #~(list (string-append "INSTALL_DIR=" %output)
               (string-append "MANUAL_COMMIT_HASH=" #$version))
     #:phases
       #~(modify-phases %standard-phases
           (delete 'configure))))
   (native-inputs `(,zip))
   (inputs `(,sdl2))
   (synopsis "An emulator for the GameTank")
   (description "An emulator project for the GameTank 8-bit game console, to speed cross-development of software for the real system.")
   (home-page "https://github.com/clydeshaffer/GameTankEmulator")
   (license license:expat)))