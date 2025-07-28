(define-module (fruix packages minecraft)
  #:use-module ((fruix licenses) #:prefix license:)
  #:use-module (guix build-system copy)
  #:use-module (guix download)
  #:use-module (guix packages)
  #:use-module (gnu packages java)
  #:use-module (gnu packages linux)
  #:use-module (guix gexp))

(define-public minecraft-server
  (package
    (name "minecraft-server")
    (version "1.21.8")
    (source (origin
              (method url-fetch/executable)
              (uri "https://piston-data.mojang.com/v1/objects/6bce4ef400e4efaa63a13d5e6f6b500be969ef81/server.jar")
              (sha256
               (base32
                "196fz2dp92733q5bdn4jfvrfs0srx8d26bf5x54sg6wxlqyc3pvs"))))
    (build-system copy-build-system)
    (arguments
      (list
        #:install-plan #~'(("server.jar" "/lib/minecraft/server.jar"))))
    (propagated-inputs
      (list
        openjdk21))
    (home-page "https://minecraft.net")
    (synopsis "Minecraft server software")
    (description "Build anything you can imagine, uncover eerie mysteries, and
survive the night in the ultimate sandbox game. In Minecraft, every playthrough
is different, and unforgettable adventures await behind every corner. Explore
and craft your way through an infinite world that’s yours to shape, one block
at a time.")
    (license license:mc-eula)))