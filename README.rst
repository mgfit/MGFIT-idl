=========
MGFIT-idl
=========
    
.. image:: https://app.travis-ci.com/mgfit/MGFIT-idl.svg?branch=master
    :target: https://app.travis-ci.com/github/mgfit/MGFIT-idl
    :alt: Build Status

.. image:: https://ci.appveyor.com/api/projects/status/pavs6wccoxtho5xb?svg=true
    :target: https://ci.appveyor.com/project/danehkar/mgfit-idl
    :alt: Build Status

.. image:: http://mybinder.org/badge.svg
    :target: http://mybinder.org/repo/mgfit/mgfit-idl
    :alt: Binder

.. image:: https://img.shields.io/badge/license-GPL-blue.svg
    :target: https://github.com/mgfit/mgfit-idl/blob/master/LICENSE
    :alt: GitHub license
    
.. image:: https://img.shields.io/badge/DOI-10.5281/zenodo.4495916-blue.svg
    :target: https://doi.org/10.5281/zenodo.4495916
    :alt: Zenodo

**MGFIT (IDL version)** - IDL/GDL Library for Least-Squares Minimization Genetic Algorithm Fitting

Description
============

The **MGFIT** is an `Interactive Data Language <http://www.harrisgeospatial.com/ProductsandSolutions/GeospatialProducts/IDL.aspx>`_ (IDL)/`GNU Data Language <http://gnudatalanguage.sourceforge.net/>`_ (GDL) Library developed to fit multiple Gaussian functions to a list of emission (or absorption) lines using a least-squares minimization technique and a random walk method in three-dimensional locations of the specified lines, namely line peak, line width, and wavelength shift. It uses the `MPFIT <http://cow.physics.wisc.edu/~craigm/idl/cmpfit.html>`_ IDL Library (`MINPACK-1 Least Squares Fitting <https://ui.adsabs.harvard.edu/abs/2012ascl.soft08019M/abstract>`_; `Markwardt 2009 <https://ui.adsabs.harvard.edu/abs/2009ASPC..411..251M/abstract>`_), which performs Levenberg-Marquardt least-squares minimization, to estimate the seed values required for initializing the three-dimensional coordination of each line in the first iteration. It then uses a random walk method optimized using a genetic algorithm originally evolved from the early version of the Fortran program `ALFA <https://ui.adsabs.harvard.edu/abs/2015ascl.soft12005W/abstract>`_ (`Automated Line Fitting Algorithm <https://github.com/rwesson/ALFA>`_; `Wesson 2016 <https://ui.adsabs.harvard.edu/abs/2016MNRAS.456.3774W/abstract>`_) to determine the best fitting values of the specified lines. The continuum curve is determined and subtracted before the line identification and flux measurements. It quantifies the white noise of the spectrum, which is then utilized to estimate uncertainties of fitted lines using the signal-dependent noise model of least-squares Gaussian fitting (`Lenz & Ayres 1992 <https://ui.adsabs.harvard.edu/abs/1992PASP..104.1104L/abstract>`_) built on the work of `Landman, Roussel-Dupre, and Tanigawa (1982) <https://ui.adsabs.harvard.edu/abs/1982ApJ...261..732L/abstract>`_.

Installation
============

Dependent IDL Packages
----------------------

* This package requires the following packages:

    - `The IDL Astronomy User's Library <https://idlastro.gsfc.nasa.gov/homepage.html>`_
    
    - `The Coyote IDL Library <https://github.com/idl-coyote/coyote>`_
    
    - `The MPFIT IDL Library <http://cow.physics.wisc.edu/~craigm/idl/idl.html>`_

    - `The TextoIDL Library <http://physics.mnstate.edu/craig/textoidl/>`_
    
* To get this package with all the dependent packages, you can simply use ``git`` command as follows:

    .. code-block::

        git clone --recursive https://github.com/mgfit/MGFIT-idl


Installation in IDL
-------------------

