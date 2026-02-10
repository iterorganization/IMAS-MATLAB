Getting Started with IMAS-Matlab
=================================

Welcome! This 5-minute guide will get you up and running with the IMAS-Matlab.

**What is IMAS-Matlab?**

IMAS-Matlab is the IMAS data access library (formerly known as the Access Layer) for Matlab users/developers. 


Load the IMAS-Matlab Module
-------------------------------

On the ITER SDCC (supercomputing cluster), make the Access Layer available:

.. code-block:: bash

    module load IMAS-Matlab

To see available versions:

.. code-block:: bash

    module avail IMAS-Matlab

If you have a local installation, source the environment file instead:

.. code-block:: bash

    source <install_dir>/bin/al_env.sh


Open MATLAB and Connect to Data
-------------------------------------------

Start MATLAB and open a database entry using an IMAS URI. A URI tells the Access Layer 
where your data is stored and in what format.

.. code-block:: matlab

    % Open a database entry
    uri = 'imas:hdf5?path=/path/to/data';
    ctx = imas_open(uri, 40);  
    
    if ctx < 0
        error('Unable to open database');
    end

**What's an IMAS URI?**

URIs follow the format: ``imas:backend?query_options``

For example:
- ``imas:hdf5?path=/path/to/data`` – Read from HDF5 files
- ``imas:mdsplus?path=./test_db`` – Read from MDSplus
- ``imas:uda?backend=...`` – Read from UDA backend

Learn more: :ref:`Data entry URIs`


Load and Display Dat
------------------------

Fetch an IDS from your database entry:

.. code-block:: matlab

    % Load the magnetics IDS (occurrence 0)
    magnetics = ids_get(ctx, 'magnetics');
    
    % Explore the data
    disp(magnetics.ids_properties);      % Metadata
    disp(magnetics.time);                 % Time points
    disp(magnetics.flux_loop{1}.flux.data); % Access nested data


Modify and Store Data
------------------------

You can create new data, modify existing data, and store it back:

.. code-block:: matlab

    % Create a new IDS or modify existing one
    equilibrium = ids_init('equilibrium');
    equilibrium.time = [0, 1, 2, 3];
    equilibrium.q_profile.value.data = [1, 2, 3, 4];
    
    % Store it to the database
    ids_put(ctx, 'equilibrium', equilibrium);


Clean Up
-----------

Always close the database entry when you're done:

.. code-block:: matlab

    imas_close(ctx);


Key Functions Reference
-----------------------

+====================================+=============================================+
| Function                           | Purpose                                     |
+====================================+=============================================+
| ``imas_open(uri, version)``        | Open a database entry at the given URI      |
+------------------------------------+---------------------------------------------+
| ``imas_close(ctx)``                | Close the database entry                    |
+------------------------------------+---------------------------------------------+
| ``ids_get(ctx, ids_name)``         | Load an entire IDS                          |
+------------------------------------+---------------------------------------------+
| ``ids_put(ctx, ids_name, ids_obj)``| Store an IDS to disk                        |
+------------------------------------+---------------------------------------------+
| ``ids_init(ids_name)``             | Create and initialize a new IDS             |
+------------------------------------+---------------------------------------------+
| ``ids_get_slice(ctx, ids_name, time)`` | Load a specific time slice              |
+====================================+=============================================+


Common Use Cases
----------------

**Load data and extract a single time slice:**

.. code-block:: matlab

    % Use CLOSEST interpolation
    data = ids_get_slice(ctx, 'equilibrium', 2.5, 'CLOSEST');


**Check if data exists:**

.. code-block:: matlab

    if ids_isdefined(magnetics.flux_loop{1}.flux)
        disp('Flux data is defined');
    end


**Access MATLAB examples:**

The repository contains several example scripts in the ``examples/`` directory:
- ``test_get.m``  Load and display data
- ``test_put.m``  Store new data
- ``test_get_sample_magnetics.m``  Practical magnetics data example


Next Steps
----------

- **Read more about IDSs**: :doc:`Use Interface Data Structures <identifiers>`
- **Learn advanced loading/storing**: :doc:`Loading and storing IMAS data <load_store_ids>`
- **Understand data storage**: :ref:`Data entry URIs`
- **Check the full API documentation**: See your installed IMATLAB help or visit the 
  `IMAS-Matlab <https://imas-matlab.readthedocs.io>`__


Common Issues
-------------

**"Unable to open pulse" error:**
- Check that your URI is correct and the data path exists

**IDS not found:**
- Verify the data entry contains this IDS
- Use ``ids_isdefined()`` to check existence first

**Need help?**
- Check the :doc:`Using the Access Layer <using_al>` guide
- Consult the `IMAS-Matlab <https://imas-matlab.readthedocs.io/>`__