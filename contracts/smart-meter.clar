;; Smart Meter Integration Contract

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))

(define-map smart-meters
  { meter-id: (string-ascii 24) }
  { owner: principal, energy-produced: uint, energy-consumed: uint })

(define-public (register-smart-meter (meter-id (string-ascii 24)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set smart-meters
      { meter-id: meter-id }
      { owner: tx-sender, energy-produced: u0, energy-consumed: u0 }))))

(define-public (update-meter-reading (meter-id (string-ascii 24)) (produced uint) (consumed uint))
  (let
    ((meter (unwrap! (map-get? smart-meters { meter-id: meter-id }) err-not-authorized)))
    (asserts! (is-eq tx-sender (get owner meter)) err-not-authorized)
    (ok (map-set smart-meters
      { meter-id: meter-id }
      { owner: (get owner meter),
        energy-produced: (+ (get energy-produced meter) produced),
        energy-consumed: (+ (get energy-consumed meter) consumed) }))))

(define-read-only (get-meter-reading (meter-id (string-ascii 24)))
  (map-get? smart-meters { meter-id: meter-id }))

