; docformat = 'rst'

function read_deeplines, fits_file, EXTEN_NO=EXTEN_NO
;+
;     This function reads the list of deep lines 
;     from the 3rd binary table extension
;     of the FITS data file (../data/linedata.fits). 
;     This function uses the routine ftab_ext from 
;     IDL Astronomy User's library. 
;  
; :Returns:
;     type=arrays of structures. This function returns the deep line list
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
;     IDL> deepline_data = read_deeplines(fits_file)
;     IDL> print, deepline_data.Wavelength, deepline_data.Ion
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
;     
;     16/06/2017, A. Danehkar, A few changes.
;- 
  line_template={Wavelength:double(0.0), Ion:'', Multiplet:'', LowerTerm:'', UpperTerm:'', g1:'', g2:''}
  
  if keyword_set(EXTEN_NO) eq 1 then begin
    ftab_ext,fits_file,[1,2,3,4,5,6,7],Wavelength,Ion,Multiplet,LowerTerm,UpperTerm,g1,g2,EXTEN_NO =EXTEN_NO
  endif else begin
    ftab_ext,fits_file,[1,2,3,4,5,6,7],Wavelength,Ion,Multiplet,LowerTerm,UpperTerm,g1,g2,EXTEN_NO =3
  endelse
  temp=size(Wavelength,/DIMENSIONS)
  speclength=temp[0]
  
  deepline_data=replicate(line_template, speclength)
  for i=0, speclength-1 do begin 
     deepline_data[i].Wavelength=Wavelength[i]
     deepline_data[i].Ion=strtrim(Ion[i])
     deepline_data[i].Multiplet=strtrim(Multiplet[i])
     deepline_data[i].LowerTerm=strtrim(LowerTerm[i])
     deepline_data[i].UpperTerm=strtrim(UpperTerm[i])
     deepline_data[i].g1=strtrim(g1[i])
     deepline_data[i].g2=strtrim(g2[i])
  endfor
  return, deepline_data
end
