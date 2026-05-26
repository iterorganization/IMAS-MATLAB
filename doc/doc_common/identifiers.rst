Identifiers
===========

The "identifier" structure is used to provide an enumerated list of options.

For a complete reference of all available identifiers, see the 
`IMAS Data Dictionary Identifiers <https://imas-data-dictionary.readthedocs.io/en/latest/identifiers.html>`__ documentation.

.. csv-table:: Identifier examples (from part of the ``core_sources/source`` identifier)
    :header-rows: 1

    Index, Name, Description
    2, NBI, Source from Neutral Beam Injection
    3, EC, Sources from heating at the electron cyclotron heating and current drive
    4, LH, Sources from lower hybrid heating and current drive
    5, IC, Sources from heating at the ion cyclotron range of frequencies
    6, fusion, "Sources from fusion reactions, e.g. alpha particle heating"

Using the identifiers library
-----------------------------

|identifiers_link_instructions|

Below examples illustrates how to use the identifiers in your Matlab programs.

.. literalinclude:: code_samples/identifier_example1
    :caption: Matlab example 1: obtain identifier information of coordinate identifier ``phi``

.. literalinclude:: code_samples/identifier_example2
    :caption: Matlab example 2: Use the identifier library to fill the ``NBI`` label in the ``core_sources`` IDS

.. literalinclude:: code_samples/identifier_example3
    :caption: Matlab example 3: Use the identifier library to fill the type of coordinate system used in the ``equilibrium`` IDS

