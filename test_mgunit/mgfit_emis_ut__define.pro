; docformat = 'rst'

function mgfit_emis_ut::test_basic
  compile_opt strictarr
  
  base_dir = file_dirname(file_dirname((routine_info('mgfit_emis_ut__define', /source)).path))
  data_dir = ['data']
  output_dir = ['test_mgunit']
  image_dir = ['test_mgunit']

  fits_file = filepath('linedata.fits', root_dir=base_dir, subdir=data_dir )
  output_path = filepath('', root_dir=base_dir, subdir=output_dir )
  image_output_path = filepath('', root_dir=base_dir, subdir=image_dir )
  
  strongline_data=read_stronglines(fits_file)
  deepline_data=read_deeplines(fits_file)

  wavel = [5000.2486,5000.6049,5000.9612,5001.3174,5001.6737,5002.0300,5002.3863,5002.7425,5003.0988,5003.4551,$
           5003.8113,5004.1676,5004.5239,5004.8802,5005.2364,5005.5927,5005.9490,5006.3052,5006.6615,5007.0178,$
           5007.3741,5007.7303,5008.0866,5008.4429,5008.7992,5009.1554,5009.5117,5009.8680,5010.2242,5010.5805,$
           5010.9368,5011.2931,5011.6493,5012.0056,5012.3619,5012.7181,5013.0744,5013.4307,5013.7870,5014.1432]
  
  flux =[3.183313E-15,3.054452E-15,3.087807E-15,3.206507E-15,3.120304E-15,3.457131E-15,3.741686E-15,4.069117E-15,4.376543E-15,4.408498E-15,$
         4.760826E-15,4.925109E-15,5.177085E-15,6.017217E-15,7.389534E-15,1.194054E-14,2.516601E-14,6.637287E-14,3.126801E-13,1.349944E-12,$
         3.563323E-12,5.945202E-12,7.606664E-12,7.662568E-12,6.954537E-12,5.387889E-12,3.704870E-12,8.094462E-13,2.211600E-13,1.950699E-14,$
         9.668120E-15,7.059885E-15,6.072944E-15,4.989528E-15,4.456528E-15,3.943729E-15,3.374629E-15,3.169192E-15,3.053266E-15,2.818097E-15]
  ; genetic algorithm settings
  popsize=30.
  pressure=0.3
  generations=100.
  ; fitting interval setting
  interval_wavelength=500
  ; redshift initial and tolerance
  redshift_initial = 1.0
  redshift_tolerance=0.001
  ; initial FWHM and tolerance
  fwhm_initial=1.0
  fwhm_tolerance=1.4;*fwhm_initial
  fwhm_min=0.1
  fwhm_max=1.8
  temp=size(wavel,/DIMENSIONS)
  speclength=temp[0]
  wavelength_min=wavel[0]
  wavelength_max=wavel[speclength-1]
  rebin_resolution = 10
  temp=size(wavel,/DIMENSIONS)
  speclength=temp[0]
  speclength_new=rebin_resolution*speclength
  wavel_new = interpolate(wavel, (double(speclength)-1.)/(double(speclength_new)-1.) * findgen(speclength_new))
  flux_new = interpolate(flux, (double(speclength)-1.)/(double(speclength_new)-1.) * findgen(speclength_new))
  wavel=wavel_new
  flux=flux_new
  spectrumdata=mgfit_init_spec(wavel, flux)

  emissionlines_section=mgfit_init_fltr_emis(strongline_data, wavelength_min, wavelength_max, redshift_initial)
  emissionlines_section = mgfit_emis(spectrumdata, redshift_initial, fwhm_initial, $
                                     emissionlines_section, redshift_tolerance, fwhm_tolerance, $
                                     fwhm_min, fwhm_max, $
                                     generations, popsize, pressure)
  
  temp=size(emissionlines_section,/DIMENSIONS)
  result=temp[0]

  assert, result eq 1, 'incorrect result: %d', result
  
  return, 1
end

pro mgfit_emis_ut__define
  compile_opt strictarr
  
  define = { mgfit_emis_ut, inherits mgfitUTTestCase}
end
