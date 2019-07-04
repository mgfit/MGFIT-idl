;+
; Builds the mgfit sav file.
;-

; clear any other compilations
.reset

; compile required code

@mgfit_compile_all

; create the sav file
save, filename='mgfit.sav', /routines, description='MGFIT-idl ' + mgfit_version(/full)

exit
