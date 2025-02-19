;; Energy Production Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))

;; Data Variables
(define-data-var last-producer-id uint u0)

;; Data Maps
(define-map producers
  { producer-id: uint }
  {
    owner: principal,
    energy-type: (string-ascii 20),
    capacity: uint,
    total-generated: uint
  }
)

(define-map energy-generation
  { producer-id: uint, timestamp: uint }
  { amount: uint }
)

;; Public Functions

;; Register a new energy producer
(define-public (register-producer (energy-type (string-ascii 20)) (capacity uint))
  (let
    (
      (new-id (+ (var-get last-producer-id) u1))
    )
    (map-set producers
      { producer-id: new-id }
      {
        owner: tx-sender,
        energy-type: energy-type,
        capacity: capacity,
        total-generated: u0
      }
    )
    (var-set last-producer-id new-id)
    (ok new-id)
  )
)

;; Record energy generation
(define-public (record-generation (producer-id uint) (amount uint))
  (let
    (
      (producer (unwrap! (map-get? producers { producer-id: producer-id }) err-not-found))
      (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
    )
    (asserts! (is-eq tx-sender (get owner producer)) err-unauthorized)
    (map-set energy-generation
      { producer-id: producer-id, timestamp: current-time }
      { amount: amount }
    )
    (map-set producers
      { producer-id: producer-id }
      (merge producer { total-generated: (+ (get total-generated producer) amount) })
    )
    (ok true)
  )
)

;; Read-only Functions

;; Get producer details
(define-read-only (get-producer (producer-id uint))
  (ok (unwrap! (map-get? producers { producer-id: producer-id }) err-not-found))
)

;; Get energy generation for a specific timestamp
(define-read-only (get-energy-generation (producer-id uint) (timestamp uint))
  (ok (unwrap! (map-get? energy-generation { producer-id: producer-id, timestamp: timestamp }) err-not-found))
)

;; Get total energy generated by a producer
(define-read-only (get-total-generated (producer-id uint))
  (ok (get total-generated (unwrap! (map-get? producers { producer-id: producer-id }) err-not-found)))
)

;; Initialize contract
(begin
  (var-set last-producer-id u0)
)

