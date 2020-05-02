pro mgfit_write_lines, lines, filename
;+
;     This function save detected lines.
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
;     filename:     in, required, type=string
;                   the file name for writing the lines.
;
; :Examples:
;    For example::
;
;     IDL> mgfit_write_lines, emissionlines, filename
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
;     22/10/2019, A. Danehkar, Create function.
;-
  temp=size(lines,/DIMENSIONS)
  if size(temp,/DIMENSIONS) gt 1 then begin
    nlines=temp[1]
  endif else begin
    nlines=temp[0]
  endelse
  output_filename=filename
  openw, lun1, output_filename, /GET_LUN
  for i=0, nlines-1 do begin
    if lines[i].sigma1 ne 0.0 and lines[i].peak ne 0.0 and lines[i].flux ne 0.0 and lines[i].resolution ne 0.0  then begin
      printf, lun1, format='(F-12.4," ",E-14.7," ",E-14.7," ",E-14.7," ",E-14.7," ",E-14.7," ",F-16.10," ",F-16.2," ",I-3," ",A-18," ",A-14," ",A-18," ",A-18," ",A-3," ",A-3)', $
            lines[i].wavelength, lines[i].peak, lines[i].sigma1, lines[i].flux, lines[i].continuum, lines[i].uncertainty, $
            lines[i].redshift, lines[i].resolution, lines[i].blended, lines[i].Ion, lines[i].Multiplet, $
            lines[i].LowerTerm, lines[i].UpperTerm, lines[i].g1, lines[i].g2
    endif
  endfor
  free_lun, lun1
end

