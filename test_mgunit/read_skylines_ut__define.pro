; docformat = 'rst'

function read_skylines_ut::test_basic
  compile_opt strictarr
  
  base_dir = file_dirname(file_dirname((routine_info('read_skylines_ut__define', /source)).path))
  data_dir = ['data']
  
  fits_file = filepath('linedata.fits', root_dir=base_dir, subdir=data_dir )
  
  skyline_data=read_skylines(fits_file)
  
  temp=size(skyline_data,/DIMENSIONS)
  result=temp[0]

  assert, result eq 438, 'incorrect result: %d', result
  
  return, 1
end

pro read_skylines_ut__define
  compile_opt strictarr
  
  define = { read_skylines_ut, inherits mgfitUTTestCase}
end
