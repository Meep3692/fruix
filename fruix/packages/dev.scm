(define-module (fruix packages dev)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (gnu packages emulators)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages sdl)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages engineering))

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

(define-public hexwalk
  (package
   (name "hexwalk")
   (version "1.10.0")
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/gcarmix/HexWalk")
                  (commit (string-append "v" version))
                  (recursive? #t)))
            (sha256
             (base32
              "1grrqwk5h4yk535nj97lv78683fmgsmz60d6skylrz2glr40dw1p"))))
   (build-system gnu-build-system)
   (arguments
    (list
     #:phases
     #~(modify-phases %standard-phases
          (replace 'configure
            (lambda _
              (mkdir "build")
              (chdir "build")
              (invoke "qmake" "../hexwalk/hexwalk.pro")))
          (add-before 'configure 'unvendor
            (lambda _
              (substitute* "hexwalk/hexwalk.pro"
                ((".*capstone.*") "")
                (("DESTDIR.*") ""))
              (let ((file (open-file "hexwalk/hexwalk.pro" "a")))
                (display "unix:LIBS += -lcapstone" file)
                (newline file)
                (close file))))
          (replace 'install
            (lambda _
              (install-file "hexwalk"
                            (string-append #$output "/bin")))))))
   (inputs `(,qtbase-5 ,qtcharts-5 ,capstone))
   (native-inputs `(,qttools-5))
   (synopsis "A hex editor, viewer, and analyzer.")
   (description "HexWalk is an Hex editor, viewer, analyzer.

Based on opensource projects like qhexedit2,binwalk and QT.

It is cross platform and has plenty of features:

    Advanced Find (can find patterns in binary files based on HEX,UTF8,UTF16 and regex)
    Binwalk integration
    Entropy Analysis
    Byte Map
    Hash Calculator
    Bin/Dec/Hex Converter
    Hex file editing
    Diff file analysis
    Byte Patterns to parse headers
    Disassembler for x86,ARM and MIPS architectures
")
   (home-page "https://www.hexwalk.com/")
   (license license:gpl3)))