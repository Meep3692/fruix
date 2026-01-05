(define-module (fruix packages dev)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (gnu packages emulators))

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