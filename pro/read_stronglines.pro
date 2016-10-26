function read_stronglines, fits_file
;+
; NAME:
;     read_stronglines
; PURPOSE:
;     read the list of strong lines from the 1st binary table extension
;     of the FITS data file (../data/linedata.fits)
; EXPLANATION:
;
; CALLING SEQUENCE:
;     strongline_data = read_stronglines(fits_file)
;     print, strongline_data.Wavelength, strongline_data.Ion
;
; INPUTS:
;     fits_file - the MGFIT line data (../data/linedata.fits)
; RETURN:  strongline_data
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
