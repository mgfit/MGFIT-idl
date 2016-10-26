function mgfit_emis, specdata, redshift_initial, resolution_initial, emissionlines, redshift_tolerance1, resolution_tolerance1, generations, popsize, pressure
;+
; NAME:
;     mgfit_emis
; PURPOSE:
;     fit multiple Gaussian functions to a list of emission lines using 
;     a least-squares minimization technique and a genetic-type random walk
;     method. It uses the MPFIT idl library to initialize the parameters of
;     the run in the first iteration. The continuum curve is determined 
;     using mgfit_contin() and subtracted before the line identification 
;     and flux measurements. It uses mgfit_emis_err() to estimate the 
;     uncertainties itroduced by the best-fit model residuals and 
;     the white noise. 
; EXPLANATION:
;
; CALLING SEQUENCE:
;     fittedlines = mgfit_emis(stronglines, redshift_initial, resolution_initial, 
;                              emissionlines, redshift_tolerance, 
;                              resolution_tolerance, generations, 
;                              popsize, pressure)
;
; INPUTS:
;     specdata - the observed spectrum
;          array with the following structure
;          { wavelength: 0.0, 
;            flux:0.0, 
;            residual:0.0}
;     redshift_initial  - the initial/guess redshift
;     resolution_initial - the initial/guess spectral resolution
;     emissionlines - the specified emission lines
;          array with the following structure
;          { wavelength: 0.0, 
;            peak:0.0, 
;            sigma1:0.0, 
;            flux:0.0, 
;            uncertainty:0.0, 
;            redshift:0.0, 
;            resolution:0.0, 
;            blended:0, Ion:'', 
;            Multiplet:'', 
;            LowerTerm:'', 
;            UpperTerm:'', 
;            g1:'', 
;            g2:''}
;     redshift_tolerance - the redshift tolerance
;     resolution_tolerance - the spectral resolution tolerance
;     generations - the maximum generation number in the genetic algorithm
;     popsize - the population size in each generation in the genetic algorithm
;     pressure - the value of the selective pressure in the genetic algorithm
; 
; RETURN:  fitted emission lines
;          array with the following structure
;          { wavelength: 0.0, 
;            peak:0.0, 
;            sigma1:0.0, 
;            flux:0.0, 
;            uncertainty:0.0, 
;            redshift:0.0, 
;            resolution:0.0, 
;            blended:0, Ion:'', 
;            Multiplet:'', 
;            LowerTerm:'', 
;            UpperTerm:'', 
;            g1:'', 
;            g2:''}
;
; REVISION HISTORY:
;     Algorithm inherited from ALFA written in FORTRAN by R. Wessson
;     Translated to IDL code by A. Danehkar, 20/07/2014
;     Several performance optimized, A. Danehkar, 22/07/2015
;     Degree and variance added to chi_squared, A. Danehkar, 12/11/2015
;     Continuum subtracted before fitting, A. Danehkar, 15/02/2016
;     Uncertainties estimation added, A. Danehkar, 22/02/2016
;     Fixed small bugs, A. Danehkar, 15/10/2016
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
  if (max(specdata.flux) lt 0.01) then begin
    specscale = 1./max(specdata.flux)
  end
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
  specdata[negetive_loc].flux=0.0
  for i=0, nlines-1 do begin
      linelocation0 = where(specdata.wavelength gt redshift_initial*emissionlines[i].wavelength)
      linelocation=min(linelocation0)
      if linelocation-25 ge 0 and linelocation+24 le speclength then begin
        lam1 = specdata[linelocation-25:linelocation+24].wavelength
        spec1 = specdata[linelocation-25:linelocation+24].flux
      endif else begin
        if linelocation-25 lt 0  then begin
          lam1 = specdata[0:linelocation+24].wavelength
          spec1 = specdata[0:linelocation+24].flux
        endif
        if linelocation+24 gt speclength then begin
          lam1= specdata[linelocation-25:speclength-1].wavelength
          spec1 = specdata[linelocation-25:speclength-1].flux
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
      if peak1 le 0 then begin
        peak1=0
        centroid1=emissionlines[i].wavelength
        sigma1=(emissionlines[i].wavelength/resolution_initial)
      endif
      if a[0] ne 0 then begin
        emissionlines[i].peak=peak1
        emissionlines[i].sigma1=sigma1
        emissionlines[i].resolution=emissionlines[i].wavelength/emissionlines[i].sigma1
        emissionlines[i].redshift=centroid1/emissionlines[i].wavelength
      end
  endfor
  for i=0, popsize-1 do begin 
    specsynth[*,i].wavelength=specdata.wavelength
    resolution_initial=emissionlines[0].wavelength/emissionlines[0].sigma1
    if nlines gt 1 then begin
      population[i,*].wavelength = transpose(emissionlines.wavelength)
      population[i,*].peak=transpose(emissionlines.peak)
      population[i,*].resolution=resolution_initial
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
      population[i,*].resolution=resolution_initial
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
    endfor
    for popnumber=1,popsize-1 do begin
      population[popnumber,*].resolution = population[popnumber,*].resolution * mgfit_mutation1()
      if (abs(population[popnumber,0].resolution-resolution_initial) gt resolution_tolerance1) then begin
        population[popnumber,*].resolution = resolution_initial
      endif
      population[popnumber,*].redshift = population[popnumber,*].redshift + ((mgfit_mutation1()-1.)*redshift_tolerance1)
      if (abs(population[popnumber,0].redshift-redshift_initial) gt redshift_tolerance1) then begin
        population[popnumber,*].redshift = redshift_initial
      endif
      for lineid=0,nlines -1   do begin
        population[popnumber,lineid].peak = population[popnumber,lineid].peak * mgfit_mutation1()
      endfor
    endfor
    print, "Percentage:", double(gencount+1)/double(generations)*100.0
  endfor
  chi_squared_min_loc=minloc_idl(chi_squared,first=1)
  specsynth_best=specsynth[*,chi_squared_min_loc]
  emissionlines=population[chi_squared_min_loc,*];
  ; estimate uncertainties
  emissionlines=mgfit_emis_err(specsynth_best, specdata, emissionlines)  
  emissionlines.sigma1=emissionlines.wavelength/emissionlines.resolution
  emissionlines.peak = emissionlines.peak / specscale
  emissionlines.uncertainty = emissionlines.uncertainty / specscale
  ;plot,  specdata.wavelength, specdata.flux, color=cgColor('white'), XRANGE =[4420, 7060]
  ;plot,  specdata.wavelength, specdata.flux, color=cgColor('white'), XRANGE =[4800, 5100]
  ;plot,  specdata.wavelength, specdata.flux, color=cgColor('white'), XRANGE =[6500, 6700]
  ;oplot, specsynth_best.wavelength, specsynth_best.flux, color=cgColor('red')
  ;oplot,  continuum.wavelength, continuum.flux, color=cgColor('blue')
  emissionlines.flux= emissionlines.peak*emissionlines.sigma1*sqrt(2*!dpi)
  
  return, emissionlines
end
