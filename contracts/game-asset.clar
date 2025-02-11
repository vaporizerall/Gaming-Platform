;; Game Asset Contract

;; Define non-fungible token for game assets
(define-non-fungible-token game-asset uint)

;; Define data structures
(define-map asset-details
  { asset-id: uint }
  { name: (string-utf8 64), owner: principal }
)

(define-data-var last-asset-id uint u0)

;; Error codes
(define-constant err-not-owner (err u100))
(define-constant err-asset-not-found (err u101))

;; Functions
(define-public (mint-asset (name (string-utf8 64)))
  (let
    ((new-asset-id (+ (var-get last-asset-id) u1)))
    (try! (nft-mint? game-asset new-asset-id tx-sender))
    (map-set asset-details { asset-id: new-asset-id } { name: name, owner: tx-sender })
    (var-set last-asset-id new-asset-id)
    (ok new-asset-id)
  )
)

(define-public (transfer-asset (asset-id uint) (recipient principal))
  (let
    ((asset-owner (unwrap! (nft-get-owner? game-asset asset-id) err-asset-not-found)))
    (asserts! (is-eq tx-sender asset-owner) err-not-owner)
    (try! (nft-transfer? game-asset asset-id tx-sender recipient))
    (map-set asset-details { asset-id: asset-id }
      (merge (unwrap! (map-get? asset-details { asset-id: asset-id }) err-asset-not-found)
        { owner: recipient }))
    (ok true)
  )
)

(define-read-only (get-asset-details (asset-id uint))
  (map-get? asset-details { asset-id: asset-id })
)

