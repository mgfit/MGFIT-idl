; Example: mgfit_detect_lines()
;     This function detects lines using 
;     the string and deep line lists.
;
; --- Begin $MAIN$ program. ---------------
; 
; 

base_dir = '../'
data_dir = ['data']
input_dir = ['examples','example2','inputs']
output_dir = ['examples','example2','outputs']
image_dir = ['examples','example2','images']

fits_file = filepath('linedata.fits', root_dir=base_dir, subdir=data_dir )
input_file = filepath('spec.txt', root_dir=base_dir, subdir=input_dir )
image_output_path = filepath('', root_dir=base_dir, subdir=image_dir )
output_path = filepath('', root_dir=base_dir, subdir=output_dir )

; read emission line list
strongline_data=read_stronglines(fits_file)
deepline_data=read_deeplines(fits_file)
ultradeepline_data=read_ultradeeplines(fits_file)
skyline_data=read_skylines(fits_file)

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

mgfit_read_ascii, input_file, wavel, flux

emissionlines = mgfit_detect_lines(wavel, flux, deepline_data, strongline_data, $
                                   popsize=popsize, pressure=pressure, $
                                   generations=generations, $
                                   interval_wavelength=interval_wavelength, $
                                   redshift_initial=redshift_initial, $
                                   redshift_tolerance=redshift_tolerance, $
                                   fwhm_initial=fwhm_initial, $
                                   fwhm_tolerance=fwhm_tolerance, $
                                   fwhm_min=fwhm_min, fwhm_max=fwhm_max, $
                                   image_output_path=image_output_path, output_path=output_path, /auto_line_array_size)

output_filename=output_path+'line_list'
mgfit_save_lines, emissionlines, output_filename

exit
