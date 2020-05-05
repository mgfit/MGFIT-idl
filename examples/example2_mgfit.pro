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

base_dir = file_dirname(file_dirname((routine_info('$MAIN$', /source)).path))
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
; spectral resolution initial and tolerance
resolution_initial=12000
resolution_tolerance=0.02*resolution_initial
resolution_min=6000.0
resolution_max=30000.0

read1dspecascii, input_file, wavel, flux

emissionlines = mgfit_detect_lines(wavel, flux, deepline_data, strongline_data, $
                                   popsize=popsize, pressure=pressure, $
                                   generations=generations, $
                                   interval_wavelength=interval_wavelength, $
                                   redshift_initial=redshift_initial, $
                                   redshift_tolerance=redshift_tolerance, $
                                   resolution_initial=resolution_initial, $
                                   resolution_tolerance=resolution_tolerance, $
                                   resolution_min=resolution_min, resolution_max=resolution_max, $
                                   image_output_path=image_output_path, output_path=output_path, /auto_line_array_size)

end
