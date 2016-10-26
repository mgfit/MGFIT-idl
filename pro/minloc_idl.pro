function minloc_idl, inarr, first=first, last=last
;+
; NAME:
;     minloc_idl
; PURPOSE:
;     Determines the location of the element in the array 
;     with the minimum value
; EXPLANATION:
;
; CALLING SEQUENCE:
;     chi_squared = [5, 7, 1, 3, 6, 1]
;     chi_squared_min_loc=minloc_idl(chi_squared,first=1)
;     print, chi_squared_min_loc
;
; INPUTS:
;     inarr - an array of type INTEGER or REAL. 
;     first - set to return the location of the first value
;     last -  set to return the location of the last value
; RETURN:  Location of the minimum value within an array:
;          the location of the first value if first=1, 
;          the location of last value if last=1.
;- 
  dum=where(inarr eq min(inarr),ndum)  &  mud=dum
  if keyword_set(first) then mud=dum(0)
  if keyword_set(last) then mud=dum(ndum-1)
  if keyword_set(first) and keyword_set(last) then begin
     mud=[dum(0),dum(ndum-1)]  &  if mud(0) eq mud(1) then mud=mud(0)
  endif
  return,mud
end
