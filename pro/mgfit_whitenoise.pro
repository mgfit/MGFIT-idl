; docformat = 'rst'

function mgfit_whitenoise, spectrumdata, rebin_resolution=rebin_resolution
;+
;     This function extracts the white noise from the spectrum.
;  
; :Returns:
;     type=arrays of structures. This function returns the white noise
;                               in the arrays of structures 
;                               {wavelength: 0.0, flux:0.0, residual:0.0}
;
; :Keywords:
;     rebin_resolution     :    in, optional, type=float
;                               increase the spectrum resolution by rebinning
;                               resolution by rebin_resolution times
;
; :Params:          
;     lines  :      in, required, type=arrays of structures
;                   the whitenoise stored in
;                   the arrays of structures
;                   { wavelength: 0.0, flux:0.0, residual:0.0}
;  
;     spectrumdata  :   in, required, type=arrays of structures
;                       the input spectrum stored in
;                       the arrays of structures
;                       { wavelength: 0.0, flux:0.0, residual:0.0}
;  
; :Examples:
;    For example::
;
;     IDL> specdata=mgfit_whitenoise(specdata)
;
; :Categories:
;   Spectrum, Noise, Uncertainty
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
;     20/07/2014, A. Danehkar, Translated to IDL from FORTRAN 
;                 in ALFA by R. Wessson
;     
;     21/11/2017, A. Danehkar, Some modifications.
;- 
  spectrumstructure={wavelength: 0.0, flux:0.0, residual:0.0}
  temp=size(spectrumdata,/DIMENSIONS)
  speclength=temp[0]
  whitenoise =replicate(spectrumstructure, speclength)
  ;residuals_num=50
  ;residuals_num2=10
  if keyword_set(rebin_resolution) eq 1 then begin
    residuals_num=long(10*rebin_resolution)
    residuals_num2=long(5*rebin_resolution)
  endif else begin
    residuals_num=10
    residuals_num2=5
  endelse
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
    rms_noise=(total(specsample[0:residuals_num2-1]^2.)/float(residuals_num2))^0.5  
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
