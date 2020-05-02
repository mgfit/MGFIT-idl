; docformat = 'rst'

function mgfit_fltr_emis, emissionlines, wavel_min, wavel_max
;+
;     This function filters the emission line lists from the list of 
;     emission lines within the specified wavelength range.
;
; :Returns:
;     type=arrays of structures. This function returns the lits of 
;                                selected emission lines in the arrays of structures 
;                                { wavelength: 0.0, peak:0.0, sigma1:0.0, flux:0.0, 
;                                  uncertainty:0.0, redshift:0.0, resolution:0.0, 
;                                  blended:0, Ion:'', Multiplet:'', 
;                                  LowerTerm:'', UpperTerm:'', g1:'', g2:''}
;
; :Params:
;     emissionlines :     in, required, type=arrays of structures    
;                         the emission lines given for the selection
;                         stored in the arrays of structures 
;                         { wavelength: 0.0, 
;                           peak:0.0, 
;                           sigma1:0.0, 
;                           flux:0.0, 
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
;     wavel_min       :     in, required, type=float   
;                           the minimum wavelength
;     
;     wavel_max        :    in, required, type=float   
;                           the maximum wavelength
;
; :Examples:
;    For example::
;
;     IDL>  emissionlines_section=mgfit_fltr_emis(emissionlines, wavel_min, wavel_max)
;
; :Categories:
;   Emission, Filter
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
;     20/07/2014, A. Danehkar,  IDL code written.
;-
  emissionlinestructure={wavelength: 0.0, peak:0.0, sigma1:0.0, flux:0.0, continuum:0.0, uncertainty:0.0, redshift:0.0, resolution:0.0, blended:0, Ion:'', Multiplet:'', LowerTerm:'', UpperTerm:'', g1:'', g2:''}

  temp=size(emissionlines,/DIMENSIONS)
  speclength=temp[0]
  linelocation01 = where(emissionlines.wavelength ge wavel_min)
  linelocation1=min(linelocation01)
  linelocation02 = where(emissionlines.wavelength le wavel_max)
  linelocation2=max(linelocation02)
  nlines = linelocation2 - linelocation1 + 1

  if nlines gt 0 then begin
    emissionlines_select=replicate(emissionlinestructure, nlines)
    emissionlines_select[0:nlines-1]=emissionlines[linelocation1:linelocation2]
  endif
  return, emissionlines_select
end
