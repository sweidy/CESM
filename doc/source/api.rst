.. _api:

================================
Changes to SourceMods for Replay
================================

Most changes have been labeled with an inline comment "added - sweid" or 
something similar. The :f:mod:`replay.F90` module is where the core of the replay occurs, and 
is likely the only file needed to understand how the replay works. 

CIME 
----
`CIME github <https://github.com/sweidy/cime>`_

**Module** :f:mod:`ESMF_ClockMod.F90`

Source path: cime/src/share/esmf_wrf_timemgr/

.. f:module:: ESMF_ClockMod.F90

.. f:subroutine:: ESMF_ClockSetOLD

    Use replay timing variable ContinueTime.

.. f:subroutine:: ESMF_ClockGetContinueTime

    Define replay timing variable ContinueTime and allow other functions to query.

.. f:subroutine:: ESMF_ClockAdvance

    Adjust current time and advance time based on whether a replay or corrector step. 
    Turn off sync alarms. Allows for other clock functions to work with replay. Changes 
    clock alarms so the model doesn't crash when backup occurs.

**Module** :f:mod:`cime_comp_mod.F90`

Source path: cime/src/drivers/mct/main/

.. f:module:: cime_comp_mod.F90

.. f:subroutine:: cime_run
    
    Reset time and date to restart time at correct time.

**Module** :f:mod:`seq_timemgr_mod.F90`

Source path: cime/src/drivers/mct/shr/

.. f:module:: seq_timemgr_mod.F90

.. f:subroutine:: seq_timemgr_clockAdvance
    
    Change clock advance to replay-specific advance variable continue_tod.

.. f:subroutine:: seq_timemgr_EClockInit

    Adjust clock time for restart.

CAM
---
`CAM github <https://github.com/sweidy/CAM>`_

**Module** :f:mod:`cam_comp.F90`

Source path: components/cam/src/control

.. f:module:: cam_comp.F90

.. f:subroutine:: cam_run4 

    Initialize and call variables from the physics buffer, including _old variables. 
    Save buffer variables into "_old" at timestep the model is supposed to back up to
    (currently 00z, 06z, 12z, 18z). Switch buffer variable back to _old version when
    time for model to back up (currently 03z, 09z, 15z, 21z). Turns off clock alarm for
    cam clock out of sync.

**Module** :f:mod:`cam_history.F90`

Source path: components/cam/src/control

.. f:module:: cam_history.F90

.. f:subroutine:: wshist 

    Comment out end run if issue with history file writeout. Allows history files to 
    be overwritten after the model backs up and re-runs with the replay forcing applied.

**Module** :f:mod:`camsrfexch.F90`

Source path: components/cam/src/control

.. f:module:: camsrfexch.F90

.. f:type:: cam_out 

    Define _old variables for cam_out (to coupler) variables.

.. f:type:: cam_in_t

    Define _old variables for cam_in_t (from coupler) variables.  

.. f:subroutine:: hub2atm_alloc 

    Allocate _old cam_in variables as needed.

.. f:subroutine:: hub2atm_dealloc 

    Deallocate _old cam_in variables as needed.

**Module** :f:mod:`runtime_opts.F90`

Source path: components/cam/src/control

.. f:module:: runtime_opts.F90

.. f:subroutine:: read_namelist 

    Read in replay namelist parameters from user_nl_cam.

**Module** :f:mod:`atm_comp_mct.F90`

Source path: components/cam/src/cpl

.. f:module:: atm_comp_mct.F90

.. f:subroutine:: atm_run_mct 

    Save cam_out and cam_in variables into "_old" at timestep the model is supposed to back up to
    (currently 00z, 06z, 12z, 18z). Switch variable back to _old version when
    time for model to back up (currently 03z, 09z, 15z, 21z). Turns off clock alarm for
    cam clock out of sync.

**Module** :f:mod:`replay.F90`

Source path: components/cam/src/physics/cam/

.. f:module:: replay.F90

.. f:subroutine:: replay_readnl 

    Read replay namelist parameters. End job and throw error if namelist parameters not properly
    defined. Send parameters to all processors.

.. f:subroutine:: replay_init

    Process windowing parameters if there are any in the namelist and send the updated values
    to all processors.   

