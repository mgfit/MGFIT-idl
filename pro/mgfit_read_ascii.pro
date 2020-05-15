; docformat = 'rst'

pro mgfit_read_ascii, filename, wavel, flux
;+
;     This function read ascii file spectrum.
; 
; :Params:
;     filename:     in, required, type=string
;                   the file name for writing the lines.
;
;     wavel  :      in, required, type=arrays
;                   the wavelength array
;            
;     flux   :      in, required, type=arrays
;                   the flux array
;
; :Examples:
;    For example::
;
;     IDL> mgfit_read_ascii, filename, wavel, flux
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
;     14/05/2020, A. Danehkar, Create function.
;-
  rownumber=long(0)
  rownumber= file_lines(filename)  
  wavel=dblarr(rownumber)
  flux=dblarr(rownumber)
  b0=double(0.0)
  b1=double(0.0)
  openr, lun, filename, /GET_LUN
  i=long(0)
  while(i lt rownumber) do begin
    readf,lun, b0, b1
    wavel[i] = b0
    flux[i] = b1 
    i = i + 1
  endwhile
  free_lun, lun 
end

