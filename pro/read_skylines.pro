function read_skylines, fits_file
;+
; NAME:
;     read_deeplines
; PURPOSE:
;     read the list of sky lines from the 5th binary table extension
;     of the FITS data file (../data/linedata.fits)
; EXPLANATION:
;
; CALLING SEQUENCE:
;     skyline_data = read_skylines(fits_file)
;     print, skyline_data.Wavelength
;
; INPUTS:
;     fits_file - the MGFIT line data (../data/linedata.fits)
; RETURN:  skyline_data
;          { Wavelength:0.0}
;
; REQUIRED EXTERNAL LIBRARY:
;     ftab_ext from IDL Astronomy User's library (../externals/astron/pro)
;
; REVISION HISTORY:
;     IDL code by A. Danehkar, 20/07/2014
;- 
  sky_template={Wavelength: 0.0}
  
  ftab_ext,fits_file,[1],Wavelength,EXTEN_NO =5
  temp=size(Wavelength,/DIMENSIONS)
  speclength=temp[0]
  
  skyline_data=replicate(sky_template, speclength)
  for i=0, speclength-1 do begin 
     skyline_data[i].Wavelength=Wavelength[i]
  endfor
  return, skyline_data
end
