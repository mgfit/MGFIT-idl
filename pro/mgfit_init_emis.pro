function mgfit_init_emis, wavel, flux
;+
; NAME:
;     mgfit_init_emis
; PURPOSE:
;     initialize the emission line list with the specified 
;     wavelength array and flux array
; EXPLANATION:
;
; CALLING SEQUENCE:
;     lines=mgfit_init_emis(wavel, flux)
;
; INPUTS:
;     wavel - the wavelength array
;     flux - the flux array
;
; RETURN:  emissionlines,
;          array with the following structure
;          { wavelength: 0.0, 
;            peak:0.0, 
;            sigma1:0.0, 
;            flux:0.0, 
;            uncertainty:0.0, 
;            redshift:0.0, 
;            resolution:0.0, 
;            blended:0, Ion:'', 
;            Multiplet:'', 
;            LowerTerm:'', 
;            UpperTerm:'', 
;            g1:'', 
;            g2:''}
;
; REVISION HISTORY:
;     IDL by A. Danehkar, 20/07/2014
;- 
  emissionlinestructure={wavelength: 0.0, peak:0.0, sigma1:0.0, flux:0.0, uncertainty:0.0, redshift:0.0, resolution:0.0, blended:0, Ion:'', Multiplet:'', LowerTerm:'', UpperTerm:'', g1:'', g2:''}

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
