; docformat = 'rst'

function mgfit_contin, spectrumdata
;+
;     This function extracts the continuum from the spectrum.
;
; :Returns:
;    type=arrays of structures. This function returns 
;         the arrays of structures {wavelength: 0.0, flux:0.0, residual:0.0}.
;
; :Params:
;     spectrumdata  :     in, required, type=arrays of structures
;                         the arrays of structures {wavelength: 0.0, flux:0.0, residual:0.0}
;
; :Examples:
;    For example::
;
;     IDL> spectrumdata=mgfit_init_spec(wavel, flux)
;     IDL> continuum=mgfit_contin(spectrumdata)
;
; :Categories:
;   Continuum
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
;                              in ALFA by R. Wessson.
;
;     15/01/2017, A. Danehkar, A few bugs fixed
;-
  spectrumstructure={wavelength: 0.0, flux:0.0, residual:0.0}
  temp=size(spectrumdata,/DIMENSIONS)
  speclength=temp[0]
  continuum =replicate(spectrumstructure, speclength)
  ;residuals_num=long(50)
  ;residuals_num2=long(25)
  ;residuals_num=long(50)
  if speclength ge 10 then begin
    spec_len=10 ;floor(speclength/10.)*10
    if spec_len ge 50 then spec_len=50
  endif else begin
    spec_len=speclength
  endelse
  residuals_num=long(spec_len)
  residuals_num2=long(5)
  specsample=fltarr(2*residuals_num+1)
  continuum[*].wavelength = spectrumdata[*].wavelength
  continuum[*].flux = 0.0
  i=long(0)
  j=long(0)
  for i=residuals_num, speclength-residuals_num-1 do begin 
    for j=-residuals_num, residuals_num do begin
      specsample[j+residuals_num] = spectrumdata[i+j].flux
    endfor
    sortsample=sort(specsample)
    specsample=specsample[sortsample]
    continuum[i].flux = specsample[0]
  endfor
  continuum[0:residuals_num-1].flux = continuum[residuals_num].flux
  continuum[speclength-residuals_num-1:speclength-1].flux = continuum[speclength-residuals_num-2].flux
  ;plot,spectrumdata.wavelength,spectrumdata.flux
  ;plot,continuum.wavelength,continuum.flux
  poly_a = poly_fit(continuum.wavelength , continuum.flux , 1)
  continuum.flux = poly_a[0] + poly_a[1]*continuum.wavelength ; + poly_a[2]*continuum.wavelength^2
  ;plot,continuum.wavelength,continuum.flux
  return, continuum
end
