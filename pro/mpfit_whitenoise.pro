function mpfit_whitenoise, spectrumdata
;+
; NAME:
;     mpfit_whitenoise
; PURPOSE:
;     extract the white noise from the spectrum
; EXPLANATION:
;
; CALLING SEQUENCE:
;     whitenoise=mpfit_whitenoise(spectrumdata)
;
; INPUTS:
;     spectrumdata - the spectrumdata
;          { wavelength: 0.0, 
;            flux:0.0, 
;            residual:0.0}
; RETURN:  whitenoise
;          { wavelength: 0.0, 
;            flux:0.0, 
;            residual:0.0}
;
; REVISION HISTORY:
;     IDL by A. Danehkar, 20/07/2014
;- 
  spectrumstructure={wavelength: 0.0, flux:0.0, residual:0.0}
  temp=size(spectrumdata,/DIMENSIONS)
  speclength=temp[0]
  whitenoise =replicate(spectrumstructure, speclength)
  residuals_num=50
  residuals_num2=10
  specsample=fltarr(2*residuals_num+1)
  whitenoise[*].wavelength = spectrumdata[*].wavelength
  whitenoise[*].flux = spectrumdata[*].flux
  whitenoise[*].residual = 0.0
  for i=residuals_num, speclength-residuals_num-1 do begin 
    for j=-residuals_num, residuals_num do begin
      specsample[j+residuals_num] = spectrumdata[i+j].flux
    endfor
    sortsample=sort(specsample)
    specsample=specsample[sortsample]
    rms_noise=(total(specsample[0:residuals_num2-1]^2)/float(residuals_num2))^0.5  
    whitenoise[i].residual = rms_noise
  endfor
  whitenoise[0:residuals_num-1].residual = whitenoise[residuals_num].residual
  whitenoise[speclength-residuals_num-1:speclength-1].residual = whitenoise[speclength-residuals_num-2].residual
  residualmin=min(whitenoise.residual)
  if residualmin eq 0 then begin
    residualmin=min(whitenoise[where(whitenoise.residual ne 0)].residual)
    whitenoise[where(whitenoise.residual eq 0)].residual=residualmin
  endif
  return, whitenoise
end
