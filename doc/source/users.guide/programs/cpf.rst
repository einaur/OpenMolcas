.. index::
   single: Program; CPF
   single: CPF

.. _UG\:sec\:cpf:

:program:`cpf`
==============

.. only:: html

  .. contents::
     :local:
     :backlinks: none

Description
-----------

.. xmldoc:: <MODULE NAME="CPF">
            %%Description:
            <HELP>
            This program performs standard SDCI calculations, or
            CPF calculations as described by Ahlrichs; MCPF calculations(Chong) or
            ACPF calculations(Gdanitz). In each case, the reference is normally
            a single determinant, possibly with a few high-spin coupled open shells,
            but low-spin cases are also possible. It was originally written by Siegbahn and
            Blomberg, and has only been slightly modified to fit MOLCAS.
            It requires a file generated by the GUGA program. See manual.
            </HELP>

The
:program:`CPF` program generates :index:`SDCI <single: SDCI; using CPF>`,
:index:`CPF` :cite:`Ahlrichs:85`,
:index:`MCPF` :cite:`Chong:86` or
:index:`ACPF <single: ACPF; using CPF>` :cite:`Gdanitz:88`,
wavefunctions from **one** reference configuration.

The
:program:`CPF` program is a modification to a CPF
program written by P. E. M. Siegbahn and M. Blomberg
(Institute of Physics, Stockholm University, Sweden).

The program is based on the Direct CI method :cite:`Roos:72`,
with the coupling coefficients generated
by the Graphical Unitary Group Approach :cite:`Shavitt:77,Shavitt:78,Siegbahn:80`
(See program description for
:program:`GUGA`).
:program:`CPF` generates natural orbitals that can be fed into
the property program to evaluate certain one electron properties.
Also, the natural orbitals can be used for Iterative Natural Orbital
calculations.

Orbital subspaces
-----------------

The orbital space is divided into the following subspaces:
:index:`Frozen <single: CPF; Frozen>`,
:index:`Inactive <single: CPF; Inactive>`,
:index:`Active <single: CPF; Active>`,
:index:`Secondary <single: CPF; Secondary>`,
and :index:`Deleted <single: CPF; Deleted>` orbitals. Within each
symmetry type, they follow this order.
Their meaning is the same as explained in the :program:`GUGA` and
:program:`MOTRA` sections, except that, in this case, there is only
a single reference configuration. Therefore, the active orbitals in
this case are usually only open shells, if any.
Since explicit handling of orbitals is taken care of at the integral
transformation step, program :program:`MOTRA`, orbital spaces are not
specified in the input, except when orbitals are frozen or deleted by the
:program:`CPF` program, rather than by :program:`MOTRA`
(which should normally be avoided).

.. index::
   pair: Dependencies; CPF

.. _UG\:sec\:cpf_dependencies:

Dependencies
------------

The :program:`CPF` program needs the coupling
coefficients generated by the program
:program:`GUGA` and the transformed one and two electron
integrals from the program
:program:`MOTRA`.

.. index::
   pair: Files; CPF

.. _UG\:sec\:cpf_files:

Files
-----

Input files
...........

The
:program:`CPF` program need the coupling coefficients generated by
:program:`GUGA` and the transformed integrals from
:program:`MOTRA`.

:program:`CPF` will use the following input
files: :file:`ONEINT`, :file:`RUNFILE`, :file:`CIGUGA`,
:file:`TRAINT`, :file:`TRAONE`
(for more information see :numref:`UG:sec:files_list`).
and :file:`CPFVECT` (for restarted calculations).

Output files
............

:program:`CPF` generates an two output files:

.. class:: filelist

:file:`CPFORB`
  The natural orbitals from the CPF functional.

:file:`CPFVECT`
  The CI expansion coefficients. These may be used for restarting an
  unconverged calculation.

.. index::
   pair: Input; CPF

.. _UG\:sec\:cpf_input:

Input
-----

This section describes the input to the :program:`CPF` program in the |molcas| program system.
The input for each module is preceded by its name like: ::

  &CPF

.. index::
   pair: Keywords; CPF

Optional keywords
.................

.. class:: keywordlist