.. f:subroutine:: replay_register 

    Register _old buffer fields used to store buffer information for model reset. 

.. f:subroutine:: read_netcdf_replay 

    Read reanalysis file for replay using file path and name defined in namelist. Only valid 
    for fv grids. 

.. f:function:: interpret_filename_replay

    Interpret reanalysis filename based on template defined in namelist. Requires year, month,
    day, and seconds.

.. f:subroutine:: replay_correction 

    Set state replay forcing variables to 0 during unforced steps (first 3 hours). When time for
    model to reset (currently 03z, 09z, 15z, 21z), calls read of reanalysis file for current time. 
    Calculates difference between model state and reanalysis. Sets state replay forcing variables 
    as that difference. Applies replay forcing as tendency (divided by forcing time, which is
    6 hours in seconds by default) during replay forcing steps.

.. f:subroutine:: replaying_set_profile 

    Set the spatial regions where the replay is being applied using the windowing parameters for
    the 3D replay varaibles. If no windowing parameters, then the full globe will be replayed.

.. f:subroutine:: replaying_set_PSprofile 

    Set the spatial regions where the replay is being applied using the windowing parameters for PS. 
    If no windowing parameters, then the full globe will be replayed.  

**Module** :f:mod:`cam_diagnostics.F90`

Source path: components/cam/src/physics/cam/

.. f:module:: cam_diagnostics.F90

.. f:subroutine:: diag_init_dry 

    Add replay difference fields (SDIFF, QDIFF, UDIFF, VDIFF) to default history outfield lists.

.. f:subroutine:: diag_phys_writeout 

    Call writeout replay difference fields (SDIFF, QDIFF, UDIFF, VDIFF) when other state variables
    are also called. 

**Module** :f:mod:`physics_types.F90`

Source path: components/cam/src/physics/cam/

.. f:module:: physics_types.F90

.. f:subroutine:: physics_state_alloc 

    Define and allocate state type variables (sforce, qforce, vforce, uforce) for applying 
    replay forcing to state.

**Module** :f:mod:`physpkg.F90`

Source path: components/cam/src/physics/cam/

.. f:module:: physpkg.F90

.. f:subroutine:: phys_register 

    Call register replay variables

.. f:subroutine:: phys_run2

    Call replay correction function and physics writeout to save calculated replay forcings.

.. f:subroutine:: tphsbc

    Comment out debug checks so model doesn't crash with replay forcing applied.

**Module** :f:mod:`restart_physics.F90`

Source path: components/cam/src/physics/cam/

.. f:module:: restart_physics.F90

.. f:subroutine:: read_restart_physics 

    Comment out call to read restart file since restart files will not have the right 
    information to restart with a clean replay. 

**Module** :f:mod:`dyn_comp.F90`

Source path: components/cam/dynamics/fv

.. f:module:: dyn_comp.F90

.. f:subroutine:: dyn_init 

    Allocate dyn_in and dyn_out variables that are stored in the buffer.

.. f:subroutine:: dyn_free_interface

    Separate subroutine dyn_free_interface to be public outside of dyn_final
    for use in other functions. Deallocates _old variables as needed.

**Module** :f:mod:`stepon.F90`

Source path: components/cam/dynamics/fv

.. f:module:: stepon.F90

.. f:subroutine:: stepon_run3

    Save dynamics buffer variables into "_old" at timestep the model is supposed to back up to
    (currently 00z, 06z, 12z, 18z). Switch buffer variable back to _old version when
    time for model to back up (currently 03z, 09z, 15z, 21z). Turns off clock alarm for
    cam clock out of sync.

**Module** :f:mod:`pft_module.F90`

Source path: components/cam/dynamics/fv

.. f:module:: pft_module.F90

.. f:subroutine:: pftinit 

    Deallocate variable for model reset.

**Module** :f:mod:`restart_dynamics.F90`

Source path: components/cam/dynamics/fv

.. f:module:: restart_dynamics.F90

.. f:subroutine:: read_restart_dynamics 

    Deallocate restart variables and pointers for model reset. Because of these 
    changes, replay cannot restart automatically from restart variables.

**Module** :f:mod:`spmd_dyn.F90`

Source path: components/cam/dynamics/fv

.. f:module:: spmd_dyn.F90

