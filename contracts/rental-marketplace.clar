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
