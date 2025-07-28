(define-module (fruix licenses)
  #:use-module (guix licenses))

(define license (@@ (guix licenses) license))

(define-public mc-eula
  (license "Minecraft EULA"
           "https://www.minecraft.net/en-us/eula"
           "End user license agreement for minecraft"))