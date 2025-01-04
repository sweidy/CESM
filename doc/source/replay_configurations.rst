.. _configurations:

=======================================
Available configurations for the replay
=======================================

Available Compsets
------------------

The replay requires resetting buffer variables to their previous values every time 
the model backs up. The current setup only resets buffer variables in the FHIST_DARTC6 
compset, which is similar to the normal AMIP compsets but with a stub river component 
and has been used for other data assimilation purposes. A description of the compset 
is in **components/cam/cime_config/confic_compsets.xml**.

Additional compsets could be added by making similar changes to the ocean or river buffer
variables (any variables that show up in the component.r. restart file) as for the CICE and
CLM components (see :ref:`API <Changes to SourceMods for Replay>` for descriptions of what files 
need to be changed).

Available Resolutions
---------------------

Replay should be able to use any fv resolution that matches your reanalysis dataset. 

Namelist parameters
-------------------

Various additional Namlist parameters are available for configuring the replay, defined in 
**components/cam/bld/namelist_files/namelist_definition.xml**. Specific replay parameters are 
defined below:

Replay_Model: 
       type="logical", category="replay", group="replay_nl" 
         Toggle replay ON/OFF.

         Default: FALSE

Replay_Path: 
       type="char*256", input_pathname="abs", category="replay", group="replay_nl" 
         Full pathname of analyses data to use for replay.
         (e.g. '/$DIN_LOC_ROOT/atm/cam/replay/')
       
         Default: none

Replay_File_Template: 
       type="char*80", category="replay", group="replay_nl" 
         Template for replay analyses file names.
         (e.g. '/MERRA2_%y%m%d_%h.nc')
       
         Default: none

Replay_Beg_Year: 
       type="integer", category="replay", group="replay_nl" 
         Year at which replay begins.
       
         Default: 1980

Replay_coef: 
       type="real", category="replay", group="replay_nl" 
         Coeffcient for replay [0.,1.]. Fraction of nudging tendency applied: 
         usually 1 (full forcing) or 0 (no forcing).
       
         Default: 1.


Configurations TODO
--------------------

#. Windowing for replay like in the nudging toolbox (Will?)
#. Ability to change duration of replay and forcing times.
#. Allow for setting on and off each variable (Will?)