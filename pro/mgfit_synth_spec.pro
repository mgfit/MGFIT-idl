function mgfit_synth_spec, lines, spec
;+
; NAME:
;     mgfit_contin
; PURPOSE:
;     make a spectrum from given lines 
; EXPLANATION:
;
; CALLING SEQUENCE:
;     continuum=mgfit_contin(spectrumdata)
;
; INPUTS:
;     lines - the line list 
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
;     spectrum  - the input spectrum 
;          array with the following structure
;          { wavelength: 0.0, 
;            flux:0.0, 
;            residual:0.0}
; 
; RETURN:  the modified spectrum
;          { wavelength: 0.0, 
;            flux:0.0, 
;            residual:0.0}
;
; REVISION HISTORY:
;     Translated from FORTRAN in ALFA by R. Wessson
;     to IDL by A. Danehkar, 20/07/2014
;- 
  temp=size(lines,/DIMENSIONS)
  if size(temp,/DIMENSIONS) gt 1 then begin
    nlines=temp[1]
  endif else begin
    nlines=temp[0]
  endelse
  for i=0, nlines-1 do begin
    location = where(abs(lines[i].redshift*lines[i].wavelength - spec.wavelength) lt (5*lines[i].wavelength/lines[i].resolution))
    temp=size(location,/DIMENSIONS)
    if temp[0] gt 0 and lines[i].sigma1 ne 0 then begin
      ;spec[location].flux = spec[location].flux + lines[i].peak*exp((-(spec[location].wavelength-lines[i].redshift*lines[i].wavelength)^2)/(2*(lines[i].sigma1)^2))
      spec[location].flux = spec[location].flux + lines[i].peak*exp((-(spec[location].wavelength-lines[i].redshift*lines[i].wavelength)^2)/(2*(lines[i].wavelength/lines[i].resolution)^2))
    endif
  endfor
  return, spec
end
