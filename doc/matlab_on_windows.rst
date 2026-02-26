==========================================
Windows Installation Guide
==========================================

Known Limitations
=================

.. warning::

   **IDS validation is not supported on Windows.**

   The ``ids_validate`` MEX function and the automatic validation step that
   normally runs inside ``ids_put`` / ``ids_put_slice`` are both **disabled** on
   Windows builds. Calling ``ids_validate()`` directly will result in an error.

   This is a known limitation tracked in
   `GitHub issue #3 <https://github.com/iterorganization/IMAS-MATLAB/issues/3>`_.

   As a consequence:

   - The ``ids_validate`` MEX target is **not compiled** on Windows.
   - ``ids_put`` and ``ids_put_slice`` skip the validation check on Windows and
     write data directly without schema validation.
   - Users are responsible for ensuring that the IDS data structure is correct
     before calling ``ids_put`` or ``ids_put_slice`` on Windows.


Windows Prerequisites
=====================

1. **Visual Studio 2022** with:
   - Desktop Development with C++
   - C++ Make Tools for Windows

2. **MATLAB R2025b** (or compatible version)

3. **CMake** (included with Visual Studio)

4. **Python 3.8+** with venv module (verify with ``python --version``)



Setup vcpkg
===========

.. code-block:: batch

    git clone https://github.com/microsoft/vcpkg.git
    cd vcpkg
    bootstrap-vcpkg.bat


Configure PowerShell Environment
================================

Run these commands in PowerShell before building:

.. code-block:: powershell

    $env:PATH += ";C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\"
    $env:PATH += ";C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.44.35207\bin\HostX86\x86"
    $env:PATH += ";<VCPKG_INSTALLATION_PATH>"

if using already built IMAS-Core:

.. code-block:: powershell

    $env:AL_COMMON_PATH = "<IMAS_CORE_INSTALL_DIR>\share\common"

Build Configuration
===================

**Debug Build:**

.. code-block:: bash

    # with   -DAL_DOWNLOAD_DEPENDENCIES=ON
    cmake -Bbuild -S . -DVCPKG=ON -DAL_PYTHON_BINDINGS=ON -DCMAKE_INSTALL_PREFIX="<INSTALL_PATH>" -DCMAKE_TOOLCHAIN_FILE="<VCPKG_PATH>/scripts/buildsystems/vcpkg.cmake" -DAL_DOWNLOAD_DEPENDENCIES=ON -DAL_EXAMPLES=OFF -DAL_TESTS=OFF -DAL_PLUGINS=OFF -DAL_HLI_DOCS=OFF -DAL_DOCS_ONLY=OFF -DDD_VERSION="3.39.0" -DAL_BACKEND_UDA=OFF -DAL_BACKEND_UDAFAT=OFF -DAL_BACKEND_MDSPLUS=OFF
    # with   -DAL_DOWNLOAD_DEPENDENCIES=OFF
    cmake -Bbuild -S . -DVCPKG=ON -DAL_PYTHON_BINDINGS=ON -DCMAKE_INSTALL_PREFIX="<INSTALL_PATH>" -DCMAKE_TOOLCHAIN_FILE="<VCPKG_PATH>/scripts/buildsystems/vcpkg.cmake" -DAL_DOWNLOAD_DEPENDENCIES=OFF -DAL_EXAMPLES=OFF -DAL_TESTS=OFF -DAL_PLUGINS=OFF -DAL_HLI_DOCS=OFF -DAL_DOCS_ONLY=OFF -DDD_VERSION="3.39.0" -DAL_BACKEND_UDA=OFF -DAL_BACKEND_UDAFAT=OFF -DAL_BACKEND_MDSPLUS=OFF -DCMAKE_PREFIX_PATH="<IMAS_CORE_INSTALL_DIR>"

**Release Build:**

