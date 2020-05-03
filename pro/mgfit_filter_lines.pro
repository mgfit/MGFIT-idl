; docformat = 'rst'

function mgfit_filter_lines, line_filter, lines_input
  ;+
  ;     This function combines two sets of detected lines.
  ;
  ; :Returns:
  ;     type=arrays of structures. This function returns the list of
  ;                                filtered emission lines in the arrays of structures
  ;                                { wavelength: 0.0, peak:0.0, sigma1:0.0, flux:0.0,
  ;                                  continuum:0.0, uncertainty:0.0, redshift:0.0,
  ;                                  resolution:0.0, blended:0, Ion:'', Multiplet:'',
  ;                                  LowerTerm:'', UpperTerm:'', g1:'', g2:''}
  ; :Params:
  ;
  ;     line_filter: in, required, type=arrays of structures
  ;                  the input lines in the arrays of structures
  ;                  for filtering
  ;                         { wavelength: 0.0,
  ;                           flux:0.0,
  ;                           uncertainty:0.0,
  ;                           redshift:0.0}
  ;                         
  ;     lines_input: in, required, type=arrays of structures
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
  ;
  ; :Examples:
  ;    For example::
  ;
  ;     IDL> lines_out=mgfit_filter_lines(line_filter, lines_input)
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
  ;     28/10/2019, A. Danehkar, Create function.
  ;-
  emissionlinestructure={wavelength: 0.0, peak:0.0, sigma1:0.0, flux:0.0, continuum:0.0, uncertainty:0.0, redshift:0.0, resolution:0.0, blended:0, Ion:'', Multiplet:'', LowerTerm:'', UpperTerm:'', g1:'', g2:''}
  temp=size(line_filter,/DIMENSIONS)
  if size(temp,/DIMENSIONS) gt 1 then begin
    nlines=temp[1]
  endif else begin
    nlines=temp[0]
  endelse
  lines=replicate(emissionlinestructure, nlines)
  for i=0, nlines-1 do begin
    wavelength=line_filter[i].wavelength
    loc1=where(lines_input.wavelength eq wavelength)
    if loc1 ne -1 then begin
        lines[i]=lines_input[loc1]
    endif
  endfor
  return, lines
end

