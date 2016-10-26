function mgfit_contin, spectrumdata
;+
; NAME:
;     mgfit_contin
; PURPOSE:
;     extract the continuum from the spectrum
; EXPLANATION:
;
; CALLING SEQUENCE:
;     continuum=mgfit_contin(spectrumdata)
;
; INPUTS:
;     spectrumdata - the spectrumdata
;          { wavelength: 0.0, 
;            flux:0.0, 
;            residual:0.0}
; RETURN:  continuum
;          { wavelength: 0.0, 
;            flux:0.0, 
;            residual:0.0}
;
; REVISION HISTORY:
;     Translated from FORTRAN in ALFA by R. Wessson
;     to IDL by A. Danehkar, 20/07/2014
;- 
  spectrumstructure={wavelength: 0.0, flux:0.0, residual:0.0}
  temp=size(spectrumdata,/DIMENSIONS)
  speclength=temp[0]
  continuum =replicate(spectrumstructure, speclength)
  residuals_num=50
  residuals_num2=25
  specsample=fltarr(2*residuals_num+1)
  continuum[*].wavelength = spectrumdata[*].wavelength
  continuum[*].flux = 0.0
  for i=residuals_num, speclength-residuals_num-1 do begin 
    for j=-residuals_num, residuals_num do begin
      specsample[j+residuals_num] = spectrumdata[i+j].flux
    endfor
    sortsample=sort(specsample)
    specsample=specsample[sortsample]
    continuum[i].flux = specsample[residuals_num2]
  endfor
  continuum[0:residuals_num-1].flux = continuum[residuals_num].flux
  continuum[speclength-residuals_num-1:speclength-1].flux = continuum[speclength-residuals_num-2].flux
  return, continuum
end
