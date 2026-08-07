(define-module (fruix packages media)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system qt)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (gnu packages upnp)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages video)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages gtk))

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

(define-public ffmpeg-dv
  (package
    (inherit ffmpeg)
    (name "ffmpeg-dv")
    (inputs (modify-inputs (package-inputs ffmpeg)
                           (append libiec61883 libavc1394 harfbuzz)))
    (arguments
      (substitute-keyword-arguments
        (package-arguments ffmpeg)
        ((#:configure-flags flags ''())
         #~(cons* "--enable-libiec61883" "--enable-libharfbuzz" #$flags))))))

(define-public midieditor
  (package
   (name "midieditor")
   (version "3.3.2")
   (source (origin
              (method git-fetch)
              (uri
                (git-reference
                  (url "https://github.com/markusschwenk/midieditor.git")
                  (commit version)))
              (sha256
                (base32 "1bj3y1z5pas62r3pls9ch8lh2h0yw3smin5qz703jcxja3czql5w"))))
   (build-system qt-build-system)
   (arguments
       (list #:tests? #f
             #:modules '((guix build qt-build-system)
                         ((guix build gnu-build-system) #:prefix gnu:)
                         (guix build utils))
             #:phases
             #~(modify-phases %standard-phases
                 ;; Configure using qmake.
                 (replace 'configure
                   (lambda _
                     (invoke "qmake" "-project" "-v" (string-append "PREFIX=" #$output))
                     (invoke "qmake" "midieditor.pro" (string-append "PREFIX=" #$output))))
                 (replace 'build (assoc-ref gnu:%standard-phases 'build))
                 (replace 'install
                   (lambda _
                     (mkdir-p (string-append #$output "/bin"))
                     ;(mkdir-p (string-append #$output "/share/applications"))
                     (mkdir-p (string-append #$output "/share/pixmaps"))
                     ;(mkdir-p (string-append #$output "/share/midieditor"))
                     ;(mkdir-p (string-append #$output "/share/doc/midieditor"))
                     ;(mkdir-p (string-append #$output "/lib/midieditor"))
                     (install-file "MidiEditor" (string-append #$output "/lib/midieditor"))
                     ;(install-file "packaging/unix/midieditor/midieditor" (string-append #$output "/bin"))
                     (call-with-output-file (string-append #$output "/bin/midieditor")
                                            (lambda (port)
                                              (format port
                                                      "#!/bin/bash~%cd ~a/lib/midieditor~%~a/lib/midieditor/MidiEditor"
                                                      #$output
                                                      #$output)))
                     ;(install-file "packaging/unix/midieditor/MidiEditor.desktop" (string-append #$output "/usr/share/applications"))
                     (copy-file "packaging/unix/midieditor/logo48.png" (string-append #$output "/share/pixmaps/midieditor.png"))
                     (install-file "packaging/unix/midieditor/copyright" (string-append #$output "/share/doc/midieditor"))
                     (copy-recursively "packaging/metronome" (string-append #$output "/share/midieditor/metronome"))
                     (chmod (string-append #$output "/bin/midieditor") #o755)
                     (chmod (string-append #$output "/lib/midieditor/MidiEditor") #o755)
                     (make-desktop-entry-file
                      (string-append #$output
                                    "/share/applications/MidiEditor.desktop")
                      
                      #:name "MidiEditor"
                      #:comment "NONE"
                      #:categories '("AudioVideo" "Audio")
                      #:exec (string-append #$output "/bin/midieditor")
                      #:icon (string-append #$output
                                            "/share/pixmaps/midieditor.png"))
                     )))))
   (inputs (list alsa-lib qtmultimedia-5))
   (home-page "https://www.midieditor.org")
   (synopsis "MidiEditor is a free software providing an interface to edit, record, and play Midi data.")
   (description "The editor is able to open existing Midi files and modify their content. New files can be created and the user can enter his own composition by either recording Midi data from a connected Midi device (e.g., a digital piano or a keyboard) or by manually creating new notes and other Midi events. The recorded data can be easily quantified and edited afterwards using MidiEditor.")
   (license license:gpl3)))

(define-public upplay
  (package
   (name "upplay")
   (version "1.9.11")
   (source (origin
              (method url-fetch)
              (uri (string-append "https://www.lesbonscomptes.com/upplay/downloads/upplay-" version ".tar.gz"))
              (sha256
                (base32 "0jsl8i301d45gpnjqvd7c71kr9m4g8xglkn5f2g6g8qqf3nkvlfl"))))
   (build-system qt-build-system)
   (inputs (list amber-mpris-qt5 jsoncpp))
   (home-page "https://www.lesbonscomptes.com/upplay/index.html")
   (synopsis "UPnP audio Control Point")
   (description "upplay is a desktop UPnP audio Control Point for Linux/Unix, MS Windows, and Mac OS. It began its existence as a companion to the Upmpdcli renderer, but it has become an ugly but nice, lightweight but capable, control point in its own right.")
   (license license:gpl2)))

(define-public amber-mpris
  (package
   (name "amber-mpris")
   (version "1.2.10")
   (source (origin
              (method git-fetch)
              (uri
                (git-reference
                  (url "https://github.com/sailfishos/amber-mpris")
                  (commit version)))
              (sha256
                (base32 "0wjhk2w9vmbc1g6p9bglw52g0icrnkcan0szx7s51fwpbrlg7s4h"))))
   (build-system gnu-build-system)
   (arguments
       (list #:validate-runpath? #f
             #:phases
             #~(modify-phases %standard-phases
                 (add-after 'unpack 'fix-path
                  (lambda* (#:key outputs #:allow-other-keys)
                    (substitute* "src/src.pro"
                      (("^target.path = .*")
                        (string-append "target.path = "
                                      (assoc-ref outputs "out") "/lib\n"))
                      (("^headers.path = /usr/include/AmberMpris")
                        (string-append "headers.path = "
                                      (assoc-ref outputs "out") "/usr/include/AmberMpris\n")))
                    (substitute* "declarative/declarative.pro"
                      (("^target.path = .*")
                        (string-append "target.path = "
                                      (assoc-ref outputs "out") "/lib/qt6/qml/Amber/Mpris\n")))))
                 ;; qmake configure
                 (replace 'configure
                   (lambda _
                     (invoke "qmake"))))))
   (native-inputs (list ))
   (inputs (list qtdeclarative qtbase))
   (home-page "https://github.com/sailfishos/amber-mpris")
   (synopsis "MPRIS interface for QT and QML")
   (description "MPRIS v.2 specification implementation for Qt and QML plugin.")
   (license license:gpl2)))

(define-public amber-mpris-qt5
  (package
   (inherit amber-mpris)
   (name "amber-mpris-qt5")
   (arguments
     (substitute-keyword-arguments arguments
       ((#:phases phases '%standard-phases)
             #~(modify-phases #$phases
                 (add-after 'fix-path 'qt5-path
                  (lambda* (#:key outputs #:allow-other-keys)
                    (substitute* "declarative/declarative.pro"
                      (("^target.path = .*")
                        (string-append "target.path = "
                                      (assoc-ref outputs "out") "/lib/qt5/qml/Amber/Mpris\n")))
                    (substitute* "src/src.pro"
                      (("^prf.path = .*")
                        (string-append "target.path = "
                                      (assoc-ref outputs "out") "/lib/qt5/mkspecs/features\n")))))))))
   (inputs (list qtdeclarative-5 qtbase-5))))