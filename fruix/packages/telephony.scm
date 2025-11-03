(define-module (fruix packages telephony)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system copy)
  #:use-module (guix gexp)
  #:use-module (guix config)
  #:use-module ((gcrypt hash) #:prefix gcrypt:)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages libedit)
  #:use-module (gnu packages web)
  #:use-module (gnu packages sqlite)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages wget)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (srfi srfi-26))

(define %auxiliary-files-path
  (make-parameter
   (map (cut string-append <> "/fruix/packages/aux")
        %load-path)))

(define (search-auxiliary-file file-name)
  "Search the auxiliary FILE-NAME.  Return #f if not found."
  (search-path (%auxiliary-files-path) file-name))

(define-public pj-project
  (let ((version "2.15.1"))
    (package
    (name "pjproject")
    (version version)
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/pjsip/pjproject/archive/refs/tags/" version ".tar.gz"))
              (sha256
              (base32
                "01jpsmmyybhww3vsy7paxbcqr7gb65ha7f1qh3nrcgq0myfdjfwg"))))
    (build-system gnu-build-system)
    (arguments
     '(#:phases (modify-phases %standard-phases
                               (delete 'check))))
    (home-page "https://www.pjsip.org/")
    (synopsis "PJSIP project")
    (description "PJSIP is a free and open source multimedia communication library written in C with high level API in C, C++, Java, C#, and Python languages. It implements standard based protocols such as SIP, SDP, RTP, STUN, TURN, and ICE. It combines signaling protocol (SIP) with rich multimedia framework and NAT traversal functionality into high level API that is portable and suitable for almost any type of systems ranging from desktops, embedded systems, to mobile handsets.")
    (license license:gpl2))))

; (define (dl url hash)
;   (url-fetch url 'gcrypt:sha256 (base32 hash)))
(define (dl url hash)
        (origin
          (method url-fetch)
          (uri url)
          (sha256
          (base32
            hash))))

(define-public asterisk
  (let ((version "23.0.0"))
    (package
     (name "asterisk")
     (version version)
     (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-"
                    version
                    ".tar.gz"))
              (sha256
               (base32
                "05dcih9kga68bzv5sr81m2qk63vsmr892g7kkca0p8mlqzji5w1h"))))
     (build-system gnu-build-system)
     (arguments
      (list #:configure-flags #~(list "--without-pjproject-bundled"
                                      (string-append "--with-libedit="
                                                     #$(this-package-input "libedit"))
                                      #$(string-append "--with-download-cache="
                                                     %store-directory))
            #:phases #~(modify-phases %standard-phases
                                      (delete 'check)
                                      (add-after 'configure 'menuselect
                                                 ;(lambda _ (invoke "make" "menuselect.makeopts")))
                                                 (lambda _ (invoke "make" "menuselect.makeopts")
                                                           (copy-file #$(local-file (search-auxiliary-file "asterisk/menuselect.makeopts")) "./menuselect.makeopts")))
                                      (add-before 'install 'offline-sound
                                                  (lambda _ (substitute* "sounds/Makefile"
                                                                         (("\\.PHONY: dist-clean all uninstall have_download install") ".PHONY: dist-clean all uninstall install")
                                                                         (("asterisk-$\\(2\\)$\\(if $\\(3\\),-$\\(3\\),\\)-%\\.tar\\.gz: have_download") "asterisk-$(2)$(if $(3),-$(3),)-%.tar.gz:")))))))
     (native-inputs (list pkg-config wget))
     (inputs (list ;pj-project
                   libedit
                   jansson
                   sqlite
                   libxml2
                   libxslt
                   ncurses
                   openssl
                   (list util-linux "lib")
                   (dl "https://downloads.asterisk.org/pub/telephony/sounds/releases/asterisk-core-sounds-en-gsm-1.6.1.tar.gz" "0bagy99dm00alsjiq6y4zjs8dgj0q76dyiy4cgrsh7fl8hh3v76p")
                   (dl "https://downloads.asterisk.org/pub/telephony/sounds/releases/asterisk-core-sounds-en-gsm-1.6.1.tar.gz.sha1" "1ywbs69nylf922ih304pdn6yi8caiz09bh88814ij125y5h5rgn5")))
     (home-page "https://www.asterisk.org")
     (synopsis "Free and open source framework for building communications applications.")
     (description "Asterisk is an open source framework for building
communications applications. Asterisk turns an ordinary computer into a
communications server. Asterisk powers IP PBX systems, VoIP gateways,
conference servers and other custom solutions. It is used by small businesses,
large businesses, call centers, carriers and government agencies, worldwide.
Asterisk is free and open source. Asterisk is sponsored by Sangoma.")
     (license license:gpl2))))