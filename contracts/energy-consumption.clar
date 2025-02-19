;; Energy Consumption Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))

;; Data Variables
(define-data-var last-consumer-id uint u0)

;; Data Maps
(define-map consumers
  { consumer-id: uint }
  {
    owner: principal,
    consumer-type: (string-ascii 20),
    max-consumption: uint,
    total-consumed: uint
  }
)

(define-map energy-consumption
  { consumer-id: uint, timestamp: uint }
  { amount: uint }
)

;; Public Functions

;; Register a new energy consumer
(define-public (register-consumer (consumer-type (string-ascii 20)) (max-consumption uint))
  (let
    (
      (new-id (+ (var-get last-consumer-id) u1))
    )
    (map-set consumers
      { consumer-id: new-id }
      {
        owner: tx-sender,
        consumer-type: consumer-type,
        max-consumption: max-consumption,
        total-consumed: u0
      }
    )
    (var-set last-consumer-id new-id)
    (ok new-id)
  )
)

;; Record energy consumption
(define-public (record-consumption (consumer-id uint) (amount uint))
  (let
    (
      (consumer (unwrap! (map-get? consumers { consumer-id: consumer-id }) err-not-found))
      (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
    )
    (asserts! (is-eq tx-sender (get owner consumer)) err-unauthorized)
    (map-set energy-consumption
      { consumer-id: consumer-id, timestamp: current-time }
      { amount: amount }
    )
    (map-set consumers
      { consumer-id: consumer-id }
      (merge consumer { total-consumed: (+ (get total-consumed consumer) amount) })
    )
    (ok true)
  )
)

;; Read-only Functions

;; Get consumer details
(define-read-only (get-consumer (consumer-id uint))
  (ok (unwrap! (map-get? consumers { consumer-id: consumer-id }) err-not-found))
)

;; Get energy consumption for a specific timestamp
(define-read-only (get-energy-consumption (consumer-id uint) (timestamp uint))
  (ok (unwrap! (map-get? energy-consumption { consumer-id: consumer-id, timestamp: timestamp }) err-not-found))
)

;; Get total energy consumed by a consumer
(define-read-only (get-total-consumed (consumer-id uint))
  (ok (get total-consumed (unwrap! (map-get? consumers { consumer-id: consumer-id }) err-not-found)))
)

;; Initialize contract
(begin
  (var-set last-consumer-id u0)
)