.. f:subroutine:: spmdinit_dyn

    Deallocate dynamic grid variables as needed. 

**Module** :f:mod:`CMakeLists.txt`

Source path: components/cam/src/physics/cam

.. f:module:: CMakeLists.txt

.. f:subroutine:: CAM source files 

    Include replay.F90 in make file.  

**Module** :f:mod:`namelist_definition.xml`

Source path: components/cam/bld/namelist_files/namelist_definition.xml

.. f:module:: namelist_definition.xml

.. f:subroutine:: Namelist defitions 

    Add definitions for possible namelist parameters defined in user_nl_cam,
    used to configure the replay. 

CICE
----
`CICE github <https://github.com/sweidy/CESM_CICE5>`_

**Module** :f:mod:`CICE_RunMod.F90`

Source path: components/cice/src/drivers/cesm/

.. f:module:: CICE_RunMod.F90

.. f:subroutine:: CICE_Run 

    Add current time as argument. When current time is time for model to back up, 
    subtract 3 hours from CICE time manager. 

**Module** :f:mod:`ice_comp_mct.F90`

Source path: components/cice/src/drivers/cesm/

.. f:module:: ice_comp_mct.F90

.. f:subroutine:: ice_run_mct 

    Save buffer variables into "_old" at timestep the model is supposed to back up to
    (currently 00z, 06z, 12z, 18z). Switch buffer variable back to _old version when
    time for model to back up (currently 03z, 09z, 15z, 21z). Turns off clock alarm for
    cice clock out of sync.

**Module** :f:mod:`ice_flux.F90`

Source path: components/cice/src/source/

.. f:module:: ice_flux.F90

.. f:subroutine:: Module variable declarations

    Define _old variables for active non-zero public buffer variables in the cice.r. 
    file (for the FHIST_DARTC6 compset).

**Module** :f:mod:`ice_state.F90`

Source path: components/cice/src/source/

.. f:module:: ice_state.F90

.. f:subroutine:: Module variable declarations

    Define _old variables for active non-zero public buffer variables in the cice.r. 
    file (for the FHIST_DARTC6 compset).

**Module** :f:mod:`ice_orbital.F90`

Source path: components/cice/src/source/

.. f:module:: ice_orbital.F90

.. f:subroutine:: compute_coszen

    Adjust CICE clock when time for model to restart for calculation of
    coszen based on Earth's orbit. 

**Module** :f:mod:`ice_dyn_shared.F90`

Source path: components/cice/src/source/

.. f:module:: ice_comp_mct.F90

.. f:subroutine:: ice_dyn_shared 

    Deallocate variable in case still has data after model backs up.

CLM
---
`CLM github <https://github.com/sweidy/CTSM>`_

**Module** :f:mod:`various`

Source path: components/clm/src/biogeophys/ and components/clm/src/main/ 

.. f:module:: various

.. f:subroutine:: InitAllocate
    
    Define and allocate _old variables for all non-zero public buffer variables in the clm.r. 
    file (for the FHIST_DARTC6 compset). Also deallocates _old variables for grid-type
    variables if the original buffer variable is also deallocated. Changes in the following files: 

    - Aerosol_Mod.F90
    - CanopyStateType.F90
    - EnergyFluxType.F90
    - FrictionVelocityMod.F90
    - IrrigationMod.F90
    - LakeStateType.F90
    - PhotosynthesisMod.F90
    - SoilHydrologyType.F90
    - SoilStateType.F90
    - SolarAbsorbedType.F90
    - SurfaceAlbedoType.F90
    - TemperatureType.F90
    - WaterStateType.F90
    - WaterfluxType.F90
    - ColumnType.F90
    - LandunitType.F90
    - PatchType.F90
    - atm2lndType.F90

**Module** :f:mod:`lnd_comp_mct.F90`

Source path: components/clm/src/cpl

.. f:module:: lnd_comp_mct.F90

.. f:subroutine:: lnd_run_mct

    Save buffer variables into "_old" at timestep the model is supposed to back up to
    (currently 00z, 06z, 12z, 18z). Switch buffer variable back to _old version when
    time for model to back up (currently 03z, 09z, 15z, 21z). Turns off clock alarm for
    clm clock out of sync. 

