; docformat = 'rst'

function read_skylines, fits_file
;+
;     This function reads the list of sky lines 
;     from the 3rd binary table extension
;     of the FITS data file (../data/linedata.fits). 
;     This function uses the routine ftab_ext from 
;     IDL Astronomy User's library. 
;  
; :Returns:
;     type=arrays of structures. This function returns the sky line list
;                               in the arrays of structures 
;                               { Wavelength:0.0}
;
; :Params:          
;     fits_file  :      in, required, type=string
;                       the FITS file name ("../data/linedata.fits")
;  
; :Examples:
;    For example::
;
;     IDL> skyline_data = read_skylines(fits_file)
;     IDL> print, skyline_data.Wavelength
;
; :Categories:
;   Lines
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
;- 
  sky_template={Wavelength:double(0.0)}
  
  ftab_ext,fits_file,[1],Wavelength,EXTEN_NO =5
  temp=size(Wavelength,/DIMENSIONS)
  speclength=temp[0]
  
  skyline_data=replicate(sky_template, speclength)
  for i=0, speclength-1 do begin 
     skyline_data[i].Wavelength=Wavelength[i]
  endfor
  return, skyline_data
end
