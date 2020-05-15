; --- Begin $MAIN$ program. ---------------
; 
; 

mgunit, ['mgfit_contin_ut','mgfit_whitenoise_ut','mgfit_init_spec_ut','mgfit_init_emis_ut',$
         'mgfit_emis_ut','mgfit_init_fltr_emis_ut','mgfit_synth_spec_ut','mgfit_emis_err_ut',$
         'read_stronglines_ut','read_deeplines_ut','read_ultradeeplines_ut','read_skylines_ut', $
         'mgfit_detect_lines_ut','mgfit_detect_strong_lines_ut','mgfit_detect_deep_lines_ut'], $
        filename='test-results.log'

mgunit, ['mgfit_contin_ut','mgfit_whitenoise_ut','mgfit_init_spec_ut','mgfit_init_emis_ut',$
         'mgfit_emis_ut','mgfit_init_fltr_emis_ut','mgfit_synth_spec_ut','mgfit_emis_err_ut',$
         'read_stronglines_ut','read_deeplines_ut','read_ultradeeplines_ut','read_skylines_ut', $
         'mgfit_detect_lines_ut','mgfit_detect_strong_lines_ut','mgfit_detect_deep_lines_ut'], $
        filename='test-results.html', /html

; --- End $MAIN$ program. ---------------
exit
