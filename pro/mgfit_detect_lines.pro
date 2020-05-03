; docformat = 'rst'

function mgfit_detect_lines, wavelength, flux, deepline_data, strongline_data, $
                            popsize=popsize, pressure=pressure, $
                            generations=generations, $
                            interval_wavelength=interval_wavelength, $
                            redshift_initial=redshift_initial, $
                            redshift_tolerance=redshift_tolerance, $
                            resolution_initial=resolution_initial, $
                            resolution_tolerance=resolution_tolerance, $
                            resolution_min=resolution_min, resolution_max=resolution_max, $
                            auto_line_array_size=auto_line_array_size, $
                            image_output_path=image_output_path, $
                            output_path=output_path
;+
;     This function detects lines using the string and deep line lists.
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
;     redshift_tolerance   :    in, optional, type=float
;                               the redshift tolerance in the emission line fitting
;
;     resolution_initial   :    in, optional, type=float
;                               the initial spectral resolution in the first iteration
;
;     resolution_tolerance   :  in, optional, type=float
;                               the resolution tolerance rin the emission line fitting
;
;     resolution_min       :    in, optional, type=float
;                               the lower tolerant limit of the resolution in the emission line fitting
;
;     resolution_max       :    in, optional, type=float
;                               the upper tolerant limit of the resolution in the emission line fitting
;
;     auto_line_array_size :    in, not required, type=boolean
;                               automatically determine the line array size for the internal usage
;
;     image_output_path    :    in, optional, type=string
;                               the image output path
;
;     output_path          :    in, optional, type=string
;                               the text file output path
;
; :Examples:
;    For example::
;
;     IDL> emissionlines = mgfit_detect_lines(wavelength, flux, deepline_data, $
;                                              strongline_data)
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
;-
  spectrumstructure={wavelength: 0.0, flux:0.0, residual:0.0}
  if keyword_set(wavelength) eq 0 then begin
    print,'wavelength is not set'
    return, 0
  endif
  if keyword_set(flux) eq 0 then begin
    print,'flux is not set'
    return, 0
  endif
  if keyword_set(deepline_data) eq 0 then begin
    print,'deepline_data is not set'
    return, 0
  endif
  if keyword_set(strongline_data) eq 0 then begin
    print,'strongline_data is not set'
    return, 0
  endif
  ;  if keyword_set(image_output_path) eq 0 then begin
  ;    print,'image_output_path is not set'
  ;    return, 0
  ;  endif
  if keyword_set(popsize) eq 0 then begin
    popsize=30.
  endif
  if keyword_set(pressure) eq 0 then begin
    pressure=0.3
  endif
  if keyword_set(generations) eq 0 then begin
    generations=500.
  endif
  if keyword_set(redshift_initial) eq 0 then begin
    redshift_initial = 1.0
  endif
  if keyword_set(interval_wavelength) eq 0 then begin
    interval_wavelength = 500
  endif
  if keyword_set(redshift_tolerance) eq 0 then begin
    redshift_tolerance = 0.001
  endif
  if keyword_set(resolution_tolerance) eq 0 then begin
    resolution_tolerance = 0.02*resolution_initial
  endif
  if keyword_set(resolution_min) eq 0 then begin
    resolution_min = 6000.0
  endif
  if keyword_set(resolution_max) eq 0 then begin
    resolution_max = 30000.0
  endif
  strong_emissionlines = mgfit_detect_strong_lines(wavelength, flux, strongline_data, $
                                                  popsize=popsize, pressure=pressure, $
                                                  generations=generations, $
                                                  interval_wavelength=interval_wavelength, $
                                                  redshift_initial=redshift_initial, $
                                                  redshift_tolerance=redshift_tolerance, $
                                                  resolution_initial=resolution_initial, $
                                                  resolution_tolerance=resolution_tolerance, $
                                                  resolution_min=resolution_min, resolution_max=resolution_max)

  stron_line_save_file=output_path+'save_strong_line_list.txt'
  mgfit_write_lines, strong_emissionlines, stron_line_save_file
  ;strong_emissionlines1=mgfit_read_lines(stron_line_save_file)
  ;stron_line_save_file=output_path+'strong_line_list1.txt'
  ;mgfit_write_lines, strong_emissionlines1, stron_line_save_file

  temp=size(wavelength,/DIMENSIONS)
  speclength=temp[0]
  spectrumdata=mgfit_init_spec(wavelength, flux)
  
  syntheticspec=replicate(spectrumstructure, speclength)
  syntheticspec[*].wavelength=spectrumdata.wavelength
  syntheticspec[*].flux=0.0
  syntheticspec=mgfit_synth_spec(strong_emissionlines, syntheticspec)
  plot, spectrumdata.wavelength, spectrumdata.flux, color=cgColor('white');, XRANGE =[4840, 5040]
  oplot, syntheticspec.wavelength, syntheticspec.flux, color=cgColor('red')
  ;print, strong_emissionlines.flux
  ;print, strong_emissionlines.redshift

  strong_line=min(where(strong_emissionlines.flux eq max(strong_emissionlines.flux)))
  redshift_initial_overall = strong_emissionlines[strong_line].redshift
  redshift_initial=strong_emissionlines[strong_line].redshift
  redshift_strongline=redshift_initial
  resolution_initial=strong_emissionlines[strong_line].resolution
  resolution_strongline=resolution_initial
  ;resolution_tolerance1=0.02*resolution_initial;0.001*resolution_initial;0.02*resolution_initial;0.02*
  resolution_tolerance2=0.02*resolution_initial;0.001*resolution_initial;0.0001*resolution_initial;0.01*resolution_initial;0.01*500;500.
  emissionlines = mgfit_detect_deep_lines(wavelength, flux, deepline_data, $
                                          strong_emissionlines, strongline_data, $
                                          popsize=popsize, pressure=pressure, $
                                          generations=generations, $
                                          interval_wavelength=interval_wavelength, $
                                          redshift_initial=redshift_initial, $
                                          redshift_strongline=redshift_strongline, $
                                          redshift_tolerance=redshift_tolerance2, $
                                          resolution_initial=resolution_initial, $
                                          resolution_strongline=resolution_strongline, $
                                          resolution_tolerance=resolution_tolerance2, $
                                          resolution_min=resolution_min, resolution_max=resolution_max, $
                                          image_output_path=image_output_path)

  ; detect the strong lines
  ;emissionlines=mgfit_init_fltr_emis(deepline_data, wavel_min, wavel_max, redshift_initial)
  ;temp=size(emissionlines,/DIMENSIONS)
  ;nlines=temp[0]

  line_save_file=output_path+'save_line_list.txt'
  mgfit_write_lines, emissionlines, line_save_file

  ;strong_emissionlines1=mgfit_read_lines(stron_line_save_file)
  ;stron_line_save_file=output_path+'strong_line_list1.txt'
  ;mgfit_write_lines, strong_emissionlines1, stron_line_save_file

  syntheticspec=replicate(spectrumstructure, speclength)
  syntheticspec[*].wavelength=spectrumdata.wavelength
  syntheticspec[*].flux=0.0
  syntheticspec=mgfit_synth_spec(emissionlines, syntheticspec)
  set_plot, 'x'
  plot, spectrumdata.wavelength, spectrumdata.flux, color=cgColor('white');, XRANGE =[4840, 5040]
  oplot, syntheticspec.wavelength, syntheticspec.flux, color=cgColor('red')
  
  return, emissionlines
end

