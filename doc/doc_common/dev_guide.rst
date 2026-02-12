IMAS-MATLAB development guide
=============================


Repositories
------------

The IMAS-MATLAB consists of a number of dependencies which are developed in separate
repositories:

-   `imas-core <https://github.com/iterorganization/IMAS-Core>`__: the
    IMAS core repository, MDSplus model generator and Python lowlevel
    bindings.
-   `data-dictionary
    <https://github.com/iterorganization/IMAS-Data-Dictionary>`__: the IMAS Data
    Dictionary definitions, used for generating MDSplus models and the traditional High
    Level Interfaces.
-   `IMAS-Core-Plugins <https://github.com/iterorganization/IMAS-Core-Plugins/browse>`__: Access
    Layer plugins.
-   Traditional (code-generated) High Level Interfaces

    -   `IMAS-MATLAB <https://github.com/iterorganization/IMAS-MATLAB/browse>`__:
        MATLAB HLI


The documentation on this page covers everything except the Non-generated HLIs, those
are documented in their own projects.


Development environment
-----------------------

See the :ref:`build prerequisites` section for an overview of modules you need to load
when on SDCC or packages to install when using Ubuntu 22.04.

The recommended development folder layout is to clone all :ref:`Repositories` in a single root folder (``al-dev`` in below example, but the name of that
folder is not important).

.. code-block:: text

    al-dev/                 # Feel free to name this folder however you want
    ├── al-core/
    ├── al-plugins/         # Optional
    ├── al-matlab/          
    └── data-dictionary/

Then, when you configure a project for building (see :ref:`Configuration`), set the
option ``-D AL_DOWNLOAD_DEPENDENCIES=OFF``. Instead of fetching requirements from the
ITER git, CMake will now use the repositories as they are checked out in your
development folders.

    With this setup, it is your responsibility to update the repositories to their
    latest versions (if needed). The ``<component>_VERSION`` configuration options are
    ignored when ``AL_DOWNLOAD_DEPENDENCIES=OFF``.

This setup allows you to develop in multiple repositories in parallel.


Dependency management
---------------------

With all IMAS-MATLAB dependencies spread over different repositories, managing
dependencies is more complex than before. Below diagram expresses the dependencies
between the different repositories:

.. md-mermaid::
    :name: repository-dependencies

    flowchart
        core[al-core] -->|"MDSplus<br>models"| dd[data-dictionary]
        plugins[al-plugins] --> core
        hli["al-{hli}"] --> core
        hli --> dd
        hli --> plugins

To manage the "correct" version of each of the dependencies, the CMake configuration
specifies which branch to use from each repository:

-   Each HLI indicates which commit to use from the ``al-core`` repository. This is
    defined by the ``AL_CORE_VERSION`` cache string in the main ``CMakeLists.txt`` of
    the repository.

    The default version used is ``main``, which is the last stable release of
    ``al-core``.
-   Inside the ``al-core`` repository, the commits to use for the
    ``al-plugins`` and ``data-dictionary`` are set in `ALCommonConfig.cmake
    <https://github.com/iterorganization/IMAS-MATLAB/blob/develop/common/cmake/ALCommonConfig.cmake>`__.

    The default versions used are ``main`` for ``al-plugins``, and ``main`` for
    ``data-dictionary``.


.. info::

    CMake supports setting branch names, tags and commit hashes for the dependencies.


CMake
-----

We're using CMake for the build configuration. See `the CMake documentation
<https://cmake.org/cmake/help/latest/>`__ for more details about CMake.

The ``FetchContent`` CMake module for making :ref:`dependencies from other repositories
<dependency management>` available. For more information on this module we refer to the
`FetchContent CMake documentation
<https://cmake.org/cmake/help/latest/module/FetchContent.html>`__


Documentation overview
----------------------

The documentation is generated with Sphinx. For more information on Sphinx, see the `Sphinx docs
<https://www.sphinx-doc.org/en/master/>`__ and the `documentation of the theme
(sphinx-immaterial) that we're using
<https://jbms.github.io/sphinx-immaterial/index.html>`__.

Documentation of the HLI is inside the ``doc`` folder of the repository. This folder
contains the configuration (``conf.py``), and documentation pages (``*.rst``).
Documentation that is common to all High Level Interfaces (such as this developer guide)
is in the `common/doc_common folder in the al-core repository
<https://github.com/iterorganization/IMAS-MATLAB/blob/develop/common/doc_common>`__.


Building the documentation
''''''''''''''''''''''''''

Use the option ``-D AL_HLI_DOCS`` to enable building documentation. This will create a
target ``al-<hli>-docs``, e.g. ``al-matlab-docs`` that will only build the
documentation. You could also use ``-D AL_DOCS_ONLY`` to only build the documentation,
and nothing else.

.. code-block:: console
    :caption: Example: building the documentation for the Python HLI

    al-dev$ cd al-matlab
    al-matlab$ # Configure cmake to only create the documentation:
    al-matlab$ cmake -B build -D AL_HLI_DOCS -D AL_DOCS_ONLY
    [...]
    al-matlab$ make -C build al-matlab-docs
    [...]


GitHub Actions CI/CD pipeline
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In addition to the ITER CI systems, the IMAS-MATLAB repository uses `GitHub Actions
<https://github.com/features/actions>`__ for automated building and testing. The
workflow is defined in `.github/workflows/build-and-test.yml
<https://github.com/iterorganization/IMAS-MATLAB/blob/main/.github/workflows/build-and-test.yml>`__.

This workflow:

-   **Triggers**: Automatically runs on pushes to ``main``, ``develop``, and ``feature/**`` branches, 
    on all pull requests to ``main`` and ``develop``, on release tags (``v*``), and can be triggered 
    manually via ``workflow_dispatch``.

-   **Platforms**: Currently tests on Ubuntu 24.04 with GCC 14 compiler and MATLAB R2023b.

-   **Build steps**:
    
    1. Sets up Python 3.11 environment
    2. Installs MATLAB using GitHub's official MATLAB action
    3. Installs system dependencies (build-essential, cmake, pkg-config, etc.)
    4. Caches Boost and pip packages for faster builds
    5. Builds and optionally installs external dependencies (UDA, HDF5, etc.)
    6. Configures the project with CMake
    7. Compiles the code
    8. Runs tests if enabled

-   **Backends tested**: Currently enables the HDF5 backend while MDSplus and UDA 
    backends are disabled to simplify testing.

-   **Build artifacts**: The workflow checks that the code compiles successfully and 
    that all tests pass. Build logs are available in the GitHub Actions tab of the repository.

You can monitor the status of builds and tests in the 
`Actions <https://github.com/iterorganization/IMAS-MATLAB/actions>`__ tab of the GitHub repository.
