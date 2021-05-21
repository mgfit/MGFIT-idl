; docformat = 'rst'

function mgfit_detect_lines, wavelength, flux, deepline_data, strongline_data, $
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
;     rebin_resolution     :    in, optional, type=float
;                               increase the spectrum resolution by rebinning 
;                               resolution by rebin_resolution times
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
;     fwhm_initial         :    in, optional, type=float
;                               the initial FWHM in the first iteration
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
;     auto_line_array_size :    in, not required, type=boolean
;                               automatically determine the line array size for the internal usage
;
;     image_output_path    :    in, optional, type=string
;                               the image output path
;
;     output_path          :    in, optional, type=string
;                               the text file output path
; 
; 
;     no_mpfit              :     in, required, type=boolean
;                                 Do not use MPFIT to initialize the seed
;
;     no_blueshift          :     in, required, type=boolean
;                                 Forbid the blueshift      
;                          
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
  spectrumstructure={wavelength: double(0.0), flux:double(0.0), residual:double(0.0)}
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
  if keyword_set(interval_wavelength) eq 0 then begin
    interval_wavelength = 20
  endif
  if keyword_set(redshift_initial) eq 0 then begin
    redshift_initial = 1.0
  endif
  if keyword_set(redshift_tolerance) eq 0 then begin
    redshift_tolerance = 0.001
  endif
  if keyword_set(fwhm_initial) eq 0 then begin
    fwhm_initial = 1.0
  endif
  if keyword_set(fwhm_tolerance) eq 0 then begin
    fwhm_tolerance = 0.5*fwhm_initial
  endif
  if keyword_set(fwhm_min) eq 0 then begin
    fwhm_min = 0.1
  endif
  if keyword_set(fwhm_max) eq 0 then begin
    fwhm_max = 1.0
  endif
  if keyword_set(rebin_resolution) eq 1 then begin
    temp=size(wavelength,/DIMENSIONS)
    speclength=temp[0]
    speclength_new=rebin_resolution*speclength
    wavelength_new = interpolate(wavelength, (double(speclength)-1.)/(double(speclength_new)-1.) * findgen(speclength_new))
    flux_new = interpolate(flux, (double(speclength)-1.)/(double(speclength_new)-1.) * findgen(speclength_new))
    wavelength=wavelength_new
    flux=flux_new
  endif
  check_strong_lines=1
  if check_strong_lines eq 1 then begin
    fwhm_tolerance_ratio=fwhm_tolerance/fwhm_initial
    strong_emissionlines = mgfit_detect_strong_lines(wavelength, flux, strongline_data, $
                                                    popsize=popsize, pressure=pressure, $
                                                    generations=generations, $
                                                    rebin_resolution=rebin_resolution, $
                                                    interval_wavelength=interval_wavelength, $
                                                    redshift_initial=redshift_initial, $
                                                    redshift_tolerance=redshift_tolerance, $
                                                    fwhm_initial=fwhm_initial, $
                                                    fwhm_tolerance=fwhm_tolerance, $
                                                    fwhm_min=fwhm_min, $
                                                    fwhm_max=fwhm_max, $
                                                    ;/printgenerations, $
                                                    no_blueshift=no_blueshift, no_mpfit=no_mpfit, $
                                                    /fit_continuum, $
                                                    image_output_path=image_output_path)
  
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
    fwhm_initial=2.355*strong_emissionlines[strong_line].sigma1
    fwhm_strongline=fwhm_initial
    ;fwhm_tolerance1=0.02*fwhm_initial;0.001*fwhm_initial;0.02*fwhm_initial;0.02*
    ;fwhm_tolerance2=0.02*fwhm_initial;0.001*fwhm_initial;0.0001*fwhm_initial;0.01*fwhm_initial;0.01*500;500.
    fwhm_tolerance2=fwhm_tolerance;*fwhm_initial
    loc1=where(strong_emissionlines.flux ne 0)
    fwhm_min2=2.355*min(strong_emissionlines[loc1].sigma1)*0.5
    fwhm_max2=2.355*max(strong_emissionlines[loc1].sigma1)*3.0
    fwhm_tolerance2=2.355*max(strong_emissionlines[loc1].sigma1)*1.4;-fwhm_min2
    
    redshift_min2=min(strong_emissionlines[loc1].redshift)
    redshift_max2=max(strong_emissionlines[loc1].redshift)
    redshift_tolerance2=redshift_max2-redshift_min2
    ;redshift_tolerance2=10.0*redshift_tolerance2
    redshift_tolerance2=redshift_tolerance
  endif else begin
    redshift_strongline=redshift_initial
    fwhm_strongline=fwhm_initial
    fwhm_tolerance2=fwhm_tolerance
    fwhm_min2=fwhm_min
    fwhm_max2=fwhm_max
    fwhm_tolerance2=fwhm_max2;-fwhm_min2
    redshift_tolerance2=redshift_tolerance
  endelse
  ;loc1=where(wavelength gt 4706.0 and wavelength lt 4744.0)
  ;wavelength=wavelength[loc1]
  ;flux=flux[loc1]
  emissionlines = mgfit_detect_deep_lines(wavelength, flux, deepline_data, $
                                          strong_emissionlines, strongline_data, $
                                          popsize=popsize, pressure=pressure, $
                                          generations=generations, $
                                          rebin_resolution=rebin_resolution, $
                                          interval_wavelength=interval_wavelength, $
                                          redshift_initial=redshift_initial, $
                                          redshift_strongline=redshift_strongline, $
                                          redshift_tolerance=redshift_tolerance2, $
                                          fwhm_initial=fwhm_initial, $
                                          fwhm_strongline=fwhm_strongline, $
                                          fwhm_tolerance=fwhm_tolerance2, $
                                          fwhm_min=fwhm_min2, fwhm_max=fwhm_max2, $
                                          ;/printgenerations, $
                                          auto_line_array_size=auto_line_array_size, $
                                          no_blueshift=no_blueshift, no_mpfit=no_mpfit, $
                                          /fit_continuum, $
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

