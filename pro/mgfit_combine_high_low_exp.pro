; docformat = 'rst'

function mgfit_combine_high_low_exp, line_list, lines_hi, lines_lo, saturation_hi_limit
;+
;     This function combines two sets of detected lines.
;
; :Returns:
;     type=arrays of structures. This function returns the list of
;                                selected emission lines in the arrays of structures
;                                { wavelength: 0.0, peak:0.0, sigma1:0.0, flux:0.0,
;                                  continuum:0.0, uncertainty:0.0, redshift:0.0,
;                                  resolution:0.0, blended:0, Ion:'', Multiplet:'',
;                                  LowerTerm:'', UpperTerm:'', g1:'', g2:''}
; :Params:
;     lines_hi:    in, required, type=arrays of structures    
;                  the input lines of the observation
;                  with the high exposure time
;                  stored in the arrays of structures 
;                         { wavelength: 0.0, 
;                           peak:0.0, 
;                           sigma1:0.0, 
;                           flux:0.0, 
;                           continuum:0.0, 
;                           uncertainty:0.0, 
;                           redshift:0.0, 
;                           resolution:0.0, 
;                           blended:0, 
;                           Ion:'', 
;                           Multiplet:'', 
;                           LowerTerm:'', 
;                           UpperTerm:'', 
;                           g1:'', 
;                           g2:''}
;                           
;     lines_lo:    in, required, type=arrays of structures    
;                  the input lines of the observation
;                  with the low exposure time
;                         { wavelength: 0.0, 
;                           peak:0.0, 
;                           sigma1:0.0, 
;                           flux:0.0, 
;                           continuum:0.0, 
;                           uncertainty:0.0, 
;                           redshift:0.0, 
;                           resolution:0.0, 
;                           blended:0, 
;                           Ion:'', 
;                           Multiplet:'', 
;                           LowerTerm:'', 
;                           UpperTerm:'', 
;                           g1:'', 
;                           g2:''}
;                           
;     lines:       in, required, type=arrays of structures    
;                  the output lines in the arrays of structures 
;                         { wavelength: 0.0, 
;                           peak:0.0, 
;                           sigma1:0.0, 
;                           flux:0.0, 
;                           continuum:0.0, 
;                           uncertainty:0.0, 
;                           redshift:0.0, 
;                           resolution:0.0, 
;                           blended:0, 
;                           Ion:'', 
;                           Multiplet:'', 
;                           LowerTerm:'', 
;                           UpperTerm:'', 
;                           g1:'', 
;                           g2:''}
;                           
;     saturation_hi_limit:   in, required, type=double     
;                  the flux upper limit for the saturation of 
;                  the observation with the high exposure time.
;
; :Examples:
;    For example::
;
;     IDL> lines=mgfit_combine_two_obs(lines, lines_hi, lines_lo, saturation_hi_limit)
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
;     26/10/2019, A. Danehkar, Create function.
;-
  emissionlinestructure={wavelength: double(0.0), peak:double(0.0), sigma1:double(0.0), flux:double(0.0), continuum:double(0.0), uncertainty:double(0.0), redshift:double(0.0), resolution:double(0.0), blended:0, Ion:'', Multiplet:'', LowerTerm:'', UpperTerm:'', g1:'', g2:''}
  temp=size(line_list,/DIMENSIONS)
  if size(temp,/DIMENSIONS) gt 1 then begin
    nlines=temp[1]
  endif else begin
    nlines=temp[0]
  endelse
  line_list.peak=0.0
  for i=0, nlines-1 do begin
    wavelength=line_list[i].wavelength
    loc_hi=where(lines_hi.wavelength eq wavelength)
    loc_lo=where(lines_lo.wavelength eq wavelength)
    peak_hi=0
    peak_lo=0
    if loc_hi ne -1 then peak_hi = lines_hi[loc_hi].peak
    if loc_lo ne -1 then peak_lo = lines_lo[loc_lo].peak
    if peak_hi ne 0 then begin
       if peak_hi lt saturation_hi_limit then begin
          line_list[i]=lines_hi[loc_hi]
       endif else begin
          if peak_lo ne 0 then begin
            line_list[i]=lines_lo[loc_lo]
          endif
       endelse
    endif else begin
      if peak_lo ne 0 then begin
        line_list[i]=lines_lo[loc_lo]
      endif
    endelse
  endfor
  nonzero_loc = where(line_list.peak ne 0)
  temp=size(nonzero_loc,/DIMENSIONS)
  if size(temp,/DIMENSIONS) gt 1 then begin
    nlines=temp[1]
  endif else begin
    nlines=temp[0]
  endelse
  if nlines gt 0 then begin
    lines=replicate(emissionlinestructure, nlines)
    lines=line_list[nonzero_loc]
  endif else begin
    lines=0
  endelse
  return, lines
end

