; docformat = 'rst'

function mgfit_detect_deep_lines, wavelength, flux, deepline_data, $
                                  strong_emissionlines, strongline_data, $
                                  popsize=popsize, pressure=pressure, $
                                  generations=generations, $
                                  interval_wavelength=interval_wavelength, $
                                  redshift_initial=redshift_initial, $
                                  redshift_strongline=redshift_strongline, $
                                  redshift_tolerance=redshift_tolerance, $
                                  resolution_initial=resolution_initial, $
                                  resolution_strongline=resolution_strongline, $
                                  resolution_tolerance=resolution_tolerance, $
                                  resolution_min=resolution_min, resolution_max=resolution_max, $
                                  auto_line_array_size=auto_line_array_size, $
                                  image_output_path=image_output_path, $
                                  printgenerations=printgenerations,no_mpfit=no_mpfit
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
;     resolution_initial   :    in, optional, type=float
;                               the initial spectral resolution in the first iteration
;
;     resolution_strongline :    in, optional, type=float
;                               the resolution derived in the strong line list
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
;     printgenerations :    in, optional, type=string
;                                Set to produce plots in all generations 
; 
;     no_mpfit           :     in, required, type=boolean
;                              Do not use MPFIT to initialize the seed
;   
; :Examples:
;    For example::
;
;     IDL> emissionlines = mgfit_detect_deep_lines(wavelength, flux, deepline_data, $
;                                                  strong_emissionlines, strongline_data)
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
  if keyword_set(strong_emissionlines) eq 0 then begin
    print,'strong_emissionlines is not set'
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
  if keyword_set(redshift_strongline) eq 0 then begin
    redshift_strongline = redshift_initial
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
  temp=size(wavelength,/DIMENSIONS)
  speclength=temp[0]
  wavelength_min=wavelength[0]
  wavelength_max=wavelength[speclength-1]

  spectrumdata=mgfit_init_spec(wavelength, flux)

  ; calculate resolution based on the nyquist sampling rate
  if keyword_set(resolution_initial) eq 0 then begin
    resolution_initial=2*spectrumdata[2].wavelength/(spectrumdata[3].wavelength-spectrumdata[1].wavelength)
  endif
  if keyword_set(resolution_strongline) eq 0 then begin
    resolution_strongline=resolution_initial
  endif

  ; detect the deep lines
  emissionlines=mgfit_init_fltr_emis(deepline_data, wavelength_min, wavelength_max, redshift_initial)

  temp=size(emissionlines,/DIMENSIONS)
  nlines=temp[0]

  linelocation0_step= max(where(spectrumdata.wavelength lt spectrumdata[0].wavelength+6.0))
  linelocation0_step= round(linelocation0_step/10.0)*10
  linelocation0_step_h=round(linelocation0_step/2)
  line_overlap_h=linelocation0_step_h
  
  linearraypos=0
  ;step1=2000
  step1=interval_wavelength;500
  step1=nint_idl(2*redshift_tolerance/(1.-spectrumdata[0].wavelength/spectrumdata[1].wavelength))
  line_overlap_h=0
  ;for i=0L,speclength-1,step1 do begin
  ;nimage=0
  iw =0
  overlap=nint_idl(redshift_tolerance/(1.-spectrumdata[iw].wavelength/spectrumdata[iw+1].wavelength))
  while (iw + long(overlap/4) lt speclength) do begin
    overlap=nint_idl(redshift_tolerance/(1.-spectrumdata[iw].wavelength/spectrumdata[iw+1].wavelength))
    if iw + overlap gt speclength then begin
      overlap = speclength - iw - 1
    endif
    if overlap lt 2 then break
    overlapwlen=spectrumdata[iw+overlap].wavelength-spectrumdata[iw].wavelength
    if (iw eq 0) then begin
      startpos=0
      startwlen=spectrumdata[0].wavelength;/redshift_initial_overall
    endif else begin
      startpos=iw;-long(overlap)-line_overlap_h
      startwlen=spectrumdata[startpos].wavelength;/redshift_initial_overall
      emissionlines_check = mgfit_init_fltr_emis(strongline_data, (startwlen-long(overlapwlen/8)), startwlen, redshift_initial)
      temp=size(emissionlines_check,/DIMENSIONS)
      nlines=temp[0]
      if (nlines gt 0) then begin
        if emissionlines_check[0].wavelength*(redshift_initial) le startwlen+long(overlapwlen/8)  then begin
          startpos=startpos-long(overlap)
          startwlen=spectrumdata[startpos].wavelength
        endif
      endif
    endelse

    if (iw+overlap-1 gt speclength) then begin
      endpos=speclength-1
      endwlen=spectrumdata[speclength-1].wavelength;/redshift_initial_overall
    endif else begin
      endpos=iw+long(overlap)+line_overlap_h-1
      ;endwlen=spectrumdata[iw+step1].wavelength;/redshift_initial_overall
      endwlen=spectrumdata[endpos].wavelength;/redshift_initial_overall
      emissionlines_check = mgfit_init_fltr_emis(deepline_data, (endwlen-long(overlapwlen/2)), (endwlen+long(overlapwlen/2)), redshift_initial)
      temp=size(emissionlines_check,/DIMENSIONS)
      nlines=temp[0]
      if (nlines gt 0) then begin
        if emissionlines_check[max(nlines)-1].wavelength*(redshift_initial) gt endwlen-long(overlapwlen/2) then begin
          endpos=endpos+long(overlap)
          temp=size(spectrumdata,/DIMENSIONS)
          if endpos ge temp[0] then begin
            endpos = temp[0] -1
          endif
          endwlen=spectrumdata[endpos].wavelength
        endif
      endif
    endelse
    ;if spectrumdata[iw].wavelength gt 5000. and spectrumdata[iw].wavelength lt 5020. then begin
    ;  print, "debug: [O III]"
    ;endif
    find_nearest=abs(strong_emissionlines.wavelength-startwlen)
    find_nearest_loc=where(find_nearest eq min(find_nearest))
    if find_nearest_loc[0] ne -1 then begin 
      find_nearest_loc=min(find_nearest_loc)
      if strong_emissionlines[find_nearest_loc].redshift ne 0 then begin
        redshift_initial = strong_emissionlines[find_nearest_loc].redshift
      endif
      if strong_emissionlines[find_nearest_loc].resolution ne 0 then begin
        resolution_initial= strong_emissionlines[find_nearest_loc].resolution
      endif
    endif
    spec_section =replicate(spectrumstructure, endpos-startpos+1)
    spec_section = spectrumdata[startpos:endpos]

    emissionlines_section=mgfit_init_fltr_emis(deepline_data, startwlen, endwlen, redshift_initial)
    temp=size(emissionlines_section,/DIMENSIONS)
    nlines=temp[0]

    if (nlines gt 0) then begin
      ;nimage=nimage+1
      ;imagename=output_path+'images/plot'+strtrim(string(i/step1+1),2)+'.eps'
      imagename='plot_'+strtrim(string(long(startwlen)),2)+'_'+strtrim(string(long(endwlen)),2)+'.eps'
      ;if long(startwlen) eq 4431 then printgenerations=1 else printgenerations=0
      if keyword_set(auto_line_array_size) eq 0 then begin
        if keyword_set(image_output_path) eq 1 then begin
          emissionlines_section = mgfit_emis(spec_section, redshift_initial, resolution_initial, $
            emissionlines_section, redshift_tolerance, resolution_tolerance, $
            resolution_min, resolution_max, $
            generations, popsize, pressure, line_array_size=linelocation0_step, $
            printgenerations=printgenerations, $
            /no_blueshift, /printimage, imagename=imagename, image_output_path=image_output_path, $
            no_mpfit=no_mpfit)
        endif else begin
          emissionlines_section = mgfit_emis(spec_section, redshift_initial, resolution_initial, $
            emissionlines_section, redshift_tolerance, resolution_tolerance, $
            resolution_min, resolution_max, $
            generations, popsize, pressure, line_array_size=linelocation0_step, $
            printgenerations=printgenerations, $
            /no_blueshift, no_mpfit=no_mpfit)
        endelse
      endif else begin
        if keyword_set(image_output_path) eq 1 then begin
          emissionlines_section = mgfit_emis(spec_section, redshift_initial, resolution_initial, $
            emissionlines_section, redshift_tolerance, resolution_tolerance, $
            resolution_min, resolution_max, $
            generations, popsize, pressure, $ ;line_array_size=linelocation0_step, $
            printgenerations=printgenerations, $
            /no_blueshift, /printimage, imagename=imagename, image_output_path=image_output_path, $
            no_mpfit=no_mpfit) 
        endif else begin
          emissionlines_section = mgfit_emis(spec_section, redshift_initial, resolution_initial, $
            emissionlines_section, redshift_tolerance, resolution_tolerance, $
            resolution_min, resolution_max, $
            generations, popsize, pressure, $ ;line_array_size=linelocation0_step, $
            printgenerations=printgenerations, $
            /no_blueshift, no_mpfit=no_mpfit) 
        endelse
      endelse

      redshift_initial=redshift_strongline
      resolution_initial=resolution_strongline

      if nlines gt 1 then begin
        emissionlines[linearraypos:linearraypos+nlines-1]=emissionlines_section
      endif else begin
        emissionlines[linearraypos]=emissionlines_section
      endelse
      linearraypos=linearraypos+nlines

      print, "Level %:", double(iw+1)/double(speclength)*100.0
    endif
    iw = endpos
    ;endfor
  endwhile
  return, emissionlines
end

