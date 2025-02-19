;; Trading Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-insufficient-energy (err u103))

;; Data Variables
(define-data-var last-trade-id uint u0)

;; Data Maps
(define-map energy-balances
  { user: principal }
  { balance: int }
)

(define-map trades
  { trade-id: uint }
  {
    seller: principal,
    buyer: principal,
    amount: uint,
    price: uint,
    status: (string-ascii 10)
  }
)

;; Public Functions

;; Create a new trade offer
(define-public (create-trade (amount uint) (price uint))
  (let
    (
      (seller-balance (unwrap! (map-get? energy-balances { user: tx-sender }) err-not-found))
      (trade-id (+ (var-get last-trade-id) u1))
    )
    (asserts! (>= (get balance seller-balance) (to-int amount)) err-insufficient-energy)
    (map-set trades
      { trade-id: trade-id }
      {
        seller: tx-sender,
        buyer: tx-sender,
        amount: amount,
        price: price,
        status: "open"
      }
    )
    (var-set last-trade-id trade-id)
    (ok trade-id)
  )
)

;; Accept a trade offer
(define-public (accept-trade (trade-id uint))
  (let
    (
      (trade (unwrap! (map-get? trades { trade-id: trade-id }) err-not-found))
      (buyer-balance (default-to { balance: 0 } (map-get? energy-balances { user: tx-sender })))
      (seller-balance (unwrap! (map-get? energy-balances { user: (get seller trade) }) err-not-found))
    )
    (asserts! (is-eq (get status trade) "open") err-unauthorized)
    (asserts! (>= (stx-get-balance tx-sender) (get price trade)) err-unauthorized)

    ;; Transfer STX from buyer to seller
    (try! (stx-transfer? (get price trade) tx-sender (get seller trade)))

    ;; Update energy balances
    (map-set energy-balances
      { user: tx-sender }
      { balance: (+ (get balance buyer-balance) (to-int (get amount trade))) }
    )
    (map-set energy-balances
      { user: (get seller trade) }
      { balance: (- (get balance seller-balance) (to-int (get amount trade))) }
    )

    ;; Update trade status
    (map-set trades
      { trade-id: trade-id }
      (merge trade { buyer: tx-sender, status: "completed" })
    )
    (ok true)
  )
)

;; Cancel a trade offer
(define-public (cancel-trade (trade-id uint))
  (let
    (
      (trade (unwrap! (map-get? trades { trade-id: trade-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender (get seller trade)) err-unauthorized)
    (asserts! (is-eq (get status trade) "open") err-unauthorized)
    (map-set trades
      { trade-id: trade-id }
      (merge trade { status: "cancelled" })
    )
    (ok true)
  )
)

;; Read-only Functions

;; Get trade details
(define-read-only (get-trade (trade-id uint))
  (ok (unwrap! (map-get? trades { trade-id: trade-id }) err-not-found))
)

;; Get user's energy balance
(define-read-only (get-energy-balance (user principal))
  (ok (get balance (default-to { balance: 0 } (map-get? energy-balances { user: user }))))
)

;; Initialize contract
(begin
  (var-set last-trade-id u0)
)

