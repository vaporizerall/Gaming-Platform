;; Matchmaking Contract

;; Define data structures
(define-map player-queue
  { game-type: (string-utf8 64) }
  { players: (list 100 principal) }
)

(define-map matches
  { match-id: uint }
  { game-type: (string-utf8 64), players: (list 2 principal), status: (string-utf8 20) }
)

(define-data-var last-match-id uint u0)

;; Error codes
(define-constant err-queue-full (err u100))
(define-constant err-not-in-queue (err u101))
(define-constant err-match-not-found (err u102))

;; Functions
(define-public (join-queue (game-type (string-utf8 64)))
  (match (map-get? player-queue { game-type: game-type })
    existing-queue
    (let
      ((updated-queue (unwrap! (as-max-len? (append (get players existing-queue) tx-sender) u100) err-queue-full)))
      (map-set player-queue { game-type: game-type } { players: updated-queue })
      (ok true)
    )
    (map-set player-queue { game-type: game-type } { players: (list tx-sender) })
  )
  (ok true)
)

(define-public (leave-queue (game-type (string-utf8 64)))
  (match (map-get? player-queue { game-type: game-type })
    existing-queue
    (let
      ((updated-queue (filter not-tx-sender (get players existing-queue))))
      (map-set player-queue { game-type: game-type } { players: updated-queue })
      (ok true)
    )
    (err err-not-in-queue)
  )
)

(define-private (not-tx-sender (player principal))
  (not (is-eq player tx-sender))
)

(define-public (create-match (game-type (string-utf8 64)))
  (match (map-get? player-queue { game-type: game-type })
    existing-queue
    (let
      ((players (unwrap! (as-max-len? (take (get players existing-queue) u2) u2) err-queue-full))
       (new-match-id (+ (var-get last-match-id) u1)))
      (map-set matches { match-id: new-match-id }
        { game-type: game-type, players: players, status: "active" })
      (var-set last-match-id new-match-id)
      (map-set player-queue { game-type: game-type }
        { players: (unwrap! (as-max-len? (drop (get players existing-queue) u2) u100) err-queue-full) })
      (ok new-match-id)
    )
    (err err-queue-full)
  )
)

(define-read-only (get-match (match-id uint))
  (map-get? matches { match-id: match-id })
)

