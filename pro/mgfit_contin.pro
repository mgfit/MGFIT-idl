; docformat = 'rst'

function mgfit_contin, spectrumdata, do_polyfit=do_polyfit
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
  spectrumstructure={wavelength: double(0.0), flux:double(0.0), residual:double(0.0)}
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
  if keyword_set(do_polyfit) eq 1 then begin
    residuals_num=long(spec_len)
    residuals_num2=long(5)
    specsample_flux=dblarr(2*residuals_num+1)
    continuum[*].wavelength = spectrumdata[*].wavelength
    continuum[*].flux = 0.0
    i=long(0)
    j=long(0)
    for i=residuals_num, speclength-residuals_num-1 do begin 
      for j=-residuals_num, residuals_num do begin
        specsample_flux[j+residuals_num] = spectrumdata[i+j].flux
      endfor
      sortsample=sort(specsample_flux)
      specsample_flux=specsample_flux[sortsample]
      continuum[i].flux = specsample_flux[0]
    endfor
    continuum[0:residuals_num-1].flux = continuum[residuals_num].flux
    continuum[speclength-residuals_num-1:speclength-1].flux = continuum[speclength-residuals_num-2].flux
    ;plot,spectrumdata.wavelength,spectrumdata.flux
    ;plot,continuum.wavelength,continuum.flux
    poly_a = poly_fit(continuum.wavelength , continuum.flux , 1)
    continuum.flux = poly_a[0] + poly_a[1]*continuum.wavelength ; + poly_a[2]*continuum.wavelength^2
    ;plot,continuum.wavelength,continuum.flux
  endif else begin
    spec_len=long(speclength/4)
    spec_len_half=long(spec_len/2)
    speclength_half=long(speclength/2)
    
    specsample_flux=spectrumdata[0:speclength_half-1].flux
    specsample_wave=spectrumdata[0:speclength_half-1].wavelength
    spectrumdata1=spectrumdata[0:speclength_half-1]
    sortsample=sort(specsample_flux)
    specsample_flux=specsample_flux[sortsample]
    specsample_wave=specsample_wave[sortsample]
    ;continuum.flux = mean(specsample_flux[0:spec_len])
    continuum_mean = mean(specsample_flux[0:spec_len_half-1])
    continuum_min = min(specsample_flux[0:spec_len_half-1])
    continuum_max = max(specsample_flux[0:spec_len_half-1])
    loc1=where(spectrumdata1.flux ge continuum_min and spectrumdata1.flux le continuum_max)
    spect_cont1=spectrumdata1[loc1]
    temp=size(loc1,/DIMENSIONS)
    spect_cont1_len=temp[0]
    
    specsample_flux=spectrumdata[speclength_half:speclength-1].flux
    specsample_wave=spectrumdata[speclength_half:speclength-1].wavelength
    spectrumdata2=spectrumdata[speclength_half:speclength-1]
    sortsample=sort(specsample_flux)
    specsample_flux=specsample_flux[sortsample]
    specsample_wave=specsample_wave[sortsample]
    ;continuum.flux = mean(specsample_flux[0:spec_len])
    continuum_mean = mean(specsample_flux[0:spec_len_half-1])
    continuum_min = min(specsample_flux[0:spec_len_half-1])
    continuum_max = max(specsample_flux[0:spec_len_half-1])
    loc1=where(spectrumdata2.flux ge continuum_min and spectrumdata2.flux le continuum_max)
    spect_cont2=spectrumdata2[loc1]
    temp=size(loc1,/DIMENSIONS)
    spect_cont2_len=temp[0]
    
    spect_cont_len=spect_cont1_len+spect_cont2_len
    spect_cont =replicate(spectrumstructure, spect_cont_len)
    spect_cont[0:spect_cont1_len-1]=spect_cont1
    spect_cont[spect_cont1_len:spect_cont_len-1]=spect_cont2
        
    spect_cont.flux=median(spect_cont.flux,3)
    poly_a = poly_fit(spect_cont.wavelength, spect_cont.flux , 1)
    continuum[*].wavelength = spectrumdata[*].wavelength
    ;continuum[*].flux = 0.0
    continuum.flux = poly_a[0] + poly_a[1]*continuum.wavelength ;+ poly_a[2]*continuum.wavelength^2. ; + poly_a[3]*continuum.wavelength^3.
  endelse
  return, continuum
end
