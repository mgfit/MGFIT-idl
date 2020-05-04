; docformat = 'rst'

function mgfit_emis, specdata, redshift_initial, resolution_initial, emissionlines, $
                     redshift_tolerance1, resolution_tolerance1, $
                     resolution_min, resolution_max,$
                     generations, popsize, pressure, line_array_size=line_array_size, $
                     no_blueshift=no_blueshift, printimage=printimage, $
                     imagename=imagename, image_output_path=image_output_path, $
                     printgenerations=printgenerations
;+
;     This function fits multiple Gaussian functions to a list of emission lines using 
;     a least-squares minimization technique and a genetic-type random walk
;     method. It uses the MPFIT idl library to initialize the parameters of
;     the run in the first iteration. The continuum curve is determined 
;     using mgfit_contin() and subtracted before the line identification 
;     and flux measurements. It uses mgfit_emis_err() to estimate the 
;     uncertainties itroduced by the best-fit model residuals and 
;     the white noise. 
;
; :Returns:
;    type=arrays of structures. This function returns the arrays of structures 
;                              { wavelength: 0.0, peak:0.0, sigma1:0.0, flux:0.0, 
;                                uncertainty:0.0, redshift:0.0, resolution:0.0, 
;                                blended:0, Ion:'', Multiplet:'', 
;                                LowerTerm:'', UpperTerm:'', g1:'', g2:''}
;
; :Keywords:
;     line_array_size    :     in, required, type=float   
;                              size of the line array
; 
;     printimage         :     in, required, type=boolean
;                              Set to produce plots
; 
;     imagename          :     in, required, type=string
;                              The file name for plots if printimage sets
;                               
;     image_output_path    :    in, optional, type=string
;                               the image output path
;                               
;     printgenerations :    in, optional, type=string
;                                Set to produce plots in all generations 
;
; :Params:
;     specdata           :     in, required, type=arrays of structures
;                              the observed spectrum stored in 
;                              the arrays of structures {wavelength: 0.0, flux:0.0, residual:0.0}
;     
;     redshift_initial   :     in, required, type=float   
;                              the initial/guess redshift
;     
;     resolution_initial :     the initial/guess spectral resolution
;     
;     emissionlines      :     in, required, type=arrays of structures    
;                              the specified emission lines stored in
;                              the arrays of structures 
;                              { wavelength: 0.0, 
;                                peak:0.0, 
;                                sigma1:0.0, 
;                                flux:0.0, 
;                                continuum:0.0, 
;                                uncertainty:0.0, 
;                                redshift:0.0, 
;                                resolution:0.0, 
;                                blended:0, 
;                                Ion:'', 
;                                Multiplet:'', 
;                                LowerTerm:'', 
;                                UpperTerm:'', 
;                                g1:'', 
;                                g2:''}
;     
;     redshift_tolerance   :    in, required, type=float  
;                               the redshift tolerance
;     
;     resolution_tolerance :    in, required, type=float  
;                               the spectral resolution tolerance
;     
;     generations          :    in, required, type=float   
;                               the maximum generation number in the genetic algorithm
;     
;     popsize              :    in, required, type=float  
;                               the population size in each generation in the genetic algorithm
;     
;     pressure             :    in, required, type=float  
;                               the value of the selective pressure in the genetic algorithm
;                          
; :Examples:
;    For example::
;
;     IDL> fitstronglines = mgfit_emis(stronglines, redshift_initial, resolution_initial, $
;     IDL>                            emissionlines, redshift_tolerance1, resolution_tolerance1, $
;     IDL>                            generations, popsize, pressure, line_array_size=linelocation0_step)
;
; :Categories:
;   Emission
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
;     20/07/2014, A. Danehkar, Adopted from Algorithm used 
;                              in the FORTRAN program ALFA by R. Wessson
;     
;     22/07/2015, A. Danehkar, Several performance optimized.
;     
;     12/11/2015, A. Danehkar, Degree and variance added to chi_squared.
;     
;     15/02/2016, A. Danehkar, Continuum subtracted before fitting.
;     
;     22/02/2016, A. Danehkar, Uncertainties estimation added.
;     
;     15/10/2016, A. Danehkar, Fixed small bugs.
;     
;     22/11/2017, A. Danehkar, New parameters added, other modifications.
;-

  common random_seed, seed
  spectrumstructure={wavelength: 0.0, flux:0.0, residual:0.0}
  emissionlinestructure={wavelength: 0.0, peak:0.0, sigma1:0.0, flux:0.0, continuum:0.0, uncertainty:0.0, redshift:0.0, resolution:0.0, blended:0, Ion:'', Multiplet:'', LowerTerm:'', UpperTerm:'', g1:'', g2:''}
  populationstructure={wavelength: 0.0, peak:0.0, sigma1:0.0, flux:0.0, continuum:0.0, uncertainty:0.0, redshift:0.0, resolution:0.0, blended:0}
  
  temp=size(emissionlines,/DIMENSIONS)
  nlines=temp[0]
  temp=size(specdata,/DIMENSIONS)
  speclength=temp[0]
  ret=mgfit_init_seed()
  specscale=1.0
  specdata1=specdata
