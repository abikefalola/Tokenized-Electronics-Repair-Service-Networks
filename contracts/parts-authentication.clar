;; Parts Authentication Contract
;; Authenticates and tracks repair parts used in electronics repair

(define-constant err-not-found (err u300))
(define-constant err-unauthorized (err u301))
(define-constant err-already-exists (err u302))
(define-constant err-invalid-part (err u303))

;; Data structures
(define-map authenticated-parts
  { part-id: (string-ascii 50) }
  {
    manufacturer: (string-ascii 50),
    part-name: (string-ascii 100),
    part-number: (string-ascii 50),
    verified: bool,
    batch-number: (string-ascii 30),
    manufacturing-date: uint,
    expiry-date: (optional uint),
    authenticator: principal
  }
)

(define-map part-usage
  { part-id: (string-ascii 50), job-id: uint }
  {
    quantity-used: uint,
    installation-date: uint,
    installer: principal,
    warranty-period: uint
  }
)

(define-map part-suppliers
  { supplier: principal }
  {
    name: (string-ascii 50),
    verified: bool,
    registration-date: uint
  }
)

;; Public functions
(define-public (register-part
    (part-id (string-ascii 50))
    (manufacturer (string-ascii 50))
    (part-name (string-ascii 100))
    (part-number (string-ascii 50))
    (batch-number (string-ascii 30))
    (manufacturing-date uint)
    (expiry-date (optional uint)))
  (begin
    (asserts! (is-none (map-get? authenticated-parts { part-id: part-id })) err-already-exists)
    (map-set authenticated-parts
      { part-id: part-id }
      {
        manufacturer: manufacturer,
        part-name: part-name,
        part-number: part-number,
        verified: false,
        batch-number: batch-number,
        manufacturing-date: manufacturing-date,
        expiry-date: expiry-date,
        authenticator: tx-sender
      }
    )
    (ok part-id)
  )
)

(define-public (verify-part (part-id (string-ascii 50)))
  (let ((part (unwrap! (map-get? authenticated-parts { part-id: part-id }) err-not-found)))
    (asserts! (is-eq tx-sender (get authenticator part)) err-unauthorized)
    (map-set authenticated-parts
      { part-id: part-id }
      (merge part { verified: true })
    )
    (ok true)
  )
)

(define-public (record-part-usage
    (part-id (string-ascii 50))
    (job-id uint)
    (quantity-used uint)
    (warranty-period uint))
  (let ((part (unwrap! (map-get? authenticated-parts { part-id: part-id }) err-not-found)))
    (asserts! (get verified part) err-invalid-part)
    (map-set part-usage
      { part-id: part-id, job-id: job-id }
      {
        quantity-used: quantity-used,
        installation-date: block-height,
        installer: tx-sender,
        warranty-period: warranty-period
      }
    )
    (ok true)
  )
)

(define-public (register-supplier (name (string-ascii 50)))
  (begin
    (asserts! (is-none (map-get? part-suppliers { supplier: tx-sender })) err-already-exists)
    (map-set part-suppliers
      { supplier: tx-sender }
      {
        name: name,
        verified: false,
        registration-date: block-height
      }
    )
    (ok tx-sender)
  )
)

;; Read-only functions
(define-read-only (get-part-info (part-id (string-ascii 50)))
  (map-get? authenticated-parts { part-id: part-id })
)

(define-read-only (get-part-usage-info (part-id (string-ascii 50)) (job-id uint))
  (map-get? part-usage { part-id: part-id, job-id: job-id })
)

(define-read-only (is-part-verified (part-id (string-ascii 50)))
  (match (map-get? authenticated-parts { part-id: part-id })
    part-data (get verified part-data)
    false
  )
)

(define-read-only (get-supplier-info (supplier principal))
  (map-get? part-suppliers { supplier: supplier })
)
