; docformat = 'rst'

function mgfit_init_seed
;+
;     This function initializes the random seed based on the system clock
;
; :Returns:
;     type=arrays. This function returns 20 random numbers.
;
; :Examples:
;    For example::
;
;     IDL> ret=mgfit_init_seed()
;
; :Categories:
;   Genetic Algorithm, Initialization
;
; :Dirs:
;  ./
;      Subroutines
;
; :Author:
;   Ashkbiz Danehkar
;
; :Copyright:
;   This library is released under a GNU General Public License.
;
; :Version:
;   0.1.0
;
; :History:
;     20/07/2014, A. Danehkar, Translated to IDL from FORTRAN 
;                              in ALFA by R. Wessson
;- 
  
; Initialize the sequence and generate random numbers:
  common random_seed, seed
  n=20
  ; seed = long(systime(/seconds) )
  seed = long((systime(1) - long(systime(1))) * 1.e8)
  randomNumbers = randomu(seed, n) 
  return, randomNumbers
end
