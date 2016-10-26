function mgfit_init_spec, wavel, flux
;+
; NAME:
;     mgfit_init_emis
; PURPOSE:
;     create the spectrum from the wavelength 
;     array and flux array 
; EXPLANATION:
;
; CALLING SEQUENCE:
;     spectrum=mgfit_init_spec(wavel, flux)
;
; INPUTS:
;     wavel - the wavelength array
;     flux - the flux array
;
; RETURN:  the spectrum
;          { wavelength: 0.0, 
;            flux:0.0, 
;            residual:0.0}
;
; REVISION HISTORY:
;     IDL by A. Danehkar, 20/07/2014
;- 
  spectrumstructure={wavelength: 0.0, flux:0.0, residual:0.0}
   
  temp=size(wavel,/DIMENSIONS)
  speclength=temp[0]
   
  spectrumdata=replicate(spectrumstructure, speclength)
  for i=0, speclength-1 do begin 
    spectrumdata[i].wavelength = wavel[i]
    spectrumdata[i].flux = flux[i] 
    spectrumdata[i].residual = 0.0
  endfor
  return, spectrumdata
end
