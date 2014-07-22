#lang racket

(define (smallest-divisor n)
  (find-divisor n 2))

(define (square x) (* x x))

(define (enumerate-interval a b)
  (if (> a b)
      null
      (cons a (enumerate-interval (+ a 1) b))))

(define (find-divisor n test-divisor)
  (cond ((> (square test-divisor) n) 
         n)
        ((divides? test-divisor n) 
         test-divisor)
        (else (find-divisor 
               n 
               (+ test-divisor 1)))))

(define (divides? a b)
  (= (remainder b a) 0))

(define (prime? n)
  (= n (smallest-divisor n)))

(define (sum-primes1 a b)
  (define (iter count accum)
    (cond ((> count b) accum)
          ((prime? count)
           (iter (+ count 1)
                 (+ count accum)))
          (else (iter (+ count 1) accum))))
  (iter a 0))

(define (sum-primes2 a b)
  (foldl 
   +
   0
   (filter prime? (enumerate-interval a b))))


;;;;; Streams ;;;;;



; stream implementation

(define empty-stream null)

(define stream-null? null?)

(define (stream? s)
  (cond [(not (pair? s)) #f]
        [(stream-null? s) #t]
        [#t (stream? (stream-cdr s))]))

(define (stream-car stream) 
  (car stream))

(define (stream-cdr stream) 
  (force (cdr stream)))

(define-syntax cons-stream
  (syntax-rules ()
    [(cons-stream a b)
     (cons a (delay b))]))



; utility functions

(define (stream-ref s n)
  (if (= n 0)
      (stream-car s)
      (stream-ref (stream-cdr s) (- n 1))))

(define (stream-filter pred s)
  (cond [(stream-null? s) empty-stream]
        [(pred (stream-car s))
         (cons-stream (stream-car s)
                       (stream-filter pred (stream-cdr s)))]
        [#t (stream-filter pred (stream-cdr s))]))

(define (stream-for-each proc s)
  (if (stream-null? s)
      'done
      (begin 
        (proc (stream-car s))
        (stream-for-each proc 
                         (stream-cdr s)))))

(define (stream-enumerate-interval a b)
  (if (> a b)
      empty-stream
      (cons-stream a (stream-enumerate-interval (+ a 1) b))))



; for printing

(define (display-stream s)
  (stream-for-each display-line s))

(define (display-line x)
  (newline)
  (display x))

; ex 3.50
;(define (stream-map proc . argstreams)
;  (if (⟨??⟩ (car argstreams))
;      the-empty-stream
;      (⟨??⟩
;       (apply proc (map ⟨??⟩ argstreams))
;       (apply stream-map
;              (cons proc 
;                    (map ⟨??⟩ 
;                         argstreams))))))

(define (my-map proc . args)
  (define (my-inner-map proc args)
    (if (null? args)
        null
        (cons (proc (car args))
              (my-inner-map proc (cdr args)))))
  (if (null? (car args))
      null
      (let [(firsts (my-inner-map car args))
            (rests (my-inner-map cdr args))]
        (cons (apply proc firsts)
              (apply my-map proc rests)))))



; tests

(my-map + 
     (list 1 2 3) 
     (list 40 50 60) 
     (list 700 800 900))