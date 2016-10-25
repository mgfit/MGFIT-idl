# MGFIT line data

The line data FITS file (linedata.fits) was created from the line lists used in the Fortran program 
ALFA (Automated Line Fitting Algorithm) by [Wesson (2016)](http://adsabs.harvard.edu/abs/2016MNRAS.456.3774W). 
The Flexible Image Transport System (FITS) format is based on  the definition of 
[Hanisch et al. (2001)](http://adsabs.harvard.edu/abs/2001A%26A...376..359H).

The line data FITS file contains the following binary table extensions:

* **Strong Lines**: the lines are used to estimate the systemic velocity and spectral resolution.
* **Deap Lines**: the lines are typically used for plasma diagnostics and abundance analysis. 
* **Clean Deep Lines**: some lines which add problems and uncertainties are excluded from the deep lines.
* **Ultra Deep Lines**: the list of all possible lines for an ultra deep line exploration.
* **Sky Lines**: the list of all possible sky lines for the sky subtraction purpose. 
