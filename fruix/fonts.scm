(define-module (fruix fonts)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix build-system font)
  #:use-module (guix download))

(define-public font-monofur
  (package
    (name "font-monofur")
    (version "1.0")
    (source (origin
              (method url-fetch)
              (uri "https://bucket.daz.cat/uncifonts/pub/monof_tt.zip")
              (sha256
               (base32
                "0nh594h8m6qwwzc4bajyrnmsf7rpdjx3yhq1pis9nbrl3ycwlh9d"))))
    (build-system font-build-system)
    (outputs '("out"))
    (home-page "https://bucket.daz.cat/uncifonts/")
    (synopsis "A monospaced geometric rounded sans-serif font based on the
eurofurence typeface family.")
    (description "monofur is a monospaced font derived from the eurofurence
typeface family. It shares the same style characteristics, but the proportions
of most characters have been recalculated to fit into a 1:2 character cell,
also some letters had to be completely redesigned.")
    (license license:public-domain)))