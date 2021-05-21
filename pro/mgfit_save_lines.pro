; docformat = 'rst'

pro mgfit_save_lines, emissionlines, filename, $
                      hb_ha_flux_ratio=hb_ha_flux_ratio, $
                      ha_hb_flux_ratio=ha_hb_flux_ratio, $
                      wavelength_shift=wavelength_shift, $
                      sum_errors=sum_errors, median_errors=median_errors
;+
;     This function save detected lines.
;
; :Keywords:
;     hb_ha_flux_ratio  :     in, optional, type=float   
;                             H-beta over H-alpha flux ratio
; 
;     ha_hb_flux_ratio  :     in, optional, type=boolean
;                             H-alpha over H-beta flux ratio
; 
;     wavelength_shift  :     in, optional, type=boolean
;                             shift wavelengths
; 
; :Params:
;     lines  :      in, required, type=arrays of structures
;                   the line list stored in
;                   the arrays of structures
;                   { wavelength: 0.0,
;                     peak:0.0,
;                     sigma1:0.0,
;                     flux:0.0,
;                     continuum:0.0,
;                     uncertainty:0.0,
;                     pcerror:0.0
;                     redshift:0.0,
;                     resolution:0.0,
;                     blended:0,
;                     Ion:'',
;                     Multiplet:'',
;                     LowerTerm:'',
;                     UpperTerm:'',
;                     g1:'',
;                     g2:''}
;     
;     filename:     in, required, type=string
;                   the file name for writing the lines.
;
; :Examples:
;    For example::
;
;     IDL> mgfit_save_lines, emissionlines, filename
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
;     14/05/2020, A. Danehkar, Create function.
;-
  temp=size(emissionlines,/DIMENSIONS)
  nlines=temp[0]
  outtext_filename_red=filename+'_red.txt'
  outtext_filename_unfilter=filename+'_unfilter.txt'
  outtext_filename_raw=filename+'_raw.txt'
  openw, lun4, outtext_filename_red, /GET_LUN
  openw, lun5, outtext_filename_unfilter, /GET_LUN
  openw, lun6, outtext_filename_raw, /GET_LUN
  if keyword_set(hb_ha_flux_ratio) eq 0 and keyword_set(ha_hb_flux_ratio) eq 0 then begin
    flux_halpha_loc = where(emissionlines.wavelength eq 6562.77)
    flux_halpha = emissionlines[flux_halpha_loc].flux
    flux_halpha_err = emissionlines[flux_halpha_loc].uncertainty
    flux_halpha_pcerror = emissionlines[flux_halpha_loc].pcerror
    flux_halpha_redhsift = emissionlines[flux_halpha_loc].redshift
    
    flux_hbeta_loc = where(emissionlines.wavelength eq 4861.33)
    flux_hbeta = emissionlines[flux_hbeta_loc].flux
    flux_hbeta_err = emissionlines[flux_hbeta_loc].uncertainty
    flux_hbeta_pcerror = emissionlines[flux_hbeta_loc].pcerror
    flux_hbeta_redhsift = emissionlines[flux_halpha_loc].redshift
  endif else begin
    if keyword_set(ha_hb_flux_ratio) eq 0 then begin
      flux_halpha_loc = where(emissionlines.wavelength eq 6562.77)
      flux_halpha = emissionlines[flux_halpha_loc].flux
      flux_halpha_err = emissionlines[flux_halpha_loc].uncertainty
      flux_halpha_pcerror = emissionlines[flux_halpha_loc].pcerror
      flux_halpha_redhsift = emissionlines[flux_halpha_loc].redshift
      
      flux_hbeta = flux_halpha*hb_ha_flux_ratio
      flux_hbeta_err = flux_halpha_err
      flux_hbeta_redhsift=flux_halpha_redhsift
    endif else begin
      flux_hbeta_loc = where(emissionlines.wavelength eq 4861.33)
      flux_hbeta = emissionlines[flux_hbeta_loc].flux
      flux_hbeta_err = emissionlines[flux_hbeta_loc].uncertainty
      flux_hbeta_pcerror = emissionlines[flux_hbeta_loc].pcerror
      flux_hbeta_redhsift = emissionlines[flux_hbeta_loc].redshift
      
      flux_halpha = flux_hbeta*ha_hb_flux_ratio 
      flux_halpha_err = flux_hbeta_err
      flux_halpha_redhsift = flux_hbeta_redhsift
    endelse
  endelse
  if keyword_set(wavelength_shift) eq 0 then wave_shift=0 else wave_shift=wavelength_shift
  flux_redhsift = (flux_hbeta_redhsift + flux_halpha_redhsift)/2.0
  for i=0, nlines-1 do begin
    if emissionlines[i].flux ne 0 then begin
      IonName1=strtrim(emissionlines[i].Ion,2)
      temp=strsplit(IonName1, ' ', /extract)
      temp0=temp[0]
      n1=strpos(temp[1], ']', /reverse_search)
      if n1 ne -1 then begin
        temp1=strsplit(temp[1],']', /extract)
        temp1=strlowcase(temp1)
        temp1='~{\sc '+temp1+'}]'
      endif else begin
        temp1=temp[1]
        temp1=strlowcase(temp1)
        temp1='~{\sc '+temp1+'}'
      endelse
      IonName=temp0+temp1
      if flux_hbeta ne 0 and flux_halpha ne 0 then begin
        ;flux_abs=emissionlines[i].flux
        uncertainty_redden=emissionlines[i].uncertainty / emissionlines[i].flux * 100.0
        pcerror_redden=emissionlines[i].pcerror * 100.0
        flux=emissionlines[i].flux / flux_hbeta * 100.0
        flux_err=emissionlines[i].uncertainty / flux_hbeta * 100.0
        redhsift0=emissionlines[i].redshift
      endif else begin
        flux=emissionlines[i].flux
        uncertainty_redden=emissionlines[i].uncertainty/flux * 100.0
        pcerror_redden=emissionlines[i].pcerror * 100.0
        flux_deredden=emissionlines[i].flux
        redhsift0=emissionlines[i].redshift
      endelse
      if keyword_set(median_errors) eq 1 then begin
        error_avg=median([uncertainty_redden, pcerror_redden])
      endif else begin
        if keyword_set(sum_errors) eq 1 then begin
          error_avg=total([uncertainty_redden, pcerror_redden])
        endif else begin
          error_avg=mean([uncertainty_redden, pcerror_redden])
        endelse
      endelse
      if uncertainty_redden le 200.0 and redhsift0 gt flux_redhsift-0.0002 and redhsift0 lt flux_redhsift+0.0002 then begin
        printf, lun4, format='(F10.2," ",F10.3," ",F10.1," ",F10.1," ",F10.1," ",F10.6)', $
              emissionlines[i].wavelength, flux, $
              error_avg, uncertainty_redden, pcerror_redden, $
              emissionlines[i].redshift+wave_shift/emissionlines[i].wavelength
        printf, lun6, format='(F10.2," ",E10.3," ",E10.3," ",E10.3," ",F10.6," ",E10.3)', $
              emissionlines[i].wavelength, emissionlines[i].flux, emissionlines[i].uncertainty, emissionlines[i].pcerror, $
              emissionlines[i].redshift, emissionlines[i].continuum
      endif
      printf, lun5, format='(F10.2," ",F10.3," ",F10.1," ",F10.1," ",F10.1," ",F10.6)', $
            emissionlines[i].wavelength, flux, $
            error_avg, uncertainty_redden, pcerror_redden, $
            emissionlines[i].redshift+wave_shift/emissionlines[i].wavelength
    endif
  endfor
  free_lun, lun4
  free_lun, lun5
  free_lun, lun6
end

