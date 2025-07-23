(define-module (fruix media)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix build-system gnu)
  #:use-module (guix git-download)
  #:use-module (gnu packages upnp)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages autotools))

(define-public gmrender-resurrect
  (package
    (name "gmrender-resurrect")
    (version "0.3")
    (source (origin
              (method git-fetch)
              (uri
                (git-reference
                  (url "https://github.com/hzeller/gmrender-resurrect.git")
                  (commit
                    (string-append "v" version))))
              (file-name
               (git-file-name name version))
              (sha256
                (base32 "0j9y6flpxglqbz5rbjpxsnh5irr4ghs1gv3263zr4pxa39hiipv6"))))
    (build-system gnu-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         ;; autogen.sh calls configure at the end of the script.
         (replace 'bootstrap
           (lambda _ (invoke "autoreconf" "-vfi"))))))
    (native-inputs
     (list autoconf automake pkg-config libtool))
    (propagated-inputs
      (list libupnp
            gstreamer
            gst-plugins-base
            gst-plugins-good
            gst-plugins-bad
            gst-plugins-ugly
            gst-libav))
    (home-page "https://github.com/hzeller/gmrender-resurrect")
    (synopsis "Resource efficient UPnP/DLNA renderer, optimal for Raspberry Pi,
CuBox or a general MediaServer.")
    (description "Resource efficient UPnP/DLNA renderer, optimal for Raspberry
Pi, CuBox or a general MediaServer. Fork of GMediaRenderer to add some features
to make it usable.")
    (license license:gpl2)))