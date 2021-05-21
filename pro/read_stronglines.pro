; docformat = 'rst'

function read_stronglines, fits_file
;+
;     This function reads the list of strong lines 
;     from the 1rd binary table extension
;     of the FITS data file (../data/linedata.fits). 
;     This function uses the routine ftab_ext from 
;     IDL Astronomy User's library. 
;  
; :Returns:
;     type=arrays of structures. This function returns the strong line list
;                               in the arrays of structures 
;                               { Wavelength:0.0, 
;                                 Ion:'', 
;                                 Multiplet:'', 
;                                 LowerTerm:'', 
;                                 UpperTerm:'', 
;                                 g1:'', 
;                                 g2:''}
;
; :Params:          
;     fits_file  :      in, required, type=string
;                       the FITS file name ("../data/linedata.fits")
;  
; :Examples:
;    For example::
;
;     IDL> strongline_data = read_stronglines(fits_file)
;     IDL> print, strongline_data.Wavelength, strongline_data.Ion
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
  line_template={Wavelength:double(0.0), Ion:'', Multiplet:'', LowerTerm:'', UpperTerm:'', g1:'', g2:''}
  
  ftab_ext,fits_file,[1,2,3,4,5,6,7],Wavelength,Ion,Multiplet,LowerTerm,UpperTerm,g1,g2,EXTEN_NO =1
  temp=size(Wavelength,/DIMENSIONS)
  speclength=temp[0]
  
  strongline_data=replicate(line_template, speclength)
  for i=0, speclength-1 do begin 
     strongline_data[i].Wavelength=Wavelength[i]
     strongline_data[i].Ion=strtrim(Ion[i])
     strongline_data[i].Multiplet=strtrim(Multiplet[i])
     strongline_data[i].LowerTerm=strtrim(LowerTerm[i])
     strongline_data[i].UpperTerm=strtrim(UpperTerm[i])
     strongline_data[i].g1=strtrim(g1[i])
     strongline_data[i].g2=strtrim(g2[i])
  endfor
  return, strongline_data
end
