; Example: mgfit::detect_lines()
;     it multiple Gaussian functions to a list of emission 
;     lines using a least-squares minimization technique and 
;     a random walk method.
;
; Example of object-oriented programming (OOP) for
;     MGFIT object
; 
; --- Begin $MAIN$ program. ---------------
; 
; 

pro read1dspecascii, specfile, wavel, flux
  rownumber=long(0)
  rownumber= file_lines(specfile)  
  wavel=dblarr(rownumber)
  flux=dblarr(rownumber)
  b0=double(0.0)
  b1=double(0.0)
  openr, lun, specfile, /GET_LUN
  i=long(0)
  while(i lt rownumber) do begin
    readf,lun, b0, b1
    wavel[i] = b0
    flux[i] = b1 
    i = i + 1
  endwhile
  free_lun, lun 
end

; Example: mgfit_detect_lines()
;     This function detects lines using 
;     the string and deep line lists.
;
; --- Begin $MAIN$ program. ---------------
; 
; 
mg=obj_new('mgfit')

base_dir = file_dirname(file_dirname((routine_info('$MAIN$', /source)).path))
input_dir = ['examples','example2','inputs']
output_dir = ['examples','example2','outputs']
image_dir = ['examples','example2','images']
input_file = filepath('spec.txt', root_dir=base_dir, subdir=input_dir )
image_output_path = filepath('', root_dir=base_dir, subdir=image_dir )
output_path = filepath('', root_dir=base_dir, subdir=output_dir )

mg->set_output_path, output_path
mg->set_image_output_path, image_output_path

; genetic algorithm settings
popsize=30.
pressure=0.3
generations=500.
; fitting interval setting
;interval_wavelength=500
interval_wavelength=2000
; redshift initial and tolerance
redshift_initial = 1.0
redshift_tolerance=0.001
; initial FWHM and tolerance
fwhm_initial=1.0
fwhm_tolerance=0.8;*fwhm_initial
fwhm_min=0.1
fwhm_max=1.8

read1dspecascii, input_file, wavel, flux

emissionlines = mg->detect_lines(wavel, flux, $
                                 popsize=popsize, pressure=pressure, $
                                 generations=generations, $
                                 interval_wavelength=interval_wavelength, $
                                 redshift_initial=redshift_initial, $
                                 redshift_tolerance=redshift_tolerance, $
                                 fwhm_initial=fwhm_initial, $
                                 fwhm_tolerance=fwhm_tolerance, $
                                 fwhm_min=fwhm_min, fwhm_max=fwhm_max, /auto_line_array_size)

end