:kword:`TITLe`
  Followed by a title line

  .. xmldoc:: <KEYWORD MODULE="CPF" NAME="TITLE" APPEAR="Title" KIND="STRING" LEVEL="BASIC">
              %%Keyword: Title <basic>
              <HELP>
              Followed by a title line
              </HELP>
              </KEYWORD>

:kword:`SDCI`
  Specifies that a SDCI calculation is to be performed.
  No additional input is required.
  Only one of the choices SDCI, CPF, MCPF or ACPF should be chosen.

  .. xmldoc:: <SELECT MODULE="CPF" NAME="COMP_MODEL" APPEAR="Computation model" CONTAINS="SDCI,CPF,MCPF,ACPF" LEVEL="BASIC">

  .. xmldoc:: <KEYWORD MODULE="CPF" NAME="SDCI" KIND="SINGLE" EXCLUSIVE="CPF,MCPF,ACPF" LEVEL="BASIC">
              %%Keyword: SDCI <basic>
              Out of the choices SDCI, CPF, MCPF or ACPF, precisely one must be used.
              <HELP>
              Single-reference SDCI calculation.
              </HELP>
              </KEYWORD>

:kword:`CPF`
  Specifies that a CPF calculation is to be performed.
  Only one of the choices SDCI, CPF, MCPF or ACPF should be chosen.

  .. xmldoc:: <KEYWORD MODULE="CPF" NAME="CPF" KIND="SINGLE" EXCLUSIVE="SDCI,MCPF,ACPF" LEVEL="BASIC">
              %%Keyword: CPF <basic>
              Out of the choices SDCI, CPF, MCPF or ACPF, precisely one must be used.
              <HELP>
              Single-reference CPF calculation (Ahlrichs, see manual).
              </HELP>
              </KEYWORD>

:kword:`MCPF`
  Specifies that a Modified CPF calculation is to be performed.
  This option is in fact the default choice.
  Only one of the choices SDCI, CPF, MCPF or ACPF should be chosen.

  .. xmldoc:: <KEYWORD MODULE="CPF" NAME="MCPF" KIND="SINGLE" EXCLUSIVE="SDCI,CPF,ACPF" LEVEL="BASIC">
              %%Keyword: MCPF <basic>
              Out of the choices SDCI, CPF, MCPF or ACPF, precisely one must be used.
              <HELP>
              Single-reference MCPF calculation (Chong, see manual).
              </HELP>
              </KEYWORD>

:kword:`ACPF`
  Specifies that an Average CPF calculation is to be performed.
  Only one of the choices SDCI, CPF, MCPF or ACPF should be chosen.

  .. xmldoc:: <KEYWORD MODULE="CPF" NAME="ACPF" KIND="SINGLE" EXCLUSIVE="SDCI,CPF,MCPF" LEVEL="BASIC">
              %%Keyword: ACPF <basic>
              Out of the choices SDCI, CPF, MCPF or ACPF, precisely one must be used.
              <HELP>
              Single-reference ACPF calculation (Gdanitz, see manual).
              </HELP>
              </KEYWORD>

  .. xmldoc:: </SELECT>

:kword:`RESTart`
  Restart the calculation from a previous calculation.

  .. xmldoc:: <KEYWORD MODULE="CPF" NAME="RESTART" APPEAR="Restart" KIND="SINGLE" LEVEL="ADVANCED">
              %%Keyword: Restart <advanced>
              <HELP>
              Restart the calculation from a previous calculation.
              </HELP>
              </KEYWORD>

:kword:`THRPr`
  Threshold for printout of the wavefunction. All configurations with
  a coefficient greater than this threshold are printed in the final
  printout. The default is 0.05.

  .. xmldoc:: <KEYWORD MODULE="CPF" NAME="THRP" APPEAR="CI Print Threshold" KIND="REAL" LEVEL="ADVANCED" DEFAULT_VALUE="0.05" MIN_VALUE="0.0">
              %%Keyword: ThrPrint <advanced>
              <HELP>
              Set threshold on CI coefficients to be printed. Default 0.05.
              </HELP>
              </KEYWORD>

:kword:`ECONvergence`
  Energy convergence threshold. The update procedure is repeated
  until the energy difference between the last two iterations is less
  than this threshold. The default is 1.0e-8.

  .. xmldoc:: <KEYWORD MODULE="CPF" NAME="ECON" APPEAR="Energy Convergence" KIND="REAL" LEVEL="ADVANCED" DEFAULT_VALUE="1.0D-8" MIN_VALUE="0.0">
              %%Keyword: EConvergence <advanced>
              <HELP>
              Set energy threshold for convergence. Default 1.0D-8.
              </HELP>
              </KEYWORD>

