; docformat = 'rst'

function read_ultradeeplines, fits_file
;+
;     This function reads the list of ultra deep lines 
;     from the 4rd binary table extension
;     of the FITS data file (../data/linedata.fits). 
;     This function uses the routine ftab_ext from 
;     IDL Astronomy User's library. 
;  
; :Returns:
;     type=arrays of structures. This function returns the ultra deep line list
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
;     IDL> ultradeepline_data = read_ultradeeplines(fits_file)
;     IDL> print, ultradeepline_data.Wavelength, ultradeepline_data.Ion
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
  
  ftab_ext,fits_file,[1,2,3,4,5,6,7],Wavelength,Ion,Multiplet,LowerTerm,UpperTerm,g1,g2,EXTEN_NO =4
  temp=size(Wavelength,/DIMENSIONS)
  speclength=temp[0]
  
  ultradeepline_data=replicate(line_template, speclength)
  for i=0, speclength-1 do begin 
     ultradeepline_data[i].Wavelength=Wavelength[i]
     ultradeepline_data[i].Ion=strtrim(Ion[i])
     ultradeepline_data[i].Multiplet=strtrim(Multiplet[i])
     ultradeepline_data[i].LowerTerm=strtrim(LowerTerm[i])
     ultradeepline_data[i].UpperTerm=strtrim(UpperTerm[i])
     ultradeepline_data[i].g1=strtrim(g1[i])
     ultradeepline_data[i].g2=strtrim(g2[i])
  endfor
  return, ultradeepline_data
end
