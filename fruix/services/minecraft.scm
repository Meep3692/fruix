(define-module (fruix services minecraft)
  #:use-module (fruix packages minecraft)
  #:use-module (gnu services)
  #:use-module (gnu services configuration)
  #:use-module (gnu services shepherd)
  #:use-module (gnu system shadow)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages java)
  #:use-module (guix packages)
  #:use-module (guix records)
  #:use-module (guix gexp)
  #:use-module (guix modules)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-26)
  #:use-module (srfi srfi-34)
  #:use-module (srfi srfi-35)
  #:use-module (ice-9 match)
  #:use-module (ice-9 regex)
  #:export (minecraft-service-type
            minecraft-configuration))

(define-record-type* <minecraft-configuration>
  minecraft-configuration make-minecraft-configuration
  minecraft-configuration?
  (minecraft  minecraft-configuration-minecraft
              (default minecraft-server))
  (java       minecraft-configuration-java
              (default openjdk21))
  (user       minecraft-configuration-user
              (default "minecraft"))
  (directory  minecraft-configuration-directory
              (default "/var/lib/minecraft"))
  (eula       minecraft-configuration-eula
              (default #f))
  (properties minecraft-configuration-properties
              (default (list))))

(define (minecraft-accounts config)
  (list (user-group (name (minecraft-configuration-user config)) (system? #t))
        (user-account
          (name (minecraft-configuration-user config))
          (group (minecraft-configuration-user config))
          (system? #t)
          (comment "minecraft server user")
          (home-directory (minecraft-configuration-directory config))
          (shell (file-append shadow "/sbin/nologin")))))

(define (minecraft-activation config)
  (with-imported-modules (source-module-closure '((gnu build activation)))
    (match-record
      config <minecraft-configuration>
      (directory user eula properties)
      #~(begin
          (use-modules (gnu build activation))
          (define (copy-file/perms source dest user perms)
                  (copy-file source dest)
                  (chown dest (passwd:uid (getpwnam user)) (passwd:gid (getpwnam user)))
                  (chmod dest perms))
          (mkdir-p/perms #$directory
                         (getpwnam #$user) #o755)
          ;(copy-file #$(plain-file "eula.txt" (string-append "eula=" (if eula "true" "false"))) (string-append #$directory "/eula.txt"))
          ;(chown (string-append #$directory "/eula.txt") (passwd:uid (getpwnam #$user)) (passwd:gid (getpwnam #$user)))
          ;(chmod (string-append #$directory "/eula.txt") #o644)
          (copy-file/perms
            #$(plain-file "eula.txt" (string-append "eula=" (if eula "true" "false")))
            (string-append #$directory "/eula.txt")
            #$user
            #o644)
          ;(copy-file #$(plain-file
          ;               "server.properties"
          ;               (string-join (map (lambda (p) (string-append (car p) "=" (cdr p))) properties) "\n"))
          ;           (string-append #$directory "/server.properties"))
          ;(chown (string-append #$directory "/server.properties") (passwd:uid (getpwnam #$user)) (passwd:gid (getpwnam #$user)))
          ;(chmod (string-append #$directory "/server.properties") #o644)
          (copy-file/perms
            #$(plain-file
              "server.properties"
              (string-join (map (lambda (p) (string-append (car p) "=" (cdr p))) properties) "\n"))
            (string-append #$directory "/server.properties")
            #$user
            #o644)
          ))))

(define (minecraft-shepherd-service config)
  (match-record
    config <minecraft-configuration>
    (java minecraft user)
    (list (shepherd-service
            (documentation "Run the Minecraft server.")
            (provision '(minecraft))
            (requirement '(networking))
            ;; (actions (list (shepherd-configuration-action config-file)))
            (start #~(make-forkexec-constructor
                       (list (string-append #$java "/bin/java")
                             "-jar"
                             (string-append #$minecraft "/lib/minecraft/server.jar"))
                        #:directory #$(minecraft-configuration-directory config)
                        #:user #$user
                        #:group #$user))
            (stop #~(make-kill-destructor))))))

(define minecraft-service-type
  (service-type (name 'minecraft)
                (extensions
                  (list (service-extension shepherd-root-service-type
                                           minecraft-shepherd-service)
                        (service-extension activation-service-type
                                           minecraft-activation)
                        (service-extension account-service-type
                                           minecraft-accounts)))
                (default-value (minecraft-configuration))
                (description
                 "Run Minecraft game server.")))