;  if (max(specdata1.flux) lt 0.01) then begin
    specscale = 1./max(specdata1.flux)
;  end
  specdata1.flux = specdata1.flux * specscale
  specsynth=replicate(spectrumstructure, speclength, popsize)
  
  chi_squared = fltarr(popsize)
  breed = replicate(populationstructure, long(popsize*pressure), nlines)
  population = replicate(populationstructure, popsize, nlines)
  
  ; make population of synthetic spectrum population
  negetive_loc=where(specdata1.flux lt 0.0)
  if negetive_loc[0] ne -1 then specdata1[negetive_loc].flux=0.0
  
  continuum=mgfit_contin(specdata1)
  
  ;plot,continuum.wavelength,continuum.flux
  specdata1=mpfit_whitenoise(specdata1)
  
  specdata1.flux=specdata1.flux-continuum.flux
  negetive_loc=where(specdata1.flux lt 0.0)
  if negetive_loc[0] ne -1 then specdata1[negetive_loc].flux=0.0
  
  if keyword_set(line_array_size) then begin
    linelocation0_step=line_array_size
  endif else begin
    linelocation0_step= max(where(specdata1.wavelength lt specdata1[0].wavelength+5.0))
  endelse
  linelocation0_step= long(linelocation0_step/10.0)*10
  if linelocation0_step eq 0 then begin
    return, emissionlines ; cannot find lines!
  endif
  linelocation0_step_h=long(linelocation0_step/4)
  for i=0, nlines-1 do begin
      linelocation0 = where(specdata1.wavelength gt redshift_initial*emissionlines[i].wavelength)
      linelocation=min(linelocation0)
      if linelocation-linelocation0_step_h ge 0 and linelocation+linelocation0_step_h-1 lt speclength then begin
        lam1 = specdata1[linelocation-linelocation0_step_h:linelocation+linelocation0_step_h-1].wavelength
        spec1 = specdata1[linelocation-linelocation0_step_h:linelocation+linelocation0_step_h-1].flux
        cont1= mean(continuum[linelocation-linelocation0_step_h:linelocation+linelocation0_step_h-1].flux)
      endif else begin
        if linelocation-linelocation0_step_h lt 0  then begin
          lam1 = specdata1[0:linelocation+linelocation0_step_h-1].wavelength
          spec1 = specdata1[0:linelocation+linelocation0_step_h-1].flux
          cont1= mean(continuum[0:linelocation+linelocation0_step_h-1].flux)
        endif
        if linelocation+linelocation0_step_h-1 ge speclength then begin
          lam1= specdata1[linelocation-linelocation0_step_h:speclength-1].wavelength
          spec1 = specdata1[linelocation-linelocation0_step_h:speclength-1].flux
          cont1= mean(continuum[linelocation-linelocation0_step_h:speclength-1].flux)
        endif
      endelse
      yfit = mpfitpeak(lam1, spec1, a, error=perror, /POSITIVE)
      ;a[0] Peak Value 
      ;a[1] Peak Centroid 
      ;a[2] Gaussian Sigma
      sigma_tolerance1=emissionlines[i].wavelength/resolution_initial
      peak1=a[0]
      centroid1=a[1]
      sigma1=a[2]
      if (abs(sigma1) gt sigma_tolerance1) then begin
        sigma1 = sigma_tolerance1
      endif
      ;if peak1 le 0 then begin
      ;  peak1=0
      ;  centroid1=emissionlines[i].wavelength
      ;  sigma1=(emissionlines[i].wavelength/resolution_initial)
      ;endif
      if a[0] gt 0 then begin
        emissionlines[i].peak=peak1
        emissionlines[i].sigma1=sigma1
        emissionlines[i].resolution=emissionlines[i].wavelength/emissionlines[i].sigma1
        emissionlines[i].redshift=centroid1/emissionlines[i].wavelength
        if keyword_set(no_blueshift) then begin
          if emissionlines[i].redshift lt redshift_initial then begin
             emissionlines[i].redshift = redshift_initial
          endif
        endif
        emissionlines[i].continuum=cont1
      end else begin
        emissionlines[i].peak=1.0
        emissionlines[i].sigma1=emissionlines[i].wavelength/resolution_initial
        emissionlines[i].resolution=resolution_initial
        emissionlines[i].redshift=redshift_initial
        emissionlines[i].continuum=cont1
      endelse
  endfor
  sigma1=mean(emissionlines[*].sigma1)
  wavelength1=mean(emissionlines[0].wavelength)
  resolution_initial=wavelength1/sigma1
  for i=0, popsize-1 do begin 
    specsynth[*,i].wavelength=specdata1.wavelength
    if nlines gt 1 then begin
      population[i,*].wavelength = transpose(emissionlines.wavelength)
      population[i,*].peak=transpose(emissionlines.peak)
      population[i,*].resolution=transpose(emissionlines.resolution);resolution_initial
      population[i,*].sigma1=transpose(emissionlines.sigma1)
      population[i,*].redshift=transpose(emissionlines.redshift);redshift_initial
      population[i,*].continuum = 0 ; continuum subtracted
    endif else begin
      population[i,*].wavelength = emissionlines.wavelength
      population[i,*].peak=emissionlines.peak
      population[i,*].resolution=emissionlines.resolution;resolution_initial
      population[i,*].sigma1=emissionlines.sigma1
      population[i,*].redshift=emissionlines.redshift;redshift_initial
      population[i,*].continuum = 0 ; continuum subtracted
    endelse
  endfor
  nzero_lines=where(emissionlines.peak ne 0)
  temp=size(nzero_lines,/DIMENSIONS)
  gaussian_number=temp[0]
  sigma_squares=variance(specdata1[*].flux)
  mean_flux=mean(specdata1[*].flux)
  freedom_degree=speclength - gaussian_number
  for gencount=0,generations-1 do begin
    specsynth.flux[*]=0.0
    chi_squared[*]=0.0
    for popnumber=0,popsize-1 do begin
      ;make synthetic spectrum
      specsynth[*,popnumber]=mgfit_synth_spec(population[popnumber,*], specsynth[*,popnumber])
      ;calculate chi-squares 
      deviates=(specdata1[*].flux-specsynth[*,popnumber].flux)
      chi_squared[popnumber]=total(deviates^2)/(freedom_degree*sigma_squares)
      chi_squared2=chi_squared
