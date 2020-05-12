; docformat = 'rst'

;+
;     "Unit for Least-Squares Minimization Genetic Algorithm Fitting (MGFIT)": 
;     This obejct library can be used
;     to fit multiple Gaussian functions to a list of emission 
;     lines using a least-squares minimization technique and 
;     a random walk method in three-dimensional locations of 
;     the specified lines, namely line peak, line width, and 
;     wavelength shift.
;
; :Examples:
;    For example::
;
;     IDL> mg=obj_new('mgfit')
;     IDL> mg->set_output_path, output_path
;     IDL> mg->set_image_output_path, image_output_path
;     IDL> emissionlines = mg->detect_lines(wavel, flux)
;          
;
; :Categories:
;   Spectrum
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
;   0.2.0
;
; :History:
;
;     12/05/2020, A. Danehkar, Create object-oriented programming (OOP).
;-
function mgfit::init
  self.data_dir = 'data'
  self.base_dir = file_dirname(file_dirname((routine_info('mgfit__define', /source)).path))
  fits_file = filepath('linedata.fits', root_dir=self.base_dir, subdir=self.data_dir )
  self.fits_file=fits_file
  strongline_data=read_stronglines(Fits_file)
  deepline_data=read_deeplines(fits_file)
  self.strongline_data=ptr_new(strongline_data)
  self.deepline_data=ptr_new(deepline_data)
  self.image_output_path= file_dirname(file_dirname((routine_info('$MAIN$', /source)).path))
  self.output_path= file_dirname(file_dirname((routine_info('$MAIN$', /source)).path))
  self.popsize=30.
  self.pressure=0.3
  self.generations=500.
  self.interval_wavelength = 500
  self.redshift_initial = 1.0
  self.redshift_tolerance = 0.001
  self.fwhm_initial = 1.0
  self.fwhm_tolerance = 1.4
  self.fwhm_min = 0.1
  self.fwhm_max = 1.0
  return,1
end

function mgfit::free
  ptr_free, self.strongline_data
  strongline_data=ptr_new(/ALLOCATE_HEAP)
  ptr_free, self.deepline_data
  deepline_data=ptr_new(/ALLOCATE_HEAP)
  return,1
end

function mgfit::detect_lines, wavelength, flux, $
                              popsize=popsize, pressure=pressure, $
                              generations=generations, $
                              rebin_resolution=rebin_resolution, $
                              interval_wavelength=interval_wavelength, $
                              redshift_initial=redshift_initial, $
                              redshift_tolerance=redshift_tolerance, $
                              fwhm_initial=fwhm_initial, $
                              fwhm_tolerance=fwhm_tolerance, $
                              fwhm_min=fwhm_min, fwhm_max=fwhm_max, $
                              auto_line_array_size=auto_line_array_size, $
                              image_output_path=image_output_path, $
                              output_path=output_path, $
                              no_mpfit=no_mpfit, no_blueshift=no_blueshift
