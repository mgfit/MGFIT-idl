; docformat = 'rst'

function mgfit_read_lines, filename
;+
;     This function save detected lines.
;
; :Returns:
;     type=arrays of structures. This function returns the lits of
;                                selected emission lines in the arrays of structures
;                                { wavelength: 0.0, peak:0.0, sigma1:0.0, flux:0.0,
;                                  continuum:0.0, uncertainty:0.0, redshift:0.0,
;                                  resolution:0.0, blended:0, Ion:'', Multiplet:'',
;                                  LowerTerm:'', UpperTerm:'', g1:'', g2:''}
; :Params:
;     filename:     in, required, type=string
;                   the file name for reading the lines.
;
; :Examples:
;    For example::
;
;     IDL> mgfit_save_lines, emissionlines
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
  emissionlinestructure={wavelength: 0.0, peak:0.0, sigma1:0.0, flux:0.0, continuum:0.0, uncertainty:0.0, redshift:0.0, resolution:0.0, blended:0, Ion:'', Multiplet:'', LowerTerm:'', UpperTerm:'', g1:'', g2:''}
  input_filename=filename
  rownumber=long(0)
  nlines= file_lines(input_filename)
  if nlines gt 0 then begin
    lines=replicate(emissionlinestructure, nlines)
    openr, lun1, input_filename, /GET_LUN
    for i=0, nlines-1 do begin
      Ion=""
      Multiplet=""
      LowerTerm=""
      UpperTerm=""
      g1=""
      g2=""
      readf,lun1, wavelength, peak, sigma1, flux, continuum, uncertainty, $
        redshift, resolution, blended, Ion, Multiplet, $
        LowerTerm, UpperTerm, g1, g2, $
        format='(F-13.4,E-15.7,E-15.7,E-15.7,E-15.7,E-15.7,F-17.10,F-17.2,I-4,A-19,A-15,A-19,A-19,A-4,A-3)'     
        lines[i].wavelength=wavelength
        lines[i].peak=peak
        lines[i].sigma1=sigma1
        lines[i].flux=flux 
        lines[i].continuum=continuum
        lines[i].uncertainty=uncertainty
        lines[i].redshift=redshift
        lines[i].resolution=resolution
        lines[i].blended=blended
        lines[i].Ion=strtrim(Ion,2)
        lines[i].Multiplet=strtrim(Multiplet,2)
        lines[i].LowerTerm=strtrim(LowerTerm ,2)
        lines[i].UpperTerm=strtrim(UpperTerm,2)
        lines[i].g1=strtrim(g1,2)
        lines[i].g2=strtrim(g2,2)
    endfor
    free_lun, lun1
  endif else begin
    lines = 0
  endelse
  return, lines
end

