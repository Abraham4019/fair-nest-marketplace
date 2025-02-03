;; Property Registry Contract

;; Constants
(define-constant err-not-found (err u100))

;; Data Maps
(define-map property-details
  { property-id: uint }
  {
    title: (string-ascii 50),
    description: (string-utf8 500),
    location: (string-ascii 100),
    amenities: (list 10 (string-ascii 20))
  }
)

;; Public Functions
(define-public (register-property 
  (property-id uint)
  (title (string-ascii 50))
  (description (string-utf8 500))
  (location (string-ascii 100))
  (amenities (list 10 (string-ascii 20)))
)
  (ok (map-insert property-details
    { property-id: property-id }
    {
      title: title,
      description: description,
      location: location,
      amenities: amenities
    }
  ))
)
