function read_ultradeeplines, fits_file
;+
; NAME:
;     read_deeplines
; PURPOSE:
;     read the list of ultra deep lines from the 4th binary table extension
;     of the FITS data file (../data/linedata.fits)
; EXPLANATION:
;
; CALLING SEQUENCE:
;     ultradeepline_data = read_ultradeeplines(fits_file)
;     print, ultradeepline_data.Wavelength, ultradeepline_data.Ion
;
; INPUTS:
;     fits_file - the MGFIT line data (../data/linedata.fits)
; RETURN:  ultradeepline_data
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
