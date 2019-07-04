; docformat = 'rst'

function mgfit_emis, specdata, redshift_initial, resolution_initial, emissionlines, $
                     redshift_tolerance1, resolution_tolerance1, generations, $ 
                     popsize, pressure, line_array_size=line_array_size, $
                     printimage=printimage, imagename=imagename
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
  emissionlinestructure={wavelength: 0.0, peak:0.0, sigma1:0.0, flux:0.0, uncertainty:0.0, redshift:0.0, resolution:0.0, blended:0, Ion:'', Multiplet:'', LowerTerm:'', UpperTerm:'', g1:'', g2:''}
  temp=size(emissionlines,/DIMENSIONS)
  nlines=temp[0]
  temp=size(specdata,/DIMENSIONS)
  speclength=temp[0]
  ret=mgfit_init_seed()
  specscale=1.0
;  if (max(specdata.flux) lt 0.01) then begin
    specscale = 1./max(specdata.flux)
;  end
  specdata.flux = specdata.flux * specscale
  specsynth=replicate(spectrumstructure, speclength, popsize)
  
  chi_squared = fltarr(popsize)
  breed = replicate(emissionlinestructure, long(popsize*pressure), nlines)
  population = replicate(emissionlinestructure, popsize, nlines)
  ; make population of synthetic spectrum population
  
  ;specdata2=specdata
  continuum=mgfit_contin(specdata)
  specdata=mpfit_whitenoise(specdata)
  
  specdata.flux=specdata.flux-continuum.flux
  negetive_loc=where(specdata.flux lt 0.0)
  if negetive_loc[0] ne -1 then specdata[negetive_loc].flux=0.0

  if keyword_set(line_array_size) then begin
    linelocation0_step=line_array_size
  endif else begin
    linelocation0_step= max(where(specdata.wavelength lt specdata[0].wavelength+5.0))
  endelse
  linelocation0_step= round(linelocation0_step/10.0)*10
  linelocation0_step_h=round(linelocation0_step/2)
  for i=0, nlines-1 do begin
      linelocation0 = where(specdata.wavelength gt redshift_initial*emissionlines[i].wavelength)
      linelocation=min(linelocation0)
      if linelocation-linelocation0_step_h ge 0 and linelocation+linelocation0_step_h-1 le speclength then begin
        lam1 = specdata[linelocation-linelocation0_step_h:linelocation+linelocation0_step_h-1].wavelength
        spec1 = specdata[linelocation-linelocation0_step_h:linelocation+linelocation0_step_h-1].flux
      endif else begin
        if linelocation-linelocation0_step_h lt 0  then begin
          lam1 = specdata[0:linelocation+linelocation0_step_h-1].wavelength
          spec1 = specdata[0:linelocation+linelocation0_step_h-1].flux
        endif
        if linelocation+linelocation0_step_h-1 gt speclength then begin
          lam1= specdata[linelocation-linelocation0_step_h:speclength-1].wavelength
          spec1 = specdata[linelocation-linelocation0_step_h:speclength-1].flux
        endif
      endelse
      yfit = mpfitpeak(lam1, spec1, a, error=perror)
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
      end else begin
        emissionlines[i].peak=1.0
        emissionlines[i].sigma1=emissionlines[i].wavelength/resolution_initial
        emissionlines[i].resolution=resolution_initial
        emissionlines[i].redshift=redshift_initial
      endelse
  endfor
  sigma1=mean(emissionlines[*].sigma1)
  wavelength1=mean(emissionlines[0].wavelength)
  resolution_initial=wavelength1/sigma1
  for i=0, popsize-1 do begin 
    specsynth[*,i].wavelength=specdata.wavelength
    if nlines gt 1 then begin
      population[i,*].wavelength = transpose(emissionlines.wavelength)
      population[i,*].peak=transpose(emissionlines.peak)
      population[i,*].resolution=transpose(emissionlines.resolution);resolution_initial
      population[i,*].sigma1=transpose(emissionlines.sigma1)
      population[i,*].redshift=transpose(emissionlines.redshift);redshift_initial
      population[i,*].Ion=transpose(emissionlines.Ion)
      population[i,*].Multiplet=transpose(emissionlines.Multiplet)
      population[i,*].LowerTerm=transpose(emissionlines.LowerTerm)
      population[i,*].UpperTerm=transpose(emissionlines.UpperTerm)
      population[i,*].g1=transpose(emissionlines.g1)
      population[i,*].g2=transpose(emissionlines.g2)
    endif else begin
      population[i,*].wavelength = emissionlines.wavelength
      population[i,*].peak=emissionlines.peak
      population[i,*].resolution=emissionlines.resolution;resolution_initial
      population[i,*].sigma1=emissionlines.sigma1
      population[i,*].redshift=emissionlines.redshift;redshift_initial
      population[i,*].Ion=emissionlines.Ion
      population[i,*].Multiplet=emissionlines.Multiplet
      population[i,*].LowerTerm=emissionlines.LowerTerm
      population[i,*].UpperTerm=emissionlines.UpperTerm
      population[i,*].g1=emissionlines.g1
      population[i,*].g2=emissionlines.g2
    endelse
  endfor
  nzero_lines=where(emissionlines.peak ne 0)
  temp=size(nzero_lines,/DIMENSIONS)
  gaussian_number=temp[0]
  sigma_squares=variance(specdata[*].flux)
  mean_flux=mean(specdata[*].flux)
  freedom_degree=speclength - gaussian_number
  for gencount=0,generations-1 do begin
    specsynth.flux[*]=0.0
    chi_squared[*]=0.0
    for popnumber=0,popsize-1 do begin
      ;make synthetic spectrum
      specsynth[*,popnumber]=mgfit_synth_spec(population[popnumber,*], specsynth[*,popnumber])
      ;calculate chi-squares 
      deviates=(specdata[*].flux-specsynth[*,popnumber].flux)
      chi_squared[popnumber]=total(deviates^2)/(freedom_degree*sigma_squares)
      chi_squared2=chi_squared
