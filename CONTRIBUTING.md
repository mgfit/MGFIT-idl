# Contributing to MGFIT-IDL

The following guidelines are designed for contributors to the MGFIT IDL package, which is 
hosted in the [MGFIT-idl repository](https://github.com/mgfit/MGFIT-idl) on GitHub. 

## Reporting Issues

The [issue tracker](https://github.com/mgfit/MGFIT-idl/issues) is used to report any bugs, request new functionality, and discuss improvements. 
For reporting a bug or a failed function or requesting a new feature, you can simply open an issue 
in the [issue tracker](https://github.com/mgfit/MGFIT-idl/issues) of the 
[MGFIT-idl](https://github.com/mgfit/MGFIT-idl) repository. If you are reporting a bug, please also include a minimal code
example that makes the issue, and IDL version used by you.

## Contributing Code

To make contributions to MGFIT-idl, you need to set up your [GitHub](https://github.com) 
account if you do not have and sign in, and request your change(s) or contribution via 
opening a pull request against the ``master``
branch in your fork of the [MGFIT-idl repository](https://github.com/mgfit/MGFIT-idl). 

Please use the following steps:

- Open a new issue for new feature or failed function in the [Issue tracker](https://github.com/mgfit/MGFIT-idl/issues).
- Fork the [MGFIT-idl repository](https://github.com/mgfit/MGFIT-idl) to your GitHub account.
- Clone your fork of the [MGFIT-idl repository](https://github.com/mgfit/MGFIT-idl):

      $ git clone git@github.com:your-username/MGFIT-idl.git
      
- Make your change(s) in the `master` branch of your cloned fork.
- Make sure that all tests are passed without any errors.
- Push yout change(s) to your fork in your GitHub account.
- [Submit a pull request][pr], mentioning what problem has been solved.

[pr]: https://github.com/mgfit/MGFIT-idl/compare/

Your contribution will be checked and merged into the original repository. You will be contacted if there is any problem in your contribution.

While you are opening a pull request for your contribution, be sure that you have included:

* **Code** which you are contributing to this package.

* **Documentation** of this code if it provides new functionality. This should be a
  description of new functionality added to the API documentation (in ``docs/``). 

- **Tests** of this code to make sure that the previously failed function or the new functionality now works properly.

- **Revision history** if you fixed a bug in the previously failed function or add a code for new functionality, you should
well document your change(s) or addition in the *Revision History* entry of the changed or added function in your code.
