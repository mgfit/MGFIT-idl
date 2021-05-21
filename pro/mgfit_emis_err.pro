; docformat = 'rst'

function mgfit_emis_err, syntheticspec, spectrumdata, emissionlines, redshift, $
                         rebin_resolution=rebin_resolution
;+
;     This function estimates the uncertainties introduced by the best-fit 
;     model residuals and the white noise quantified using the signal-dependent 
;     noise model of least-squares Gaussian fitting (Lenz & Ayres 1992; 
;     1992PASP..104.1104L) based on on the work of Landman, Roussel-Dupre, 
;     and Tanigawa (1982; 1982ApJ...261..732L).
;
; :Returns:
;    type=arrays of structures. This function returns the arrays of structures 
;                              { wavelength: 0.0, peak:0.0, sigma1:0.0, flux:0.0, 
;                                uncertainty:0.0, pcerror:0.0, redshift:0.0,
;                                resolution:0.0, blended:0, Ion:'', Multiplet:'', 
;                                LowerTerm:'', UpperTerm:'', g1:'', g2:''}
;
; :Keywords:
;     rebin_resolution     :    in, optional, type=float
;                               increase the spectrum resolution by rebinning
;                               resolution by rebin_resolution times
;
; :Params:
;     syntheticspec :     in, required, type=arrays of structures
;                         the synthetic spectrum made by mgfit_synth_spec() 
;                         stored in the arrays of structures {wavelength: 0.0, flux:0.0, residual:0.0}
;     
;     spectrumdata  :     in, required, type=arrays of structures
;                         the observed spectrum stored in the arrays 
;                         of structures {wavelength: 0.0, flux:0.0, residual:0.0}
;     
;     emissionlines :     in, required, type=arrays of structures    
;                         the emission lines specified for error estimation 
;                         stored in the arrays of structures 
;                         { wavelength: 0.0, 
;                           peak:0.0, 
;                           sigma1:0.0, 
;                           flux:0.0, 
;                           uncertainty:0.0, 
;                           pcerror:0.0,
;                           redshift:0.0, 
;                           resolution:0.0, 
;                           blended:0, 
;                           Ion:'', 
;                           Multiplet:'', 
;                           LowerTerm:'', 
;                           UpperTerm:'', 
;                           g1:'', 
;                           g2:''}
;
; :Examples:
;    For example::
;
;     IDL> emissionlines_section=mgfit_emis_err(syntheticspec_section, spec_section, emissionlines_section)
;
; :Categories:
;   Emission, Uncertainty
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
;     12/04/2015, A. Danehkar, Performance optimized for IDL.
;     
;     20/08/2016, A. Danehkar, Added better performance in noise estimation.
;     
;     22/10/2016, A. Danehkar,  Fixed small bugs.
;     
;     22/02/2016, A. Danehkar, Uncertainties estimation added.
;     
;     15/10/2016, A. Danehkar, Fixed small bugs.
;     
;     21/06/2017, A. Danehkar, Some modifications.
;-
  temp=size(spectrumdata,/DIMENSIONS)
  speclength=temp[0]
  residuals = dblarr(speclength)
  
  ;continuum=mgfit_contin(spectrumdata)
  ;spectrumdata.flux=spectrumdata.flux-continuum.flux
  ;negetive_loc=where(spectrumdata.flux lt 0.0)
  ;spectrumdata[negetive_loc].flux=0.0
  
  residuals=spectrumdata.flux-syntheticspec.flux
  
  strong_line=min(where(emissionlines.peak eq max(emissionlines.peak))) 
  resolution_initial=emissionlines[strong_line].resolution
  
  sigma1=redshift*emissionlines[strong_line].wavelength/resolution_initial
  fwhm=2*sqrt(2*alog(2))*emissionlines[strong_line].sigma1

  w_helf=2*sqrt(2*alog(2))
  profile_loc=where(spectrumdata.wavelength ge (redshift*emissionlines[strong_line].wavelength-w_helf*fwhm) and spectrumdata.wavelength le (redshift*emissionlines[strong_line].wavelength+w_helf*fwhm) )
  if profile_loc[0] eq -1 then begin
    return, emissionlines ; cannot find lines!
  endif
  temp=size(profile_loc,/DIMENSIONS)
  residuals_num=temp[0]
  residuals_num1=long(residuals_num/2)
  residuals_num=2*residuals_num1
  residuals_num2=long(3./4.*residuals_num)
  
  if residuals_num lt speclength then begin
    for i=residuals_num1,speclength-residuals_num1-1 do begin
      residuals_select=abs(residuals[i-residuals_num1:i+residuals_num1-1])
      residuals_sort=sort(residuals_select)
      residuals_select=residuals_select[residuals_sort]
      rms_noise=(total(residuals_select[0:residuals_num2-1]^2)/double(residuals_num2))^0.5
      spectrumdata[i].residual=rms_noise
    endfor
    spectrumdata[0:residuals_num1-1].residual=spectrumdata[residuals_num1].residual
    temp=size(spectrumdata.residual,/DIMENSIONS)
    residual_size=temp[0]
    spectrumdata[residual_size-residuals_num1-1:residual_size-1].residual=spectrumdata[residual_size-residuals_num1-2].residual
  endif else begin
    residuals_select=abs(residuals[0:speclength-1])
    residuals_sort=sort(residuals_select)
    residuals_select=residuals_select[residuals_sort]
    rms_noise=(total(residuals_select[0:speclength-1]^2)/double(speclength))^0.5
    spectrumdata[*].residual=rms_noise
    temp=size(spectrumdata.residual,/DIMENSIONS)
    residual_size=temp[0]
    spectrumdata[residual_size-residuals_num-1:residual_size-1].residual=spectrumdata[residual_size-residuals_num-2].residual
  endelse
  
  ;spectrumdata[residual_size-residuals_num-1:residual_size-1].residual=spectrumdata[residual_size-residuals_num-0].residual
  
  temp=size(emissionlines,/DIMENSIONS)
  if size(temp,/DIMENSIONS) gt 1 then begin
    fit_uncertainty_size=temp[1]
  endif else begin
    fit_uncertainty_size=temp[0]
  endelse
  
  for i=0,fit_uncertainty_size-1 do begin
    waveindex=minloc_idl(abs(spectrumdata.wavelength-redshift*emissionlines[i].wavelength),first=1)
    ;temp=size(spectrumdata.wavelength,/DIMENSIONS)
    ;size1=temp[0]
    ;if waveindex ge size1 then waveindex=size1-1
    ;if (spectrumdata[waveindex].residual ne 0.0) then begin
    if (emissionlines[i].peak ne 0.0) and (emissionlines[i].resolution ne 0.0) then begin
      ; Equation (1) in Lenz & Ayres 1992PASP..104.1104L 
      ; (1) Fourier Transform Spectrometer (FTS)
      ; (2) Hubble Space Telescope (HST)
      ; (3) International Ultraviolet Explorer (IUE)
      C_x= 0.67 ; C_x(FTS)=0.70, C_x(HST)=0.63, C_x(IUE)=0.64, C_x(all)=0.67
      emissionlines[i].sigma1=redshift*emissionlines[i].wavelength/emissionlines[i].resolution
      fwhm=2*sqrt(2*alog(2))*emissionlines[i].sigma1
      rms_noise=spectrumdata[waveindex].residual
      if keyword_set(rebin_resolution) eq 1 then begin
        delta_wavelength=double(rebin_resolution)*abs(spectrumdata[waveindex].wavelength - spectrumdata[waveindex-1].wavelength)
      endif else begin
        delta_wavelength=abs(spectrumdata[waveindex].wavelength - spectrumdata[waveindex-1].wavelength)
      endelse
      peak_snr=emissionlines[i].peak/rms_noise
      line_snr=C_x*(fwhm/delta_wavelength)^0.5*peak_snr
      if line_snr ne 0 then begin
        emissionlines[i].flux= emissionlines[i].peak*emissionlines[i].sigma1*sqrt(2.*!dpi)
        emissionlines[i].uncertainty=emissionlines[i].flux/line_snr
      endif else begin
        emissionlines[i].uncertainty=0.0
      endelse
      if emissionlines[i].peak ne 0 and emissionlines[i].sigma1 ne 0 then begin
        linelocation0 = where(spectrumdata.wavelength gt emissionlines[i].redshift*emissionlines[i].wavelength)
        linelocation=min(linelocation0)
        resolution0=abs(spectrumdata[linelocation].wavelength - spectrumdata[linelocation-1].wavelength)
        linelocation0_step_h=long(2.*2.355*emissionlines[i].sigma1/resolution0)
        if linelocation-linelocation0_step_h ge 0 and linelocation+linelocation0_step_h-1 lt speclength then begin
          lam1 = spectrumdata[linelocation-linelocation0_step_h:linelocation+linelocation0_step_h-1].wavelength
          spec1 = spectrumdata[linelocation-linelocation0_step_h:linelocation+linelocation0_step_h-1].flux
          ;cont1= mean(continuum[linelocation-linelocation0_step_h:linelocation+linelocation0_step_h-1].flux)
          res1 = spectrumdata[linelocation-linelocation0_step_h:linelocation+linelocation0_step_h-1].residual
        endif else begin
          if linelocation-linelocation0_step_h lt 0 and linelocation+linelocation0_step_h-1 ge speclength then begin
            lam1 = spectrumdata[0:speclength-1].wavelength
            spec1 = spectrumdata[0:speclength-1].flux
            ;cont1= mean(continuum[0:linelocation+linelocation0_step_h-1].flux)
            res1 = spectrumdata[0:speclength-1].residual
          endif else begin
            if linelocation-linelocation0_step_h lt 0 then begin
              lam1 = spectrumdata[0:linelocation+linelocation0_step_h-1].wavelength
              spec1 = spectrumdata[0:linelocation+linelocation0_step_h-1].flux
              ;cont1= mean(continuum[0:linelocation+linelocation0_step_h-1].flux)
              res1 = spectrumdata[0:linelocation+linelocation0_step_h-1].residual
            endif
            if linelocation+linelocation0_step_h-1 ge speclength then begin
              lam1= spectrumdata[linelocation-linelocation0_step_h:speclength-1].wavelength
              spec1 = spectrumdata[linelocation-linelocation0_step_h:speclength-1].flux
              ;cont1= mean(continuum[linelocation-linelocation0_step_h:speclength-1].flux)
              res1 = spectrumdata[linelocation-linelocation0_step_h:speclength-1].residual
            endif
          endelse
        endelse
        peak1=emissionlines[i].peak
        sigma1=emissionlines[i].sigma1
        centroid1=emissionlines[i].redshift*emissionlines[i].wavelength
        estimates=[peak1, centroid1, sigma1]
        ;a[0]=peak1
        ;a[1]=centroid1
        ;a[2]=sigma1
        error=res1
        yfit = mpfitpeak(lam1, spec1, a, perror=perror, $
                         ESTIMATES=estimates, BESTNORM=bestnorm, $
                         ERROR=error, DOF=dof, /POSITIVE, /GAUSSIAN)
        pcerror = perror * sqrt(bestnorm / dof) ;  estimated scaled uncertainties from measured 1-sigma uncertainties
        flux_perror=sqrt((perror[0]/a[0])^2.+(perror[2]/a[2])^2.)
        flux_pcerror=sqrt((pcerror[0]/a[0])^2.+(pcerror[2]/a[2])^2.) ; estimated flux uncertainty from 1-sigma uncertainties
        emissionlines[i].pcerror=flux_pcerror
      endif
    endif else begin
      emissionlines[i].uncertainty=0.0
    endelse
  endfor
  return, emissionlines
end
