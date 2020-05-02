; docformat = 'rst'

function mgfit_synth_spec, lines, spec, continuum=continuum
;+
;     This function makes a spectrum from given lines. 
;  
; :Returns:
;     type=arrays of structures. This function returns the spectrum
;                               in the arrays of structures 
;                               {wavelength: 0.0, flux:0.0, residual:0.0}
;
; :Params:          
;     lines  :      in, required, type=arrays of structures
;                   the line list stored in
;                   the arrays of structures
;                   { wavelength: 0.0, 
;                     peak:0.0, 
;                     sigma1:0.0, 
;                     flux:0.0, 
;                     continuum:0.0, 
;                     uncertainty:0.0, 
;                     redshift:0.0, 
;                     resolution:0.0, 
;                     blended:0, 
;                     Ion:'', 
;                     Multiplet:'', 
;                     LowerTerm:'', 
;                     UpperTerm:'', 
;                     g1:'', 
;                     g2:''}
;  
;     spectrum  :     in, required, type=arrays of structures
;                     the input spectrum stored in
;                     the arrays of structures
;                     { wavelength: 0.0, flux:0.0, residual:0.0}
;  
; :Examples:
;    For example::
;
;     IDL> syntheticspec=mgfit_synth_spec(emissionlines, syntheticspec)
;
; :Categories:
;   Spectrum
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
;                 in ALFA by R. Wessson.
;     
;     22/11/2017, A. Danehkar, A few changes.
;- 
  temp=size(lines,/DIMENSIONS)
  if size(temp,/DIMENSIONS) gt 1 then begin
    nlines=temp[1]
  endif else begin
    nlines=temp[0]
  endelse
  for i=0, nlines-1 do begin
    location = where(abs(lines[i].redshift*lines[i].wavelength - spec.wavelength) lt (5.*lines[i].wavelength/lines[i].resolution))
    temp=size(location,/DIMENSIONS)
    if temp[0] gt 0 and lines[i].sigma1 ne 0 then begin
      ;spec[location].flux = spec[location].flux + lines[i].peak*exp((-(spec[location].wavelength-lines[i].redshift*lines[i].wavelength)^2)/(2*(lines[i].sigma1)^2))
      spec[location].flux = spec[location].flux + lines[i].peak*exp((-(spec[location].wavelength-lines[i].redshift*lines[i].wavelength)^2.)/(2.*(lines[i].wavelength/lines[i].resolution)^2.))
      if keyword_set(continuum) then begin
        spec[location].flux = spec[location].flux +  lines[i].continuum
      endif
    endif
  endfor
  return, spec
end
