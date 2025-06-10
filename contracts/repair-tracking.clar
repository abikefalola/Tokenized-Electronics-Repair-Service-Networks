;; Repair Tracking Contract
;; Tracks electronics repair processes from start to completion

(define-constant err-not-found (err u200))
(define-constant err-unauthorized (err u201))
(define-constant err-invalid-status (err u202))
(define-constant err-already-exists (err u203))

;; Repair status constants
(define-constant status-pending u1)
(define-constant status-in-progress u2)
(define-constant status-completed u3)
(define-constant status-cancelled u4)

;; Data structures
(define-map repair-jobs
  { job-id: uint }
  {
    customer: principal,
    provider: principal,
    device-type: (string-ascii 50),
    issue-description: (string-ascii 200),
    status: uint,
    created-at: uint,
    estimated-completion: uint,
    actual-completion: (optional uint),
    cost-estimate: uint,
    final-cost: (optional uint)
  }
)

(define-map job-updates
  { job-id: uint, update-id: uint }
  {
    timestamp: uint,
    status: uint,
    notes: (string-ascii 200),
    updated-by: principal
  }
)

(define-data-var next-job-id uint u1)
(define-data-var next-update-id uint u1)

;; Public functions
(define-public (create-repair-job
    (provider principal)
    (device-type (string-ascii 50))
    (issue-description (string-ascii 200))
    (estimated-completion uint)
    (cost-estimate uint))
  (let ((job-id (var-get next-job-id)))
    (map-set repair-jobs
      { job-id: job-id }
      {
        customer: tx-sender,
        provider: provider,
        device-type: device-type,
        issue-description: issue-description,
        status: status-pending,
        created-at: block-height,
        estimated-completion: estimated-completion,
        actual-completion: none,
        cost-estimate: cost-estimate,
        final-cost: none
      }
    )
    (var-set next-job-id (+ job-id u1))
    (ok job-id)
  )
)

(define-public (update-repair-status
    (job-id uint)
    (new-status uint)
    (notes (string-ascii 200)))
  (let ((job (unwrap! (map-get? repair-jobs { job-id: job-id }) err-not-found))
        (update-id (var-get next-update-id)))
    (asserts! (or (is-eq tx-sender (get provider job))
                  (is-eq tx-sender (get customer job))) err-unauthorized)
    (asserts! (and (>= new-status u1) (<= new-status u4)) err-invalid-status)

    ;; Update job status
    (map-set repair-jobs
      { job-id: job-id }
      (merge job { status: new-status })
    )

    ;; Add update record
    (map-set job-updates
      { job-id: job-id, update-id: update-id }
      {
        timestamp: block-height,
        status: new-status,
        notes: notes,
        updated-by: tx-sender
      }
    )

    (var-set next-update-id (+ update-id u1))
    (ok true)
  )
)

(define-public (complete-repair (job-id uint) (final-cost uint))
  (let ((job (unwrap! (map-get? repair-jobs { job-id: job-id }) err-not-found)))
    (asserts! (is-eq tx-sender (get provider job)) err-unauthorized)
    (map-set repair-jobs
      { job-id: job-id }
      (merge job {
        status: status-completed,
        actual-completion: (some block-height),
        final-cost: (some final-cost)
      })
    )
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-repair-job (job-id uint))
  (map-get? repair-jobs { job-id: job-id })
)

(define-read-only (get-job-update (job-id uint) (update-id uint))
  (map-get? job-updates { job-id: job-id, update-id: update-id })
)

(define-read-only (get-next-job-id)
  (var-get next-job-id)
)
