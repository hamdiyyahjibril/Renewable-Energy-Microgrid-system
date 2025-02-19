;; Grid Stability Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))

;; Data Variables
(define-data-var grid-energy-balance int 0)
(define-data-var last-storage-id uint u0)

;; Data Maps
(define-map energy-storage
  { storage-id: uint }
  {
    capacity: uint,
    current-level: uint,
    owner: principal
  }
)

;; Public Functions

;; Add energy storage facility
(define-public (add-storage (capacity uint))
  (let
    (
      (storage-id (+ (var-get last-storage-id) u1))
    )
    (map-set energy-storage
      { storage-id: storage-id }
      {
        capacity: capacity,
        current-level: u0,
        owner: tx-sender
      }
    )
    (var-set last-storage-id storage-id)
    (ok storage-id)
  )
)

;; Store excess energy
(define-public (store-energy (storage-id uint) (amount uint))
  (let
    (
      (storage (unwrap! (map-get? energy-storage { storage-id: storage-id }) err-not-found))
      (new-level (+ (get current-level storage) amount))
    )
    (asserts! (<= new-level (get capacity storage)) err-unauthorized)
    (map-set energy-storage
      { storage-id: storage-id }
      (merge storage { current-level: new-level })
    )
    (var-set grid-energy-balance (- (var-get grid-energy-balance) (to-int amount)))
    (ok true)
  )
)

;; Release stored energy
(define-public (release-energy (storage-id uint) (amount uint))
  (let
    (
      (storage (unwrap! (map-get? energy-storage { storage-id: storage-id }) err-not-found))
    )
    (asserts! (>= (get current-level storage) amount) err-unauthorized)
    (map-set energy-storage
      { storage-id: storage-id }
      (merge storage { current-level: (- (get current-level storage) amount) })
    )
    (var-set grid-energy-balance (+ (var-get grid-energy-balance) (to-int amount)))
    (ok true)
  )
)

;; Update grid energy balance
(define-public (update-grid-balance (amount int))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set grid-energy-balance (+ (var-get grid-energy-balance) amount))
    (ok (var-get grid-energy-balance))
  )
)

;; Read-only Functions

;; Get storage facility details
(define-read-only (get-storage (storage-id uint))
  (ok (unwrap! (map-get? energy-storage { storage-id: storage-id }) err-not-found))
)

;; Get current grid energy balance
(define-read-only (get-grid-balance)
  (ok (var-get grid-energy-balance))
)

;; Initialize contract
(begin
  (var-set grid-energy-balance 0)
  (var-set last-storage-id u0)
)

