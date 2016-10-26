function read_deeplines, fits_file
;+
; NAME:
;     read_deeplines
; PURPOSE:
;     read the list of deep lines from the 3rd binary table extension
;     of the FITS data file (../data/linedata.fits)
; EXPLANATION:
;
; CALLING SEQUENCE:
;     deepline_data = read_deeplines(fits_file)
;     print, deepline_data.Wavelength, deepline_data.Ion
;
; INPUTS:
;     fits_file - the MGFIT line data (../data/linedata.fits)
; RETURN:  deepline_data
;          { Wavelength:0.0, 
;            Ion:'', 
;            Multiplet:'', 
;            LowerTerm:'', 
;            UpperTerm:'', 
;            g1:'', 
;            g2:''}
;
; REQUIRED EXTERNAL LIBRARY:
;     ftab_ext from IDL Astronomy User's library (../externals/astron/pro)
;
; REVISION HISTORY:
;     IDL code by A. Danehkar, 20/07/2014
;- 
  line_template={Wavelength: 0.0, Ion:'', Multiplet:'', LowerTerm:'', UpperTerm:'', g1:'', g2:''}
  
  ftab_ext,fits_file,[1,2,3,4,5,6,7],Wavelength,Ion,Multiplet,LowerTerm,UpperTerm,g1,g2,EXTEN_NO =3
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
