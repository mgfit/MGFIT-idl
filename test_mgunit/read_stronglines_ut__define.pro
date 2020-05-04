; docformat = 'rst'

function read_stronglines_ut::test_basic
  compile_opt strictarr
  
  base_dir = file_dirname(file_dirname((routine_info('read_stronglines_ut__define', /source)).path))
  data_dir = ['data']
  
  fits_file = filepath('linedata.fits', root_dir=base_dir, subdir=data_dir )
  
  strongline_data=read_stronglines(fits_file)
  
  temp=size(strongline_data,/DIMENSIONS)
  result=temp[0]

  assert, result eq 15, 'incorrect result: %d', result
  
  return, 1
end

pro read_stronglines_ut__define
  compile_opt strictarr
  
  define = { read_stronglines_ut, inherits mgfitUTTestCase}
end