;+
;     This function detects lines from the deep line list.
;
; :Returns:
;    type=arrays of structures. This function returns the arrays of structures
;                              { wavelength: 0.0, peak:0.0, sigma1:0.0, flux:0.0,
;                                uncertainty:0.0, redshift:0.0, resolution:0.0,
;                                blended:0, Ion:'', Multiplet:'',
;                                LowerTerm:'', UpperTerm:'', g1:'', g2:''}
;
; :Params:
;     wavelength:        in, required, type=arrays
;                        the arrays of wavelength
;
;     flux:              in, required, type=arrays
;                        the arrays of flux
;
;     deepline_data:     in, required, type=arrays of structures
;                        the strong line list
;                        in the arrays of structures
;                        { Wavelength:0.0,
;                          Ion:'',
;                          Multiplet:'',
;                          LowerTerm:'',
;                          UpperTerm:'',
;                          g1:'',
;                          g2:''}
;
;     strong_emissionlines:   in, required, type=arrays of structures
;                        the detected emission lines from the strong line list
;                        in the arrays of structures
;                              { wavelength: 0.0, peak:0.0, sigma1:0.0, flux:0.0,
;                                uncertainty:0.0, redshift:0.0, resolution:0.0,
;                                blended:0, Ion:'', Multiplet:'',
;                                LowerTerm:'', UpperTerm:'', g1:'', g2:''}
;
;
;     strongline_data:   in, required, type=arrays of structures
;                        the strong line list
;                        in the arrays of structures
;                        { Wavelength:0.0,
;                          Ion:'',
;                          Multiplet:'',
;                          LowerTerm:'',
;                          UpperTerm:'',
;                          g1:'',
;                          g2:''}
;
; :Keywords:
;
;     popsize              :    in, optional, type=float
;                               the population size in each generation in the genetic algorithm
;
;     pressure             :    in, optional, type=float
;                               the value of the selective pressure in the genetic algorithm
;
;     generations          :    in, optional, type=float
;                               the maximum generation number in the genetic algorithm
;
;     interval_wavelength  :    in, optional, type=float
;                               the wavelength interval used in each iteration
;
;     redshift_initial     :    in, optional, type=float
;                               the initial redshift in the first iteration
;
;     redshift_strongline  :   in, optional, type=float
;                               the redshift derived in the strong line list
;
;     redshift_tolerance   :    in, optional, type=float
;                               the redshift tolerance in the emission line fitting
;
;     fwhm_initial         :    in, optional, type=float
;                               the initial FWHM in the first iteration
;
;     fwhm_strongline :    in, optional, type=float
;                               the resolution derived in the strong line list
;
;     fwhm_tolerance       :    in, optional, type=float
;                               the FWHM tolerance rin the emission line fitting
;
;     fwhm_min             :    in, optional, type=float
;                               the lower FWHM limit of the resolution in the emission line fitting
;
;     fwhm_max             :    in, optional, type=float
;                               the upper FWHM limit of the resolution in the emission line fitting
;
;     auto_line_array_size  :    in, not required, type=boolean
;                                automatically determine the line array size for the internal usage
;
;     image_output_path     :    in, optional, type=string
;                                the image output path
;
;     printgenerations      :    in, optional, type=string
;                                Set to produce plots in all generations
;
;     no_mpfit              :     in, required, type=boolean
;                                 Do not use MPFIT to initialize the seed
;
;     no_blueshift          :     in, required, type=boolean
;                                 Forbid the blueshift
;
; :Examples:
;    For example::
;
;     IDL> emissionlines = mgfit::detect_lines(wavelength, flux)
;
; :Categories:
;   Spectrum
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
;     02/05/2020, A. Danehkar, Create function.
;     
;     12/05/2020, A. Danehkar, Move to object-oriented programming (OOP).
;-
  if keyword_set(popsize) eq 1 then begin
    self.popsize=popsize
  endif
  if keyword_set(pressure) eq 1 then begin
    self.pressure=pressure
  endif
  if keyword_set(generations) eq 1 then begin
    self.generations=generations
  endif
  if keyword_set(interval_wavelength) eq 1 then begin
    self.interval_wavelength = interval_wavelength
  endif
  if keyword_set(redshift_initial) eq 1 then begin
    self.redshift_initial = redshift_initial
  endif
  if keyword_set(redshift_tolerance) eq 1 then begin
    self.redshift_tolerance = redshift_tolerance
  endif
  if keyword_set(fwhm_initial) eq 1 then begin
    self.fwhm_initial = fwhm_initial
  endif
  if keyword_set(fwhm_tolerance) eq 1 then begin
    self.fwhm_tolerance = fwhm_tolerance
  endif
  if keyword_set(fwhm_min) eq 1 then begin
    self.fwhm_min = fwhm_min
  endif
  if keyword_set(fwhm_max) eq 1 then begin
    self.fwhm_max = fwhm_max
  endif
  if keyword_set(output_path) eq 1 then begin
    self.output_path = output_path
  endif
  if keyword_set(image_output_path) eq 1 then begin
    self.image_output_path = image_output_path
  endif
  deepline_data=*(self.deepline_data)
  strongline_data=*(self.strongline_data)
  value=mgfit_detect_lines(wavelength, flux, deepline_data, strongline_data, $
                           popsize=self.popsize, pressure=self.pressure, $
                           generations=self.generations, $
                           rebin_resolution=rebin_resolution, $
                           interval_wavelength=self.interval_wavelength, $
                           redshift_initial=self.redshift_initial, $
                           redshift_tolerance=self.redshift_tolerance, $
                           fwhm_initial=self.fwhm_initial, $
                           fwhm_tolerance=self.fwhm_tolerance, $
                           fwhm_min=self.fwhm_min, fwhm_max=self.fwhm_max, $
                           auto_line_array_size=auto_line_array_size, $
                           image_output_path=self.image_output_path, $
                           output_path=self.output_path, $
                           no_mpfit=no_mpfit, no_blueshift=no_blueshift)
  return, value                        
end     
;-------------
pro mgfit::set_popsize, popsize
  if popsize ne '' then self.popsize=popsize else print, 'Error: popsize is not given'
  return
end

function mgfit::get_popsize
  if self.popsize ne '' then popsize=self.popsize else print, 'Error: popsize is not given'
  return, popsize
end
;-------------
pro mgfit::set_pressure, pressure
  if pressure ne '' then self.pressure=pressure else print, 'Error: pressure is not given'
  return
end

function mgfit::get_pressure
  if self.pressure ne '' then pressure=self.pressure else print, 'Error: pressure is not given'
  return, pressure
end
;-------------
pro mgfit::set_generations, generations
  if generations ne '' then self.generations=generations else print, 'Error: generations is not given'
  return
end

function mgfit::get_generations
  if self.generations ne '' then generations=self.generations else print, 'Error: generations is not given'
  return, generations
end
;-------------
pro mgfit::set_interval_wavelength, interval_wavelength
  if interval_wavelength ne '' then self.interval_wavelength=interval_wavelength else print, 'Error: interval_wavelength is not given'
  return
end

