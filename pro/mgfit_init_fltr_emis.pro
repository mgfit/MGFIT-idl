; docformat = 'rst'

function mgfit_init_fltr_emis, emissionlines, wavel_min, wavel_max, redshift
;+
;     This function initializes and filters the emission line lists 
;     from the list of emission lines within the specified wavelength range
;
; :Returns:
;     type=arrays of structures. This function returns the lits of 
;                                selected emission lines in the arrays of structures 
;                                { wavelength: 0.0, peak:0.0, sigma1:0.0, flux:0.0, 
;                                  continuum:0.0, uncertainty:0.0, redshift:0.0, 
;                                  resolution:0.0, blended:0, Ion:'', Multiplet:'', 
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
;     wavel_min       :     in, required, type=float   
;                           the minimum wavelength
;     
;     wavel_max        :    in, required, type=float   
;                           the maximum wavelength
;
;
; :Examples:
;    For example::
;
;     IDL> emissionlines=mgfit_init_fltr_emis(strongline_data, wavel_min, wavel_max)
;
; :Categories:
;   Emission, Initialization
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
;     20/07/2014, A. Danehkar, IDL code written.
;     
;     15/01/2017, A. Danehkar, A few bugs fixed
;- 
  emissionlinestructure={wavelength: 0.0, peak:0.0, sigma1:0.0, flux:0.0, continuum:0.0, uncertainty:0.0, redshift:0.0, resolution:0.0, blended:0, Ion:'', Multiplet:'', LowerTerm:'', UpperTerm:'', g1:'', g2:''}

  temp=size(emissionlines,/DIMENSIONS)
  speclength=temp[0]
  linelocation01 = where(redshift*emissionlines.wavelength ge wavel_min)
  linelocation1=min(linelocation01)
  linelocation02 = where(redshift*emissionlines.wavelength le wavel_max)
  linelocation2=max(linelocation02)
  nlines = linelocation2 - linelocation1 + 1

  if nlines gt 0 then begin
    emissionlines_select=replicate(emissionlinestructure, nlines)
    emissionlines_select[0:nlines-1].wavelength=emissionlines[linelocation1:linelocation2].wavelength
    emissionlines_select[0:nlines-1].uncertainty = 0.0
    emissionlines_select[0:nlines-1].peak = 1000.0
    emissionlines_select[0:nlines-1].Ion = emissionlines[linelocation1:linelocation2].Ion
    emissionlines_select[0:nlines-1].Multiplet = emissionlines[linelocation1:linelocation2].Multiplet
    emissionlines_select[0:nlines-1].LowerTerm = emissionlines[linelocation1:linelocation2].LowerTerm
    emissionlines_select[0:nlines-1].UpperTerm = emissionlines[linelocation1:linelocation2].UpperTerm
    emissionlines_select[0:nlines-1].g1 = emissionlines[linelocation1:linelocation2].g1
    emissionlines_select[0:nlines-1].g2 = emissionlines[linelocation1:linelocation2].g2
  endif else begin
    emissionlines_select = 0
  endelse
  return, emissionlines_select
end
