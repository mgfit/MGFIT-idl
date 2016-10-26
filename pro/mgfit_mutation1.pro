function mgfit_mutation1
;+
; NAME:
;     mgfit_mutation1
; PURPOSE:
;     genetic algorithm mutation type-1
; EXPLANATION:
;
; CALLING SEQUENCE:
;     value=mgfit_mutation1()
;
; RETURN:  value - mutation rate
;
; REVISION HISTORY:
;     Translated from FORTRAN in ALFA by R. Wessson
;     to IDL by A. Danehkar, 20/07/2014
;- 
  common random_seed, seed
  value=1.0
  random = randomu(seed)
  if (random le 0.05) then begin
    value=1.*random
  endif 
  if (random ge 0.95) then begin
    value=2+(1.*(random-1))
  endif 
  return, value
end