* To install the **MGFIT** IDL library in the Interactive Data Language (IDL), you need to add the path of this package directory to your IDL path. For more information about the path management in IDL, read `the tips for customizing IDL program path <https://www.harrisgeospatial.com/Support/Self-Help-Tools/Help-Articles/Help-Articles-Detail/ArtMID/10220/ArticleID/16156/Quick-tips-for-customizing-your-IDL-program-search-path>`_ provided by Harris Geospatial Solutions or `the IDL library installation note <http://www.idlcoyote.com/code_tips/installcoyote.php>`_ by David Fanning in the Coyote IDL Library. 

* This package requires IDL version 7.1 or later. 


Installation in GDL
-------------------

*  You can install the GNU Data Language (GDL) if you do not have it on your machine:

    - Linux (Fedora):
    
      .. code-block::

        sudo dnf install gdl
    
    - Linux (Ubuntu):
    
      .. code-block::
    
        sudo apt-get install gnudatalanguage
    
    - OS X (`brew <https://brew.sh/>`_):
    
      .. code-block::

        brew tap brewsci/science
        brew install gnudatalanguage

    - OS X (`macports <https://www.macports.org/>`_):
    
      .. code-block::

        sudo port selfupdate
        sudo port upgrade libtool
        sudo port install gnudatalanguage
    
    - Windows: You can use the `GNU Data Language for Win32 <https://sourceforge.net/projects/gnudatalanguage-win32/>`_ (Unofficial Version) or you can compile the `GitHub source <https://github.com/gnudatalanguage/gdl>`_ using Visual Studio 2015 as shown in `appveyor.yml <https://github.com/gnudatalanguage/gdl/blob/master/appveyor.yml>`_.

* To install the **MGFIT** library in GDL, you need to add the path of this package directory to your ``.gdl_startup`` file in your home directory:

  .. code-block::

    !PATH=!PATH + ':/home/MGFIT-idl/pro/'
    !PATH=!PATH + ':/home/MGFIT-idl/externals/astron/pro/'
    !PATH=!PATH + ':/home/MGFIT-idl/externals/coyote/pro/'
    !PATH=!PATH + ':/home/MGFIT-idl/externals/coyote/public/'
    !PATH=!PATH + ':/home/MGFIT-idl/externals/mpfit/'
    !PATH=!PATH + ':/home/MGFIT-idl/externals/textoidl/'
  
  You may also need to set ``GDL_STARTUP`` if you have not done in ``.bashrc`` (bash):
  
  .. code-block::

    export GDL_STARTUP=~/.gdl_startup

  or in ``.tcshrc`` (cshrc):
  
  .. code-block::

    setenv GDL_STARTUP ~/.gdl_startup

* This package requires GDL version 0.9.9 or later.

How to Use
==========

The Documentation of the IDL functions provides in detail in the *API Documentation* (`mgfit.github.io/MGFIT-idl/doc <https://mgfit.github.io/MGFIT-idl/doc>`_). This IDL library fit multiple Gaussian functions to a list of emission lines in the given input spectrum.

You need to load the line list database:

.. code-block:: idl

    base_dir = file_dirname(file_dirname((routine_info('$MAIN$', /source)).path))
    data_dir = ['data']
    fits_file = filepath('linedata.fits', root_dir=base_dir, subdir=data_dir )
    strongline_data=read_stronglines(fits_file)
    deepline_data=read_deeplines(fits_file)

also load your spectrum arrays: wavelength array, and flux array (see `examples <https://github.com/mgfit/MGFIT-idl/tree/master/examples>`_):

.. code-block:: idl

    input_dir = ['examples','inputs']
    input_file = filepath('spectrum.txt', root_dir=base_dir, subdir=input_dir )
    mgfit_read_ascii, input_file, wavel, flux

and define the output paths:

.. code-block:: idl

    output_dir = ['examples','outputs']
    image_dir = ['examples','images']
    image_output_path = filepath('', root_dir=base_dir, subdir=image_dir )
    output_path = filepath('', root_dir=base_dir, subdir=output_dir )

You need to specify the genetic algorithm settings:

.. code-block:: idl

    popsize=30.
    pressure=0.3
    generations=500.

and use the appropriate fitting settings such as the wavelength interval, the redshift, and the spectral FWHM:

