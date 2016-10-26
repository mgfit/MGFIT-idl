function mgfit_init_seed
;+
; NAME:
;     mgfit_init_seed
; PURPOSE:
;     initialize the random seed based on the system clock
; EXPLANATION:
;
; CALLING SEQUENCE:
;     continuum=mgfit_contin(spectrumdata)
;
; RETURN:  20 randomNumbers
;
; REVISION HISTORY:
;     Translated from FORTRAN in ALFA by R. Wessson
;     to IDL by A. Danehkar, 20/07/2014
;- 
; Initialize the sequence and generate random numbers:
  common random_seed, seed
  n=20
  ; seed = long(systime(/seconds) )
  seed = long((systime(1) - long(systime(1))) * 1.e8)
  randomNumbers = randomu(seed, n) 
  return, randomNumbers
end
