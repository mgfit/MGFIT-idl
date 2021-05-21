; docformat = 'rst'

function mgfit_init_emis, wavel, flux
;+
;     This function initializes the emission line list with the specified 
;     wavelength array and flux array.
;
; :Returns:
;     type=arrays of structures. This function returns the emission line list 
;                               stored in the arrays of structures 
;                               { wavelength: 0.0, peak:0.0, sigma1:0.0, flux:0.0, 
;                                 uncertainty:0.0, redshift:0.0, resolution:0.0, 
;                                 blended:0, Ion:'', Multiplet:'', 
;                                 LowerTerm:'', UpperTerm:'', g1:'', g2:''}
;
; :Params:
;     wavel  :      in, required, type=arrays
;                   the wavelength array
;            
;     flux   :      in, required, type=arrays
;                   the flux array
;
;
; :Examples:
;    For example::
;
;     IDL> emissionlines=mgfit_init_emis(wavel, flux)
;
; :Categories:
;   Emission, Initialization
;
; :Dirs:
;  ./
;      Main routines
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
;     20/07/2014, A. Danehkar,  IDL code written.
;- 
  emissionlinestructure={wavelength:double(0.0), peak:double(0.0), sigma1:double(0.0), flux:double(0.0), continuum:double(0.0), uncertainty:double(0.0), redshift:double(0.0), resolution:double(0.0), blended:0, Ion:'', Multiplet:'', LowerTerm:'', UpperTerm:'', g1:'', g2:''}

  temp=size(wavel,/DIMENSIONS)
  speclength=temp[0]
   
  emissionlines=replicate(emissionlinestructure, speclength)
  for i=0, speclength-1 do begin 
    emissionlines[i].wavelength = wavel[i]
    emissionlines[i].flux = flux[i]
    emissionlines[i].peak = 0.0
    emissionlines[i].uncertainty = 0.0
  endfor
  return, emissionlines
end
