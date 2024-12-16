;; Pricing Oracle Contract

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))

(define-data-var current-price uint u0)

(define-public (set-price (new-price uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (var-set current-price new-price))))

(define-read-only (get-current-price)
  (ok (var-get current-price)))