function mgfit::get_interval_wavelength
  if self.interval_wavelength ne '' then interval_wavelength=self.interval_wavelength else print, 'Error: interval_wavelength is not given'
  return, interval_wavelength
end
;-------------
pro mgfit::set_redshift_initial, redshift_initial
  if redshift_initial ne '' then self.redshift_initial=redshift_initial else print, 'Error: redshift_initial is not given'
  return
end

function mgfit::get_redshift_initial
  if self.redshift_initial ne '' then redshift_initial=self.redshift_initial else print, 'Error: redshift_initial is not given'
  return, redshift_initial
end
;-------------
pro mgfit::set_redshift_tolerance, redshift_tolerance
  if redshift_tolerance ne '' then self.redshift_tolerance=redshift_tolerance else print, 'Error: redshift_tolerance is not given'
  return
end

function mgfit::get_redshift_tolerance
  if self.redshift_tolerance ne '' then redshift_tolerance=self.redshift_tolerance else print, 'Error: redshift_tolerance is not given'
  return, redshift_tolerance
end
;-------------
pro mgfit::set_fwhm_initial, fwhm_initial
  if fwhm_initial ne '' then self.fwhm_initial=fwhm_initial else print, 'Error: fwhm_initial is not given'
  return
end

function mgfit::get_fwhm_initial
  if self.fwhm_initial ne '' then fwhm_initial=self.fwhm_initial else print, 'Error: fwhm_initial is not given'
  return, fwhm_initial
end
;-------------
pro mgfit::set_fwhm_tolerance, fwhm_tolerance
  if fwhm_tolerance ne '' then self.fwhm_tolerance=fwhm_tolerance else print, 'Error: fwhm_tolerance is not given'
  return
end

function mgfit::get_fwhm_tolerance
  if self.fwhm_tolerance ne '' then fwhm_tolerance=self.fwhm_tolerance else print, 'Error: fwhm_tolerance is not given'
  return, fwhm_tolerance
end
;-------------
pro mgfit::set_fwhm_min, fwhm_min
  if fwhm_min ne '' then self.fwhm_min=fwhm_min else print, 'Error: fwhm_min is not given'
  return
end

function mgfit::get_fwhm_min
  if self.fwhm_min ne '' then fwhm_min=self.fwhm_min else print, 'Error: fwhm_min is not given'
  return, fwhm_min
end
;-------------
pro mgfit::set_fwhm_max, fwhm_max
  if fwhm_max ne '' then self.fwhm_max=fwhm_max else print, 'Error: fwhm_max is not given'
  return
end

function mgfit::get_fwhm_max
  if self.fwhm_max ne '' then fwhm_max=self.fwhm_max else print, 'Error: fwhm_max is not given'
  return, fwhm_max
end
;-------------
pro mgfit::set_data_dir, data_dir
  if data_dir ne '' then self.data_dir=data_dir else print, 'Error: data_dir is not given'
  return
end

function mgfit::get_data_dir
  if self.data_dir ne '' then data_dir=self.data_dir else print, 'Error: data_dir is not given'
  return, data_dir
end
;-------------
pro mgfit::set_base_dir, base_dir
  if base_dir ne '' then self.base_dir=base_dir else print, 'Error: base_dir is not given'
  return
end

function mgfit::get_base_dir
  if self.base_dir ne '' then base_dir=self.base_dir else print, 'Error: base_dir is not given'
  return, base_dir
end
;-------------
pro mgfit::set_output_path, output_path
  if output_path ne '' then self.output_path=output_path else print, 'Error: output_path is not given'
  return
end

function mgfit::get_output_path
  if self.output_path ne '' then output_path=self.output_path else print, 'Error: output_path is not given'
  return, output_path
end
;-------------
pro mgfit::set_image_output_path, image_output_path
  if image_output_path ne '' then self.image_output_path=image_output_path else print, 'Error: image_output_path is not given'
  return
end

function mgfit::get_image_output_path
  if self.image_output_path ne '' then image_output_path=self.image_output_path else print, 'Error: image_output_path is not given'
  return, image_output_path
end
;-------------
pro mgfit::set_fits_file, fits_file
  if fits_file ne '' then self.fits_file=fits_file else print, 'Error: fits_file is not given'
  return
end

function mgfit::get_fits_file
  if self.fits_file ne '' then fits_file=self.fits_file else print, 'Error: fits_file is not given'
  return, fits_file
end
;------------------------------------------------------------------
pro mgfit__define
  void={mgfit, data_dir:'', base_dir:'', fits_file:'', $
          popsize:30., pressure:0.3, generations:5000.0, $
          interval_wavelength:500, $
          redshift_initial:1.0, redshift_tolerance:0.001, $
          fwhm_initial: 1.0, fwhm_tolerance:1.4, fwhm_min: 0.1, fwhm_max:1.0, $
          image_output_path:'', output_path:'', $
          strongline_data:ptr_new(/ALLOCATE_HEAP), deepline_data:ptr_new(/ALLOCATE_HEAP)}
  return 
end