.. code-block:: idl

    interval_wavelength=500
    redshift_initial = 1.0
    redshift_tolerance=0.001
    fwhm_initial=1.0
    fwhm_tolerance=1.4
    fwhm_min=0.1
    fwhm_max=1.8

Now you run the MGFIT main function as follows:

.. code-block:: idl

    emissionlines = mgfit_detect_lines(wavel, flux, deepline_data, strongline_data, $
                                       popsize=popsize, pressure=pressure, $
                                       generations=generations, $
                                       interval_wavelength=interval_wavelength, $
                                       redshift_initial=redshift_initial, $
                                       redshift_tolerance=redshift_tolerance, $
                                       fwhm_initial=fwhm_initial, $
                                       fwhm_tolerance=fwhm_tolerance, $
                                       fwhm_min=fwhm_min, fwhm_max=fwhm_max, $
                                       image_output_path=image_output_path, output_path=output_path)
    
    output_filename=output_path+'line_list'
    mgfit_save_lines, emissionlines, output_filename

Alternatively, you could load the **mgfit** object class, which automatically loads the line list database as follows:

.. code-block:: idl

    mg=obj_new('mgfit')
    mg->set_output_path, output_path
    mg->set_image_output_path, image_output_path
    
    mg->read_ascii, input_file, wavel, flux
    
    emissionlines = mg->detect_lines(wavel, flux, $
                                     popsize=popsize, pressure=pressure, $
                                     generations=generations, $
                                     interval_wavelength=interval_wavelength, $
                                     redshift_initial=redshift_initial, $
                                     redshift_tolerance=redshift_tolerance, $
                                     fwhm_initial=fwhm_initial, $
                                     fwhm_tolerance=fwhm_tolerance, $
                                     fwhm_min=fwhm_min, fwhm_max=fwhm_max)
    
    output_filename=output_path+'line_list'
    mg->save_lines, emissionlines, output_filename

It will take a while to identify lines and fit Gaussian curves. You need to check the images of fitted lines stored in the image folder to remove some misidentified lines manually from the final list.

.. image:: https://raw.githubusercontent.com/mgfit/MGFIT-idl/master/examples/example2/images/plot_4431_4440.jpg
    :width: 200

.. image:: https://raw.githubusercontent.com/mgfit/MGFIT-idl/master/examples/example2/images/plot_4467_4476.jpg
    :width: 200

.. image:: https://raw.githubusercontent.com/mgfit/MGFIT-idl/master/examples/example2/images/plot_4548_4557.jpg
    :width: 200

.. image:: https://raw.githubusercontent.com/mgfit/MGFIT-idl/master/examples/example2/images/plot_4607_4616.jpg
    :width: 200

.. image:: https://raw.githubusercontent.com/mgfit/MGFIT-idl/master/examples/example2/images/plot_4856_4866.jpg
    :width: 200

.. image:: https://raw.githubusercontent.com/mgfit/MGFIT-idl/master/examples/animation/plot_4468_4476.gif
    :width: 200

.. image:: https://raw.githubusercontent.com/mgfit/MGFIT-idl/master/examples/animation/plot_4856_4865.gif
    :width: 200

Notes
-----

* To get better results, you should use a higher number of generations or/and a higher number of populations, which will increase the computational time, but will result in better fitted lines. 

* You need to adjust the FWHM parameters according to the spectral resolution of your observations.

* You need to change the redshift parameters for high redshift sources. 

Documentation
=============

For more information on how to use the API functions from the MGFIT-idl libray, please read the `API Documentation  <https://mgfit.github.io/MGFIT-idl/doc>`_ published on `mgfit.github.io/MGFIT-idl <https://mgfit.github.io/MGFIT-idl>`_.

Learn More
==========

==================  =============================================
**Documentation**   https://mgfit.github.io/MGFIT-idl/doc/
**Repository**      https://github.com/mgfit/MGFIT-idl
**Issues & Ideas**  https://github.com/mgfit/MGFIT-idl/issues
**Archive**         `10.5281/zenodo.4495916 <https://doi.org/10.5281/zenodo.4495916>`_
==================  =============================================
