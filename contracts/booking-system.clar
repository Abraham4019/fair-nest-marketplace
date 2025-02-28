;; Booking System Contract

;; Constants
(define-constant err-unavailable (err u100))
(define-constant err-payment-failed (err u101))
(define-constant err-invalid-dates (err u102))
(define-constant err-not-authorized (err u103))

;; Data Maps
(define-map bookings
  { booking-id: uint }
  {
    property-id: uint,
    tenant: principal,
    start-date: uint,
    end-date: uint,
    total-price: uint,
    status: (string-ascii 20)
  }
)

;; Private Functions
(define-private (check-availability (property-id uint) (start-date uint) (end-date uint))
  (let ((existing-bookings (map-get? bookings { booking-id: property-id })))
    (if (is-none existing-bookings)
      true
      (let ((booking (unwrap-panic existing-bookings)))
        (and
          (> start-date (get end-date booking))
          (< end-date (get start-date booking))
        )
      )
    )
  )
)

;; Public Functions
(define-public (create-booking 
  (booking-id uint)
  (property-id uint)
  (start-date uint)
  (end-date uint)
)
  (let (
    (property (unwrap! (contract-call? .rental-marketplace get-property property-id) err-not-found))
    (price-per-night (get price-per-night property))
    (total-nights (- end-date start-date))
    (total-price (* price-per-night total-nights))
  )
    (asserts! (> end-date start-date) err-invalid-dates)
    (asserts! (check-availability property-id start-date end-date) err-unavailable)
    
    ;; Process payment
    (match (stx-transfer? total-price tx-sender (get owner property))
      success (begin
        (map-set bookings
          { booking-id: booking-id }
          {
            property-id: property-id,
            tenant: tx-sender,
            start-date: start-date,
            end-date: end-date,
            total-price: total-price,
            status: "confirmed"
          }
        )
        (ok true)
      )
      error err-payment-failed
    )
  )
)

(define-public (get-booking (booking-id uint))
  (ok (map-get? bookings { booking-id: booking-id }))
)