.. code-block:: bash

    # with   -DAL_DOWNLOAD_DEPENDENCIES=ON
    cmake -Bbuild -S . -DCMAKE_BUILD_TYPE=Release -DVCPKG=ON -DAL_PYTHON_BINDINGS=ON -DCMAKE_INSTALL_PREFIX="<INSTALL_PATH>" -DCMAKE_TOOLCHAIN_FILE="<VCPKG_PATH>/scripts/buildsystems/vcpkg.cmake" -DAL_DOWNLOAD_DEPENDENCIES=ON -DAL_EXAMPLES=OFF -DAL_TESTS=OFF -DAL_PLUGINS=OFF -DAL_HLI_DOCS=OFF -DAL_DOCS_ONLY=OFF -DDD_VERSION="3.39.0" -DAL_BACKEND_UDA=OFF -DAL_BACKEND_UDAFAT=OFF -DAL_BACKEND_MDSPLUS=OFF
    # with   -DAL_DOWNLOAD_DEPENDENCIES=OFF
    cmake -Bbuild -S . -DCMAKE_BUILD_TYPE=Release -DVCPKG=ON -DAL_PYTHON_BINDINGS=ON -DCMAKE_INSTALL_PREFIX="<INSTALL_PATH>" -DCMAKE_TOOLCHAIN_FILE="<VCPKG_PATH>/scripts/buildsystems/vcpkg.cmake" -DAL_DOWNLOAD_DEPENDENCIES=OFF -DAL_EXAMPLES=OFF -DAL_TESTS=OFF -DAL_PLUGINS=OFF -DAL_HLI_DOCS=OFF -DAL_DOCS_ONLY=OFF -DDD_VERSION="3.39.0" -DAL_BACKEND_UDA=OFF -DAL_BACKEND_UDAFAT=OFF -DAL_BACKEND_MDSPLUS=OFF -DCMAKE_PREFIX_PATH="<IMAS_CORE_INSTALL_DIR>"

Build and Install
=================

.. code-block:: bash

    cmake --build build --config Release --target install


Using in MATLAB
===============

Example MATLAB script to access IMAS data:

.. code-block:: matlab

    % Set PATH to find all required DLLs
    setenv('PATH', [getenv('PATH') ...
        ';<IMAS_MATLAB_PATH>\build\Release' ...
        ';<IMAS_MATLAB_PATH>\matlab' ...
        ';<IMAS_MATLAB_PATH>\build\_deps\al-core-build\Release' ...
        ';<IMAS_MATLAB_PATH>\build\vcpkg_installed\x64-windows\bin']);

    % Add MATLAB helper functions and MEX files
    addpath('<IMAS_MATLAB_PATH>\matlab');
    addpath('<IMAS_MATLAB_PATH>\build\Release');

    % Open IMAS pulse file
    uri = 'imas:hdf5?path=<PATH_TO_DATA_FILE>';
    ctx = imas_open(uri, 40);
    if ctx < 0
        error('Unable to open pulse');
    end

    % Get IDS structure
    try
        m = ids_get(ctx, 'waves');
        disp('Success!')
    catch ME
        disp(['Error: ' ME.message])
    end

    % Display results
    disp('=== IDS Properties ===');
    disp(['Comment: ' m.ids_properties.comment]);
    disp(['Data Dictionary: ' m.ids_properties.version_put.data_dictionary]);


Creating the MATLAB Toolbox Package
====================================

After a successful build and install, a self-contained ``.mltbx`` toolbox file can be
created using the ``create_matlab_toolbox`` script included in the install directory.

.. note::

    The ``<INSTALL_PATH>/toolbox/`` folder must exist (produced by
    ``cmake --build build --config Release --target install``) before packaging.

Run the following from inside MATLAB:

.. code-block:: matlab

    create_matlab_toolbox('<INSTALL_PATH>', '<OUTPUT_PATH>', '<VERSION>', '<DD_VERSION>')

For example:

.. code-block:: matlab

    create_matlab_toolbox('C:\imas_matlab_release', ...
                          'C:\imas_matlab_release', ...
                          '5.5.0', '4.1.1')

This produces a file such as::

    C:\imas_matlab_release\IMAS-MATLAB_5.5.0-DD-4.1.1-win64.mltbx


Installing the MATLAB Toolbox
==============================

**Option A – Double-click** the ``.mltbx`` file in Windows File Explorer.
MATLAB opens and installs it automatically via the Add-On Manager.

**Option B – From inside MATLAB:**

.. code-block:: matlab

    matlab.addons.install('C:\imas_matlab_release\IMAS-MATLAB_5.5.0-DD-4.1.1-win64.mltbx')

The toolbox is installed to::

    C:\Users\<username>\AppData\Roaming\MathWorks\MATLAB Add-Ons\Toolboxes\IMAS-MATLAB\


Using the Installed Toolbox
============================

Initializing
------------

