; docformat = 'rst'

function mgfit_init_spec, wavel, flux
;+
;     This function creates the spectrum from the wavelength 
;     array and flux array. 
; 
; :Returns:
;     type=arrays of structures. This function returns the spectrum
;                               in the arrays of structures 
;                               {wavelength: 0.0, flux:0.0, residual:0.0}
;
; :Params:
;     wavel  :      in, required, type=arrays
;                   the wavelength array
;            
;     flux   :      in, required, type=arrays
;                   the flux array
;
;
; :Examples:
;    For example::
;
;     IDL> spectrumdata=mgfit_init_spec(wavel, flux)
;
; :Categories:
;   Spectrum, Initialization
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
  spectrumstructure={wavelength: 0.0, flux:0.0, residual:0.0}
   
  temp=size(wavel,/DIMENSIONS)
  speclength=temp[0]
   
  spectrumdata=replicate(spectrumstructure, speclength)
  for i=0L, speclength-1 do begin 
    spectrumdata[i].wavelength = wavel[i]
    spectrumdata[i].flux = flux[i] 
    spectrumdata[i].residual = 0.0
  endfor
  return, spectrumdata
end
