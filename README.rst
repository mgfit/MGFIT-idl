=========
MGFIT-idl
=========
    
.. image:: https://travis-ci.org/mgfit/MGFIT-idl.svg?branch=master
    :target: https://travis-ci.org/mgfit/MGFIT-idl
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

**MGFIT (IDL version)** - IDL/GDL Library for Least-Squares Minimization Genetic Algorithm Fitting

Description
============

The **MGFIT** is an `Interactive Data Language <http://www.harrisgeospatial.com/ProductsandSolutions/GeospatialProducts/IDL.aspx>`_ (IDL)/`GNU Data Language <http://gnudatalanguage.sourceforge.net/>`_ (GDL) Library developed to fit multiple Gaussian functions to a list of emission (or absorption) lines using a least-squares minimization technique and a random walk method in three-dimensional locations of the specified lines, namely line peak, line width, and wavelength shift. It uses the `MPFIT <http://cow.physics.wisc.edu/~craigm/idl/cmpfit.html>`_ IDL Library (`MINPACK-1 Least Squares Fitting <http://adsabs.harvard.edu/abs/2012ascl.soft08019M>`_; `Markwardt 2009 <http://adsabs.harvard.edu/abs/2009ASPC..411..251M>`_), which performs Levenberg-Marquardt least-squares minimization, to estimate the seed values required for initializing the three-dimensional coordination of each line in the first iteration. It then uses a random walk method optimized using a genetic algorithm originally evolved from the early version of the Fortran program `ALFA <http://adsabs.harvard.edu/abs/2015ascl.soft12005W>`_ (`Automated Line Fitting Algorithm <https://github.com/rwesson/ALFA>`_; `Wesson 2016 <http://adsabs.harvard.edu/abs/2016MNRAS.456.3774W>`_) to determine the best fitting values of the specified lines. The continuum curve is determined and subtracted before the line identification and flux measurements. It quantifies the white noise of the spectrum, which is then utilized to estimate uncertainties of fitted lines using the signal-dependent noise model of least-squares Gaussian fitting (`Lenz & Ayres 1992 <http://adsabs.harvard.edu/abs/1992PASP..104.1104L>`_) built on the work of `Landman, Roussel-Dupre, and Tanigawa (1982) <http://adsabs.harvard.edu/abs/1982ApJ...261..732L>`_.

Installation
============

Dependent IDL Packages
----------------------

* This package requires the following packages:

    - `The IDL Astronomy User's Library <https://idlastro.gsfc.nasa.gov/homepage.html>`_
    
    - `The Coyote IDL Library <https://github.com/idl-coyote/coyote>`_
    
    - `The MPFIT IDL Library <http://cow.physics.wisc.edu/~craigm/idl/idl.html>`_
    
* To get this package with all the dependent packages, you can simply use ``git`` command as follows::

        git clone --recursive https://github.com/mgfit/MGFIT-idl


Installation in IDL
-------------------

* To install the **MGFIT** IDL library in the Interactive Data Language (IDL), you need to add the path of this package directory to your IDL path. For more information about the path management in IDL, read `the tips for customizing IDL program path <https://www.harrisgeospatial.com/Support/Self-Help-Tools/Help-Articles/Help-Articles-Detail/ArtMID/10220/ArticleID/16156/Quick-tips-for-customizing-your-IDL-program-search-path>`_ provided by Harris Geospatial Solutions or `the IDL library installation note <http://www.idlcoyote.com/code_tips/installcoyote.php>`_ by David Fanning in the Coyote IDL Library. 

* This package requires IDL version 7.1 or later. 


Installation in GDL
-------------------

*  You can install the GNU Data Language (GDL) if you do not have it on your machine:

    - Linux (Fedora)::

        sudo dnf install gdl
    
    - Linux (Ubuntu)::
    
        sudo apt-get install gnudatalanguage
    
    - OS X::
    
        brew install gnudatalanguage
    
    - Windows: You can use the `GNU Data Language for Win32 <https://sourceforge.net/projects/gnudatalanguage-win32/>`_ (Unofficial Version) or you can compile the `GitHub source <https://github.com/gnudatalanguage/gdl>`_ using Visual Studio 2015 as shown in `appveyor.yml <https://github.com/gnudatalanguage/gdl/blob/master/appveyor.yml>`_.

* To install the **MGFIT** library in GDL, you need to add the path of this package directory to your ``.gdl_startup`` file in your home directory::

    !PATH=!PATH + ':/home/MGFIT-idl/pro/'
    !PATH=!PATH + ':/home/MGFIT-idl/externals/astron/pro/'
    !PATH=!PATH + ':/home/MGFIT-idl/externals/coyote/pro/'
    !PATH=!PATH + ':/home/MGFIT-idl/externals/coyote/public/'
    !PATH=!PATH + ':/home/MGFIT-idl/externals/mpfit/'

  You may also need to set ``GDL_STARTUP`` if you have not done in ``.bashrc`` (bash)::

    export GDL_STARTUP=~/.gdl_startup

  or in ``.tcshrc`` (cshrc)::

    setenv GDL_STARTUP ~/.gdl_startup

* This package requires GDL version 0.9.8 or later.

Documentation
=============

For more information on how to use the API functions from the idl_emcee libray, please read the `API Documentation  <https://mgfit.github.io/MGFIT-idl/doc>`_ published on `mgfit.github.io/idl_emcee <https://mgfit.github.io/MGFIT-idl>`_.

