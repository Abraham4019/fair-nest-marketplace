;; FairNest Marketplace Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-authorized (err u100))
(define-constant err-already-listed (err u101))
(define-constant err-not-found (err u102))

;; Data Variables
(define-map properties
  { property-id: uint }
  {
    owner: principal,
    price-per-night: uint,
    available: bool,
    security-deposit: uint
  }
)

;; Public Functions
(define-public (list-property (property-id uint) (price-per-night uint) (security-deposit uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-authorized)
    (ok (map-insert properties
      { property-id: property-id }
      {
        owner: tx-sender,
        price-per-night: price-per-night,
        available: true,
        security-deposit: security-deposit
      }
    ))
  )
)

(define-public (get-property (property-id uint))
  (ok (map-get? properties { property-id: property-id }))
)

(define-public (update-availability (property-id uint) (available bool))
  (let ((property (unwrap! (map-get? properties { property-id: property-id }) err-not-found)))
    (asserts! (is-eq tx-sender (get owner property)) err-not-authorized)
    (ok (map-set properties
      { property-id: property-id }
      (merge property { available: available })
    ))
  )
)
