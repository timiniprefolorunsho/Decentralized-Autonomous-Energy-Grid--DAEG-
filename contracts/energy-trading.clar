;; Energy Trading Contract

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-invalid-price (err u102))

(define-map orders
  { order-id: uint }
  { seller: principal, amount: uint, price-per-unit: uint, status: (string-ascii 10) })

(define-data-var order-nonce uint u0)

(define-public (create-sell-order (amount uint) (price-per-unit uint))
  (let
    ((order-id (var-get order-nonce)))
    (map-set orders
      { order-id: order-id }
      { seller: tx-sender, amount: amount, price-per-unit: price-per-unit, status: "active" })
    (var-set order-nonce (+ order-id u1))
    (ok order-id)))

(define-public (cancel-sell-order (order-id uint))
  (let
    ((order (unwrap! (map-get? orders { order-id: order-id }) err-not-authorized)))
    (asserts! (is-eq (get seller order) tx-sender) err-not-authorized)
    (asserts! (is-eq (get status order) "active") err-not-authorized)
    (map-set orders
      { order-id: order-id }
      (merge order { status: "cancelled" }))
    (ok true)))

(define-public (buy-energy (order-id uint) (buy-amount uint))
  (let
    ((order (unwrap! (map-get? orders { order-id: order-id }) err-not-authorized)))
    (asserts! (is-eq (get status order) "active") err-not-authorized)
    (asserts! (<= buy-amount (get amount order)) err-not-authorized)
    (let
      ((total-price (* buy-amount (get price-per-unit order))))
      (if (< buy-amount (get amount order))
        (map-set orders
          { order-id: order-id }
          (merge order { amount: (- (get amount order) buy-amount) }))
        (map-set orders
          { order-id: order-id }
          (merge order { status: "completed" })))
      (ok true))))

(define-read-only (get-order (order-id uint))
  (map-get? orders { order-id: order-id }))