;      residualmin=min(specdata1.residual)
;      if residualmin ne 0 then begin
;        deviates=(specdata1[*].flux-specsynth[*,popnumber].flux)/specdata1[*].residual
;        chi_squared[popnumber]=total(deviates^2)/freedom_degree
;      endif else begin
;         deviates=(specdata1[*].flux-specsynth[*,popnumber].flux)
;         chi_squared[popnumber]=total(deviates^2)/freedom_degree
;      endelse
    endfor
    if (gencount eq generations-1) then begin
       break;
    endif
    chi_squared_min_loc=minloc_idl(chi_squared,first=1)
    population[0,*]=population[chi_squared_min_loc,*];
    chi_squared[chi_squared_min_loc]=1.e30
    for i=0,long(popsize*pressure)-1 do begin
      chi_squared_min_loc=minloc_idl(chi_squared,first=1)
      breed[i,*] = population[chi_squared_min_loc,*]
      chi_squared[chi_squared_min_loc]=1.e20
    endfor
    for i=1, popsize - 1  do begin
      random1 = randomu(seed, 2)
      loc1=long((popsize*pressure-1)*random1[0])
      loc2=long((popsize*pressure-1)*random1[1])
      population[i,*].peak=(breed[loc1,*].peak + breed[loc2,*].peak)/2.0
      ;population[i,*].sigma1=(breed[loc1,*].sigma1 + breed[loc2,*].sigma1)/2.0
      population[i,*].resolution=(breed[loc1,*].resolution + breed[loc2,*].resolution)/2.0
      population[i,*].redshift=(breed[loc1,*].redshift + breed[loc2,*].redshift)/2.0
      population[i,*].sigma1=population[i,*].wavelength/population[i,*].resolution
    endfor
    for popnumber=1,popsize-1 do begin
      for lineid=0,nlines -1   do begin
        population[popnumber,lineid].resolution = population[popnumber,lineid].resolution + ((mgfit_mutation1()-1.)*resolution_tolerance1)
        population[popnumber,lineid].resolution = population[popnumber,lineid].wavelength/emissionlines[lineid].sigma1
        if (abs(population[popnumber,lineid].resolution-resolution_initial) gt resolution_tolerance1) then begin
           population[popnumber,lineid].resolution = population[popnumber,lineid].wavelength/emissionlines[lineid].sigma1
           population[popnumber,lineid].sigma1=emissionlines[lineid].sigma1
        endif
        population[popnumber,lineid].redshift = population[popnumber,lineid].redshift + ((mgfit_mutation1()-1.)*redshift_tolerance1)  
        if keyword_set(no_blueshift) then begin
          if population[popnumber,lineid].redshift lt redshift_initial then begin
             population[popnumber,lineid].redshift = redshift_initial
          endif       
        endif
        if (abs(population[popnumber,lineid].redshift-redshift_initial) gt redshift_tolerance1) then begin
          population[popnumber,lineid].redshift = emissionlines[lineid].redshift
        endif
        population[popnumber,lineid].peak = population[popnumber,lineid].peak * (1.+0.5*(mgfit_mutation1()-1.))
      endfor
    endfor
    percentage = double(gencount+1)/double(generations)*100.0
    if percentage mod 20 eq 0 then print, "Percentage:", percentage
    if keyword_set(printgenerations) eq 1 and total(emissionlines.peak) ne 0 then begin 
      ;set_plot,'ps'
      set_plot,'ps'
      if keyword_set(image_output_path) eq 1 then begin
        filename=image_output_path+'/plot_'+strtrim(string(long(min(specdata.wavelength))),2)+'_'+strtrim(string(long(max(specdata.wavelength))),2)+'_'+strtrim(string(long(max(gencount))),2)+'.eps'
      endif else begin
        filename='plot_'+strtrim(string(long(startwlen)),2)+'_'+strtrim(string(long(endwlen)),2)+'_'+strtrim(string(long(max(gencount))),2)+'.eps'
      endelse
      device, /color, bits_per_pixeL=8, font_size=7, $
           filename=filename, $
           encapsulated=1, helvetica=1, bold=1, book=1, $
           xsize=7.0, ysize=2.391, inches=1
      loadct,13
      
      plot, specdata1.wavelength, specdata1.flux, color=cgColor('black'), $
           XTITLE=textoidl('\lambda (!6!sA!r!u!9 %!6 !n)'), $
           YTITLE=textoidl('F_{\lambda} (10^{-15} erg cm^{-2} s^{-1} !6!sA!r!u!9 %!6 !n^{-1})'), $
           ;XRANGE =[3600, 4400], 
           YRANGE=[0.0, 1.5*max(specdata1.flux)], $
           position=[0.1, 0.10, 0.97, 0.95], $  ; with scale
           XTICKLEN=0.01, YTICKLEN=0.01, $
           XStyle=1, YStyle=1 ;/nodata , Thick=0.5,  
      specsynth1=specsynth[*,0]
      oplot, specsynth1.wavelength, specsynth1.flux, color=cgColor('red')
      for lineid=0,nlines -1   do begin
        if emissionlines[lineid].flux ne 0 then begin
          IonName='  - '+emissionlines[lineid].ion + ' ' +textoidl('\lambda')+ strtrim(string(long(emissionlines[lineid].wavelength)),2)
          ;textoidl('!6!sA!r!u!9 %!6 !n')
          xyouts, emissionlines[lineid].wavelength*emissionlines[lineid].redshift, emissionlines[lineid].peak, IonName, ORIENTATION=90, /DATA
        endif
      endfor
    
      device, /close
      
      set_plot, 'x'
    endif
  endfor
  chi_squared_min_loc=minloc_idl(chi_squared,first=1)
  specsynth_best=specsynth[*,chi_squared_min_loc]
  for lineid=0,nlines -1   do begin
    emissionlines[lineid].wavelength=population[chi_squared_min_loc,lineid].wavelength
    emissionlines[lineid].peak=population[chi_squared_min_loc,lineid].peak
    emissionlines[lineid].sigma1=population[chi_squared_min_loc,lineid].sigma1
    emissionlines[lineid].flux=population[chi_squared_min_loc,lineid].flux
    emissionlines[lineid].uncertainty=population[chi_squared_min_loc,lineid].uncertainty
    emissionlines[lineid].redshift=population[chi_squared_min_loc,lineid].redshift
    emissionlines[lineid].resolution=population[chi_squared_min_loc,lineid].resolution
    emissionlines[lineid].blended=population[chi_squared_min_loc,lineid].blended
  endfor
  non_physical_loc=where(emissionlines.resolution lt resolution_min or emissionlines.resolution gt resolution_max)
  if non_physical_loc[0] ne -1 then begin
    emissionlines[non_physical_loc].peak=0.0
    emissionlines[non_physical_loc].sigma1=0.0
    emissionlines[non_physical_loc].flux=0.0
    emissionlines[non_physical_loc].uncertainty=0.0
    emissionlines[non_physical_loc].redshift=0.0
    emissionlines[non_physical_loc].resolution=0.0
    emissionlines[non_physical_loc].blended=0
  endif
  non_physical_loc=where(emissionlines.wavelength*emissionlines.redshift gt max(specdata1.wavelength) or $
                         emissionlines.wavelength*emissionlines.redshift lt min(specdata1.wavelength) )
  if non_physical_loc[0] ne -1 then begin
    emissionlines[non_physical_loc].peak=0.0
    emissionlines[non_physical_loc].sigma1=0.0
    emissionlines[non_physical_loc].flux=0.0
    emissionlines[non_physical_loc].uncertainty=0.0
    emissionlines[non_physical_loc].redshift=0.0
    emissionlines[non_physical_loc].resolution=0.0
    emissionlines[non_physical_loc].blended=0
  endif
  specsynth_best=replicate(spectrumstructure, speclength)
  specsynth_best[*].wavelength=specdata1.wavelength
  specsynth_best[*].flux=0.0
  specsynth_best=mgfit_synth_spec(emissionlines, specsynth_best)
  ; estimate uncertainties
  if max(emissionlines.peak) ne 0 then begin
    emissionlines=mgfit_emis_err(specsynth_best, specdata1, emissionlines, redshift_initial)
  endif 
  emissionlines.sigma1=emissionlines.wavelength/emissionlines.resolution
  emissionlines.peak = emissionlines.peak / specscale
  emissionlines.uncertainty = emissionlines.uncertainty / specscale
  specdata1.flux = specdata1.flux / specscale
  specsynth_best.flux = specsynth_best.flux / specscale
  ;plot,  specdata1.wavelength, specdata1.flux, color=cgColor('white'), XRANGE =[4420, 7060]
  ;plot,  specdata1.wavelength, specdata1.flux, color=cgColor('white'), XRANGE =[4800, 5100]
  ;plot,  specdata1.wavelength, specdata1.flux, color=cgColor('white'), XRANGE =[6500, 6700]
  ;plot,  specdata1.wavelength, specdata1.flux, color=cgColor('white')
  ;oplot, specsynth_best.wavelength, specsynth_best.flux, color=cgColor('red')
  ;oplot,  continuum.wavelength, continuum.flux, color=cgColor('blue')
  emissionlines.flux= emissionlines.peak*emissionlines.sigma1*sqrt(2*!dpi)
  
  if total(emissionlines.peak) ne 0 then begin 
    set_plot, 'x'
    plot, specdata1.wavelength, specdata1.flux, color=cgColor('white'), $
          XTITLE=textoidl('\lambda (!6!sA!r!u!9 %!6 !n)'), $
          YTITLE=textoidl('F_{\lambda} (10^{-15} erg cm^{-2} s^{-1} !6!sA!r!u!9 %!6 !n^{-1})'), $
          ;XRANGE =[3600, 4400],
          YRANGE=[0.0, 1.5*max(specdata1.flux)], $
          XTICKLEN=0.01, YTICKLEN=0.01, $
          XStyle=1, YStyle=1 ;/nodata , Thick=0.5,
      
    oplot, specsynth_best.wavelength, specsynth_best.flux, color=cgColor('red') 
    
    for lineid=0,nlines -1   do begin
      if emissionlines[lineid].flux ne 0 then begin
        IonName='  - '+emissionlines[lineid].ion + ' ' +textoidl('\lambda')+ strtrim(string(long(emissionlines[lineid].wavelength)),2)
        ;textoidl('!6!sA!r!u!9 %!6 !n')
        xyouts, emissionlines[lineid].wavelength*emissionlines[lineid].redshift, emissionlines[lineid].peak, IonName, ORIENTATION=90, /DATA
      endif
    endfor
  endif
  
  if keyword_set(printimage) eq 1 and total(emissionlines.peak) ne 0 then begin 
    ;set_plot,'ps'
    set_plot,'ps'
    if keyword_set(imagename) eq 1 and keyword_set(image_output_path) eq 1 then begin
      filename=image_output_path+'/'+imagename
    endif else begin
      if keyword_set(image_output_path) eq 1 then begin
        filename=image_output_path+'/plot_'+strtrim(string(long(min(specdata.wavelength))),2)+'_'+strtrim(string(long(max(specdata.wavelength))),2)+'.eps'
      endif else begin
        filename='plot_'+strtrim(string(long(startwlen)),2)+'_'+strtrim(string(long(endwlen)),2)+'.eps'
      endelse
    endelse
    device, /color, bits_per_pixeL=8, font_size=7, $
         filename=filename, $
         encapsulated=1, helvetica=1, bold=1, book=1, $
         xsize=7.0, ysize=2.391, inches=1
    loadct,13
    
    plot, specdata1.wavelength, specdata1.flux, color=cgColor('black'), $
         XTITLE=textoidl('\lambda (!6!sA!r!u!9 %!6 !n)'), $
         YTITLE=textoidl('F_{\lambda} (10^{-15} erg cm^{-2} s^{-1} !6!sA!r!u!9 %!6 !n^{-1})'), $
         ;XRANGE =[3600, 4400], 
         YRANGE=[0.0, 1.5*max(specdata1.flux)], $
         position=[0.1, 0.10, 0.97, 0.95], $  ; with scale
         XTICKLEN=0.01, YTICKLEN=0.01, $
         XStyle=1, YStyle=1 ;/nodata , Thick=0.5,  
    oplot, specsynth_best.wavelength, specsynth_best.flux, color=cgColor('red')
    for lineid=0,nlines -1   do begin
      if emissionlines[lineid].flux ne 0 then begin
        IonName='  - '+emissionlines[lineid].ion + ' ' +textoidl('\lambda')+ strtrim(string(long(emissionlines[lineid].wavelength)),2)
        ;textoidl('!6!sA!r!u!9 %!6 !n')
        xyouts, emissionlines[lineid].wavelength*emissionlines[lineid].redshift, emissionlines[lineid].peak, IonName, ORIENTATION=90, /DATA
      endif
    endfor
  
    device, /close
    
    set_plot, 'x'
  endif
  return, emissionlines
end

