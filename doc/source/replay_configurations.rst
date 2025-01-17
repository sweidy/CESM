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

Replay_coef_U
       type="real" category="replay", group="replay_nl"
         U Coeffcient for replay -- usually 1 (full forcing) or 0 (no forcing)
         [0.,1.] fraction of nudging tendency applied.

         Default: 1.

Replay_coef_V
       type="real" category="replay", group="replay_nl"
         V Coeffcient for replay -- usually 1 (full forcing) or 0 (no forcing)
         [0.,1.] fraction of nudging tendency applied.

         Default: 1.

Replay_coef_T
       type="real" category="replay", group="replay_nl"
         T Coeffcient for replay -- usually 1 (full forcing) or 0 (no forcing)
         [0.,1.] fraction of nudging tendency applied.

         Default: 1.

Replay_coef_Q
       type="real" category="replay", group="replay_nl"
         Q Coeffcient for replay -- usually 1 (full forcing) or 0 (no forcing)
         [0.,1.] fraction of nudging tendency applied.

         Default: 1.

Replay_coef_PS
       type="real" category="replay", group="replay_nl"
         PS Coeffcient for replay -- usually 1 (full forcing) or 0 (no forcing)
         [0.,1.] fraction of nudging tendency applied.

         Default: 1.

Replay_Hwin_lat0
       type="real" category="replay", group="replay_nl"
         LAT0 center of Horizontal Window in degrees [-90.,90.].
       
         Default: 0

Replay_Hwin_latWidth
       type="real" category="replay", group="replay_nl"
         Width of LAT Window in degrees.
       
         Default: 9999 (all latitudes)

Replay_Hwin_latDelta
       type="real" category="replay", group="replay_nl"
         Width of transition which controls the steepness of window transition in latitude.
         0. --> Step function
       
         Default: 1

Replay_Hwin_lon0
       type="real" category="replay", group="replay_nl"
         LON0 center of Horizontal Window in degrees [0.,360.].
         
         Default: 180

Replay_Hwin_lonWidth
       type="real" category="replay", group="replay_nl"
         Width of LON Window in degrees.
         
         Default: 9999 (all longitudes)

Replay_Hwin_lonDelta
       type="real" category="replay", group="replay_nl"
         Width of transition which controls the steepness of window transition in longitude.
          0. --> Step function
       
         Default: none

Replay_Hwin_Invert
       type="real" category="replay", group="replay_nl"
         Invert Horizontal Window Function to its Compliment.
         TRUE  = value=0 inside the specified window, 1 outside (unforced model within window, replay outside)
         FALSE = value=1 inside the specified window, 0 outside (replay within window, unforced model outside)
         
         Default: FALSE

Replay_Vwin_Hindex
       type="real" category="replay", group="replay_nl"
         HIGH Level Index for Verical Window specified in terms of model level indices.
         (e.g. For a 30 level model, Replay_Vwin_Hindex ~ 30 ).
         For CAM, this is the bound closer to the surface
         
         Default: Vertical levels + 1

Replay_Vwin_Hdelta
       type="real" category="replay", group="replay_nl"
         Width of transition for HIGH end of Vertical Window.
         
         Default: 0.001

Replay_Vwin_Lindex
       type="real" category="replay", group="replay_nl"
         LOW Level Index for Verical Window specified in terms of model level indices.
         (e.g. Replay_Vwin_Lindex ~ 0 )
         For CAM, this is the bound closer to the top of atmosphere.
         
         Default: 0

Replay_Vwin_Ldelta
       type="real" category="replay", group="replay_nl"
         Width of transition for LOW end of Vertical Window.
         
         Default: 0.001

Replay_Vwin_Invert
       type="real" category="replay", group="replay_nl"
         Invert Vertical Window Function to its Compliment.
         TRUE  = value=0 inside the specified window, 1 outside
         FALSE = value=1 inside the specified window, 0 outside
         
         Default: FALSE

Replay_Uprof
       type="real" category="replay", group="replay_nl"
         Profile index for U replaying.
         0 == OFF      (No replaying of this variable)
         1 == CONSTANT (Spatially Uniform Replaying)
         2 == HEAVISIDE WINDOW FUNCTION (Use windowing)
         
         Default: 1

Replay_Vprof
       type="real" category="replay", group="replay_nl"
         Profile index for V replaying.
         0 == OFF      (No replaying of this variable)
         1 == CONSTANT (Spatially Uniform Replaying)
         2 == HEAVISIDE WINDOW FUNCTION (Use windowing)
         
         Default: 1

Replay_Tprof
       type="real" category="replay", group="replay_nl"
         Profile index for T replaying.
         0 == OFF      (No replaying of this variable)
         1 == CONSTANT (Spatially Uniform Replaying)
         2 == HEAVISIDE WINDOW FUNCTION (Use windowing)
         
         Default: 1

Replay_Qprof
       type="real" category="replay", group="replay_nl"
         Profile index for Q replaying.
         0 == OFF      (No replaying of this variable)
         1 == CONSTANT (Spatially Uniform Replaying)
         2 == HEAVISIDE WINDOW FUNCTIO (Use windowing)N
         
         Default: 1

Replay_PSprof
       type="real" category="replay", group="replay_nl"
         Profile index for PS replaying.
         0 == OFF      (No replaying of this variable)
         1 == CONSTANT (Spatially Uniform Replaying)
         2 == HEAVISIDE WINDOW FUNCTIO (Use windowing)N
         
         Default: 0