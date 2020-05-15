; docformat = 'rst'

function mgfit_detect_strong_lines, wavelength, flux, strongline_data, $
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
                                    printgenerations=printgenerations, $
                                    no_mpfit=no_mpfit, no_blueshift=no_blueshift
;+
;     This function detects lines from the strong line list.
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
;     printgenerations :    in, optional, type=string
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
;     IDL> strong_emissionlines = mgfit_detect_strong_lines(wavelength, flux, strongline_data)
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
  if keyword_set(strongline_data) eq 0 then begin
    print,'strongline_data is not set'
    return, 0
  endif 
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
    interval_wavelength = 500
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
    fwhm_tolerance = 0.1 *fwhm_initial
  endif 
  if keyword_set(fwhm_min) eq 0 then begin
    fwhm_min = 0.1
  endif 
  if keyword_set(fwhm_max) eq 0 then begin
    fwhm_max = 1.0
  endif
  temp=size(wavelength,/DIMENSIONS)
  speclength=temp[0]
  wavelength_min=wavelength[0]
  wavelength_max=wavelength[speclength-1]

  spectrumdata=mgfit_init_spec(wavelength, flux)
  temp=size(spectrumdata,/DIMENSIONS)
  spectrumdata_len=temp[0]
  ; calculate resolution based on the nyquist sampling rate
  if keyword_set(fwhm_initial) eq 0 then begin
    fwhm_initial=2.355*(spectrumdata[3].wavelength-spectrumdata[1].wavelength)/2.;2*spectrumdata[2].wavelength/(spectrumdata[3].wavelength-spectrumdata[1].wavelength)
  endif 
  
  ; detect the strong lines
  strong_emissionlines=mgfit_init_fltr_emis(strongline_data, wavelength_min, wavelength_max, redshift_initial)

  temp=size(strong_emissionlines,/DIMENSIONS)
  nlines=temp[0]
  
  linelocation0_step= max(where(spectrumdata.wavelength lt spectrumdata[0].wavelength+6.0))
  linelocation0_step= round(linelocation0_step/10.0)*10
  linelocation0_step_h=round(linelocation0_step/2)
  line_overlap_h=linelocation0_step_h
  
  stronglines=replicate(spectrumstructure, linelocation0_step*nlines)

  for i=0, nlines-1 do begin
    linelocation0 = where(spectrumdata.wavelength gt redshift_initial*strong_emissionlines[i].wavelength)
    linelocation=min(linelocation0)
    ; if linelocation+24 le speclength then begin
    ;   stronglines[50*i:50*(i+1)-1] = spectrumdata[linelocation-25:linelocation+24]
    ; endif else begin
    ;   stronglines[50*i:50*(i)+speclength-1-linelocation+25] = spectrumdata[linelocation-25:speclength-1]
    ; endelse
    if linelocation-linelocation0_step_h ge 0 and linelocation+linelocation0_step_h-1 le speclength then begin
      stronglines[linelocation0_step*i:linelocation0_step*(i+1)-1] = spectrumdata[linelocation-linelocation0_step_h:linelocation+linelocation0_step_h-1]
    endif else begin
      if linelocation-linelocation0_step_h lt 0  then begin
        stronglines[linelocation0_step*(i+1)-1-(linelocation+linelocation0_step_h-1):linelocation0_step*(i+1)-1] = spectrumdata[0:linelocation+linelocation0_step_h-1]
      endif
      if linelocation+linelocation0_step_h-1 gt speclength then begin
        stronglines[linelocation0_step*i:linelocation0_step*(i)+speclength-1-linelocation+linelocation0_step_h] = spectrumdata[linelocation-linelocation0_step_h:speclength-1]
      endif
    endelse
  endfor

  linearraypos=0
  ;step1=2000
  step1=interval_wavelength;500
  step1=nint_idl(2*redshift_tolerance/(1.-spectrumdata[0].wavelength/spectrumdata[1].wavelength))
  line_overlap_h=0
  ;for i=0L,speclength-1,step1 do begin
  iw =0
  overlap=nint_idl(redshift_tolerance/(1.-spectrumdata[iw].wavelength/spectrumdata[iw+1].wavelength))
  while ((iw + long(overlap/4)) lt speclength) do begin
    overlap=nint_idl(redshift_tolerance/(1.-spectrumdata[iw].wavelength/spectrumdata[iw+1].wavelength))
    if iw + overlap gt speclength then begin
      overlap = speclength - iw - 1
    endif
    if overlap lt 2 then break
    if (iw+overlap) ge spectrumdata_len then begin
       overlap = spectrumdata_len - iw - 1
    endif
    overlapwlen=spectrumdata[iw+overlap].wavelength-spectrumdata[iw].wavelength
    if (iw eq 0) then begin
      startpos=0
      startwlen=spectrumdata[0].wavelength;/redshift_initial_overall
    endif else begin
      startpos=iw;-long(overlap)-line_overlap_h
      startwlen=spectrumdata[startpos].wavelength;/redshift_initial_overall
      emissionlines_check = mgfit_init_fltr_emis(strongline_data, (startwlen-long(overlapwlen/4)), startwlen, redshift_initial)
      temp=size(emissionlines_check,/DIMENSIONS)
      nlines=temp[0]
      if (nlines gt 0) then begin
        if emissionlines_check[0].wavelength*(redshift_initial) le startwlen+long(overlapwlen/4)  then begin
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
      emissionlines_check = mgfit_init_fltr_emis(strongline_data, (endwlen-long(overlapwlen/4)), (endwlen+long(overlapwlen/4)), redshift_initial)
      temp=size(emissionlines_check,/DIMENSIONS)
      nlines=temp[0]
      if (nlines gt 0) then begin
        if emissionlines_check[max(nlines)-1].wavelength*(redshift_initial) gt endwlen-long(overlapwlen/4) then begin
          endpos=endpos+long(overlap)
          endwlen=spectrumdata[endpos].wavelength
        endif
      endif
    endelse
    spec_section =replicate(spectrumstructure, endpos-startpos+1)
    spec_section = spectrumdata[startpos:endpos]

    emissionlines_section=mgfit_init_fltr_emis(strongline_data, startwlen, endwlen, redshift_initial)
    temp=size(emissionlines_section,/DIMENSIONS)
    nlines=temp[0]

    if (nlines gt 0) then begin
      ;imagename=output_path+'images/strong'+strtrim(string(iw/step1+1),2)+'.eps'
      if keyword_set(auto_line_array_size) eq 0 then begin
        emissionlines_section = mgfit_emis(spec_section, redshift_initial, fwhm_initial, $
          emissionlines_section, redshift_tolerance, fwhm_tolerance, $
          fwhm_min, fwhm_max, $
          generations, popsize, pressure, line_array_size=linelocation0_step, $
          image_output_path=image_output_path, printgenerations=printgenerations, $
          no_blueshift=no_blueshift, no_mpfit=no_mpfit, rebin_resolution=rebin_resolution)
      endif else begin
        emissionlines_section = mgfit_emis(spec_section, redshift_initial, fwhm_initial, $
          emissionlines_section, redshift_tolerance, fwhm_tolerance, $
          fwhm_min, fwhm_max, $
          generations, popsize, pressure, $; , line_array_size=linelocation0_step, $   
          image_output_path=image_output_path, printgenerations=printgenerations, $
          no_blueshift=no_blueshift, no_mpfit=no_mpfit, rebin_resolution=rebin_resolution)
      endelse

      strong_line=min(where(emissionlines_section.flux eq max(emissionlines_section.flux)))
      ;redshift_initial0 = emissionlines_section[strong_line].redshift
      ;redshift_initial=redshift_initial0
      if strong_line[0] ne -1 then begin
        ;redshift_initial=emissionlines_section[strong_line].redshift
        if nlines gt 1 then begin
          strong_emissionlines[linearraypos:linearraypos+nlines-1]=emissionlines_section
        endif else begin
          ;temp=size(strong_emissionlines,/DIMENSIONS)
          ;if linearraypos lt temp[0] then begin
          strong_emissionlines[linearraypos]=emissionlines_section
          ;endif
        endelse
      endif
      linearraypos=linearraypos+nlines

      print, "Level %:", double(iw+1)/double(speclength)*100.0
    endif
    iw = endpos
    ;endfor
  endwhile
  return, strong_emissionlines
end

