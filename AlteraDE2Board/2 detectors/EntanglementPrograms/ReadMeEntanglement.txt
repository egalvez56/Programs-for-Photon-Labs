Two programs:
   HWPPumpEntanglementTuneAltera
The entangled state HH+VV needs equal amounts of HH and VV. This program rotates the waveplate that determines the ratio of HH and VV. This scan allows one to find the setting of the waveplate that equalizes HH and VV.

   RotationScanQuadraticfitAltera
The phase between HH and VV should be zero. When this is so, the state is also DD + AA. Thus, there should be no coincidences when detecting DA. The tilt of a quartz plate controls this, allowing the program to find the setting where DA counts are a minimum.

   SimpleMeasurementVR623noQWP.m
This program is a quick inspection of the entangled state of the light, taking data by automatically rotating the HWPs for the two photons to measure HH, HV, VH, VV, DD, DA, AA, AD. The entangled state is achieved when:
--we get high coincidence counts for: HH, VV, DD, AA 
--minimum or zero counts for HV, VH, AD, DA