On Windows, run this at the start of every MATLAB session to register the DLL
folder on the system ``PATH`` so that MEX files can locate their dependencies:

.. code-block:: matlab

    imas_toolbox_startup()

Expected output::

    IMAS-MATLAB/5.5.0-DD-4.1.1-win64 loaded successfully
    Access Layer: 5.5.0+64-... | Data Dictionary: 4.1.1

To run this automatically every session, add it to your MATLAB ``startup.m``:

.. code-block:: matlab

    % Open startup.m
    edit(fullfile(userpath, 'startup.m'))

    % Add the following line and save:
    imas_toolbox_startup()

Verifying the installation
---------------------------

.. code-block:: matlab

    v = imas_versions()

Expected output::

    v =
      struct with fields:
          al_version: '5.5.0+64-...'
         hli_version: '5.5.0+64-...'
          dd_version: '4.1.1'

Writing data
------------

.. code-block:: matlab

    % Open / create a database entry  (mode 43 = FORCE_CREATE)
    ctx = imas_open('imas:hdf5?path=C:/mydata', 43);
    if ctx < 0, error('Unable to open database'); end

    m = ids_gen('magnetics');
    m.ids_properties.homogeneous_time = 1;
    m.time = [1.0; 2.0; 3.0];
    m.flux_loop{1}.flux.data = [10.0; 20.0; 30.0];

    ids_put(ctx, 'magnetics', m);   % writes entire IDS (overwrites existing)
    imas_close(ctx);

Reading data
------------

.. code-block:: matlab

    % Open existing database  (mode 40 = OPEN_PULSE)
    ctx = imas_open('imas:hdf5?path=C:/mydata', 40);
    if ctx < 0, error('Unable to open database'); end

    m = ids_get(ctx, 'magnetics');
    disp(m.time)
    disp(m.flux_loop{1}.flux.data)

    imas_close(ctx);

Appending time slices
----------------------

.. code-block:: matlab

    ctx = imas_open('imas:hdf5?path=C:/mydata', 43);

    m = ids_gen('magnetics');
    m.ids_properties.homogeneous_time = 1;

    % Time slices must be appended in strictly increasing order
    m.time = 1.0;  m.flux_loop{1}.flux.data = 10.0;
    ids_put_slice(ctx, 'magnetics', m);

    m.time = 2.0;  m.flux_loop{1}.flux.data = 20.0;
    ids_put_slice(ctx, 'magnetics', m);

    imas_close(ctx);

``imas_open`` mode values
--------------------------

+----+----------------------+----------------------------------------------+
|Mode| Constant             | Description                                  |
+====+======================+==============================================+
| 40 | ``OPEN_PULSE``       | Open existing entry (error if not found)     |
+----+----------------------+----------------------------------------------+
| 41 | ``FORCE_OPEN_PULSE`` | Open entry, create if it does not exist      |
+----+----------------------+----------------------------------------------+
| 42 | ``CREATE_PULSE``     | Create new entry (error if already exists)   |
+----+----------------------+----------------------------------------------+
| 43 | ``FORCE_CREATE``     | Create entry, overwrite if it already exists |
+----+----------------------+----------------------------------------------+

Uninstalling
------------

In MATLAB: **Home → Add-Ons → Manage Add-Ons** → find *IMAS-MATLAB* → **Uninstall**.

Or from the command line:

.. code-block:: matlab

    matlab.addons.uninstall('IMAS-MATLAB')


Run MATLAB Tests
================

.. code-block:: bash

    matlab -batch "test_code"


Windows Troubleshooting
=======================

- Ensure all PowerShell environment variables are set before running CMake
- Verify Visual Studio C++ build tools are installed
- Check that all dependencies are accessible at the specified network paths
- Confirm Python installation with ``python --version``
- If MEX files fail with *"The specified module could not be found"*, ensure
  ``imas_toolbox_startup()`` has been called and the vcpkg DLLs are present in
  the toolbox folder (``hdf5.dll``, ``pthreadVC3.dll``,
  ``boost_filesystem-vc143-mt-x64-1_90.dll``, ``dl.dll``)
- **IDS validation is not available on Windows** — ``ids_validate`` is not
  compiled and validation is skipped inside ``ids_put`` / ``ids_put_slice``.
  See `GitHub issue #3 <https://github.com/iterorganization/IMAS-MATLAB/issues/3>`_
  for status and updates.
