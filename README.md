# MGFIT (IDL version)
[![GitHub license](https://img.shields.io/aur/license/yaourt.svg)](https://github.com/mgfit/mgfit-idl/blob/master/LICENSE)

**MGFIT** - IDL/GDL Library for Least-Squares Minimization Genetic Algorithm Fitting

### Description
The **MGFIT** is an [Interactive Data Language](http://www.harrisgeospatial.com/ProductsandSolutions/GeospatialProducts/IDL.aspx) (IDL)/[GNU Data Language](http://gnudatalanguage.sourceforge.net/) (GDL) Library developed to fit multiple Gaussian functions to a list of emission (or absorption) lines using a least-squares minimization technique and a random walk method in three-dimensional locations of the specified lines, namely line peak, line width, and wavelength shift. It uses the [MPFIT](http://cow.physics.wisc.edu/~craigm/idl/cmpfit.html) IDL Library ([MINPACK-1 Least Squares Fitting](http://adsabs.harvard.edu/abs/2012ascl.soft08019M); [Markwardt 2009](http://adsabs.harvard.edu/abs/2009ASPC..411..251M)), which performs Levenberg-Marquardt least-squares minimization, to estimate the seed values required for initializing the three-dimensional coordination of each line in the first iteration. It then uses a random walk method optimized using a genetic algorithm originally evolved from the early version of the Fortran program [ALFA](http://adsabs.harvard.edu/abs/2015ascl.soft12005W) ([Automated Line Fitting Algorithm](https://github.com/rwesson/ALFA); [Wesson 2016](http://adsabs.harvard.edu/abs/2016MNRAS.456.3774W)) to determine the best fitting values of the specified lines. The continuum curve is determined and subtracted before the line identification and flux measurements. It quantifies the white noise of the spectrum, which is then utilized to estimate uncertainties of fitted lines using the signal-dependent noise model of least-squares Gaussian fitting ([Lenz & Ayres 1992](http://adsabs.harvard.edu/abs/1992PASP..104.1104L)) built on the work of [Landman, Roussel-Dupre, and Tanigawa (1982)](http://adsabs.harvard.edu/abs/1982ApJ...261..732L).

Website: [physics.mq.edu.au/~ashkbiz/mgfit](https://physics.mq.edu.au/~ashkbiz/mgfit/)
