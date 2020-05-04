; docformat = 'rst'

function read_ultradeeplines_ut::test_basic
  compile_opt strictarr
  
  base_dir = file_dirname(file_dirname((routine_info('read_ultradeeplines_ut__define', /source)).path))
  data_dir = ['data']
  
  fits_file = filepath('linedata.fits', root_dir=base_dir, subdir=data_dir )
  
  ultradeepline_data=read_ultradeeplines(fits_file)
  
  temp=size(ultradeepline_data,/DIMENSIONS)
  result=temp[0]

  assert, result eq 1655, 'incorrect result: %d', result
  
  return, 1
end

pro read_ultradeeplines_ut__define
  compile_opt strictarr
  
  define = { read_ultradeeplines_ut, inherits mgfitUTTestCase}
end