;      residualmin=min(specdata.residual)
;      if residualmin ne 0 then begin
;        deviates=(specdata[*].flux-specsynth[*,popnumber].flux)/specdata[*].residual
;        chi_squared[popnumber]=total(deviates^2)/freedom_degree
;      endif else begin
;         deviates=(specdata[*].flux-specsynth[*,popnumber].flux)
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
      population[popnumber,*].resolution = population[popnumber,*].resolution + ((mgfit_mutation1()-1.)*resolution_tolerance1)
      if (abs(population[popnumber,0].resolution-resolution_initial) gt resolution_tolerance1) then begin
        population[popnumber,*].resolution = resolution_initial
      endif
      population[popnumber,*].redshift = population[popnumber,*].redshift + ((mgfit_mutation1()-1.)*redshift_tolerance1)
      if (abs(population[popnumber,0].redshift-redshift_initial) gt redshift_tolerance1) then begin
        population[popnumber,*].redshift = redshift_initial
      endif
      for lineid=0,nlines -1   do begin
        population[popnumber,lineid].peak = population[popnumber,lineid].peak * (1.+0.5*(mgfit_mutation1()-1.))
      endfor
    endfor
    print, "Percentage:", double(gencount+1)/double(generations)*100.0
  endfor
  chi_squared_min_loc=minloc_idl(chi_squared,first=1)
  specsynth_best=specsynth[*,chi_squared_min_loc]
  emissionlines=population[chi_squared_min_loc,*];
  ; estimate uncertainties
  if max(emissionlines.peak) ne 0 then begin
    emissionlines=mgfit_emis_err(specsynth_best, specdata, emissionlines)
  endif 
  emissionlines.sigma1=emissionlines.wavelength/emissionlines.resolution
  emissionlines.peak = emissionlines.peak / specscale
  emissionlines.uncertainty = emissionlines.uncertainty / specscale
  specdata.flux = specdata.flux / specscale
  specsynth_best.flux = specsynth_best.flux / specscale
  ;plot,  specdata.wavelength, specdata.flux, color=cgColor('white'), XRANGE =[4420, 7060]
  ;plot,  specdata.wavelength, specdata.flux, color=cgColor('white'), XRANGE =[4800, 5100]
  ;plot,  specdata.wavelength, specdata.flux, color=cgColor('white'), XRANGE =[6500, 6700]
  ;plot,  specdata.wavelength, specdata.flux, color=cgColor('white')
  ;oplot, specsynth_best.wavelength, specsynth_best.flux, color=cgColor('red')
  ;oplot,  continuum.wavelength, continuum.flux, color=cgColor('blue')
  emissionlines.flux= emissionlines.peak*emissionlines.sigma1*sqrt(2*!dpi)
  
  set_plot, 'x'
  plot, specdata.wavelength, specdata.flux, color=cgColor('white')
  oplot, specsynth_best.wavelength, specsynth_best.flux, color=cgColor('red')

  if keyword_set(printimage) eq 1 and keyword_set(imagename) eq 1 then begin 
    set_plot,'ps'
    filename=imagename
    
    device, /color, bits_per_pixeL=8, font_size=7, $
         filename=filename, $
         encapsulated=1, helvetica=1, bold=1, book=1, $
         xsize=7.0, ysize=2.391, inches=1
    loadct,13
    
    plot, specdata.wavelength, specdata.flux, color=cgColor('black'), $
         XTITLE=textoidl('\lambda (!6!sA!r!u!9 %!6 !n)'), $
         YTITLE=textoidl('F_{\lambda} (10^{-15} erg cm^{-2} s^{-1} !6!sA!r!u!9 %!6 !n^{-1})'), $
         ;XRANGE =[3600, 4400], YRANGE=[0.0, 10.0], $
         position=[0.08, 0.10, 0.97, 0.95], $  ; with scale
         XTICKLEN=0.01, YTICKLEN=0.01, $
         XStyle=1, YStyle=1 ;/nodata , Thick=0.5, 
         
    oplot, specsynth_best.wavelength, specsynth_best.flux, color=cgColor('red')
    
    device, /close
    
    set_plot, 'x'
  endif
  return, emissionlines
end
