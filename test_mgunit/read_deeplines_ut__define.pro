; docformat = 'rst'

function read_deeplines_ut::test_basic
  compile_opt strictarr
  
  base_dir = file_dirname(file_dirname((routine_info('read_deeplines_ut__define', /source)).path))
  data_dir = ['data']
  
  fits_file = filepath('linedata.fits', root_dir=base_dir, subdir=data_dir )
  
  deepline_data=read_deeplines(fits_file)
  
  temp=size(deepline_data,/DIMENSIONS)
  result=temp[0]

  assert, result eq 679, 'incorrect result: %d', result
  
  return, 1
end

pro read_deeplines_ut__define
  compile_opt strictarr
  
  define = { read_deeplines_ut, inherits mgfitUTTestCase}
end