:kword:`PRINt`
  Print level of the program. Default is 5.

  .. xmldoc:: <KEYWORD MODULE="CPF" NAME="PRINT" APPEAR="Print level" KIND="INT" LEVEL="ADVANCED" DEFAULT_VALUE="5">
              %%Keyword: PrintLevel <advanced>
              <HELP>
              Set print level. Default is 5.
              </HELP>
              </KEYWORD>

:kword:`MAXIterations`
  Maximum number of iterations in the update procedure. Default 20.
  The maximum value of this parameter is 75.

  .. xmldoc:: <KEYWORD MODULE="CPF" NAME="MAXITER" APPEAR="Maximum iterations" KIND="INT" LEVEL="ADVANCED" DEFAULT_VALUE="20" MIN_VALUE="0" MAX_VALUE="75">
              %%Keyword: MaxIterations <advanced>
              <HELP>
              Set maximum iterations. Default 20, max possible 75.
              </HELP>
              </KEYWORD>

:kword:`FROZen`
  Specify the number of orbitals to be frozen in
  **addition** to the orbitals frozen in the integral transformation. Default is 0
  in all symmetries.

  .. xmldoc:: <KEYWORD MODULE="CPF" NAME="FROZEN" APPEAR="Frozen" KIND="INTS_LOOKUP" SIZE="NSYM" LEVEL="ADVANCED" DEFAULT_VALUE="0" MIN_VALUE="0">
              %%Keyword: Frozen <advanced>
              <HELP>
              Specify, for each symmetry, how many orbitals to keep uncorrelated
              in addition to any that were frozen already by MOTRA.
              </HELP>
              </KEYWORD>

:kword:`DELEted`
  Specify the number of orbitals to be deleted in
  **addition** to the orbitals deleted in the integral transformation. Default is 0
  in all symmetries.

  .. xmldoc:: <KEYWORD MODULE="CPF" NAME="DELETED" APPEAR="Deleted" KIND="INTS_LOOKUP" SIZE="NSYM" LEVEL="ADVANCED" DEFAULT_VALUE="0" MIN_VALUE="0">
              %%Keyword: Deleted <advanced>
              <HELP>
              Specify, for each symmetry, how many orbitals to delete
              in addition to any that were deleted already by MOTRA.
              </HELP>
              </KEYWORD>

:kword:`LOW`
  Specifies that this is a low spin case, i.e. the spin is less than
  the maximum possible with the number of open shells in the
  calculation. See Refs. :cite:`Ahlrichs:85,Chong:86`.
  This requires special considerations.

  .. xmldoc:: <KEYWORD MODULE="CPF" NAME="LOWSPIN" APPEAR="Low Spin" KIND="SINGLE" LEVEL="ADVANCED">
              %%Keyword: Low <advanced>
              <HELP>
              Specifies a low spin case, see manual.
              </HELP>
              </KEYWORD>

:kword:`MAXPulay`
  Maximum number of iterations in the initial stage. After that, DIIS extrapolation
  will be used. Default is 6.

  .. xmldoc:: <KEYWORD MODULE="CPF" NAME="MAXPULAY" APPEAR="Pre-DIIS Iterations" KIND="INT" LEVEL="ADVANCED" DEFAULT_VALUE="6">
              %%Keyword: MaxPulay <advanced>
              <HELP>
              Number of iterations until DIIS extrapolation is switched on.
              </HELP>
              </KEYWORD>

:kword:`LEVShift`
  Levelshift in the update procedure. Default is 0.3.

  .. xmldoc:: <KEYWORD MODULE="CPF" NAME="LEVSHIFT" APPEAR="Level shift" KIND="REAL" LEVEL="ADVANCED" DEFAULT_VALUE="0.3">
              %%Keyword: LevShift <advanced>
              <HELP>
              Enter level shift to use in the equation solver. Default is 0.3.
              </HELP>
              </KEYWORD>

Input example
.............

::

  &CPF
  Title
   Water molecule. 1S frozen in transformation.
  MCPF

.. xmldoc:: </MODULE>
