;; Booking System Contract

;; Constants
(define-constant err-unavailable (err u100))
(define-constant err-payment-failed (err u101))
(define-constant err-invalid-dates (err u102))
(define-constant err-not-authorized (err u103))
(define-constant err-not-found (err u104))
(define-constant err-overflow (err u105))

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
(define-private (is-overlapping (start1 uint) (end1 uint) (start2 uint) (end2 uint))
  (not (or (>= start1 end2) (<= end1 start2)))
)

(define-private (check-availability (property-id uint) (start-date uint) (end-date uint))
  (let ((all-bookings (map-get? bookings { booking-id: property-id })))
    (if (is-none all-bookings)
      true
      (let ((booking (unwrap-panic all-bookings)))
        (not (is-overlapping start-date end-date 
                           (get start-date booking) 
                           (get end-date booking)))
      )
    )
  )
)

(define-private (calculate-total-price (price-per-night uint) (total-nights uint))
  (let ((result (* price-per-night total-nights)))
    (asserts! (> result u0) err-overflow)
    (ok result)
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
  )
    (asserts! (> end-date start-date) err-invalid-dates)
    (asserts! (check-availability property-id start-date end-date) err-unavailable)
    
    (match (calculate-total-price price-per-night total-nights)
      total-price (match (stx-transfer? total-price tx-sender (get owner property))
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
      error err-overflow
    )
  )
)

(define-public (get-booking (booking-id uint))
  (ok (map-get? bookings { booking-id: booking-id }))
)
