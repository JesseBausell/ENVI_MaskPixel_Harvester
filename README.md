# ENVI_MaskPixel_Harvester
Reconfigures ENVI imagery data (ascii file) for analysis using a data science programing language (e.g. Matlab or Python)

Sometimes ENVI users would prefer analyzing a masked image (or a image subset) with a programing language that is not IDL. For this purpose, ENVI allows user to download masked imagery data as ascii files. However these files are often exceedingly large; furthermore, their formatting is extremely confusing. This makes the task of organizing imagery data especially daunting. Fortunately, ENVI_MaskPixel_Harvester reconfigures ENVI-generated ascii data into easy-to-use Matlab structures/python dictionaries. It organizes imagery in two ways: 1. It isolates masked pixels in "regions of interest" (ROIs) allowing users easy access to reflectance (Rrs) spectra of all masked pixels while discarding pixels outside masks, 2. It compiles data spatially by band/wavelength (including both masked and unmasked regions of the original image).

Inputs:
ENVI-generated ascii file, BIP interleaved

Outputs:
MASK_pix - This structure contains the Rrs spectrum for each masked pixel
ENVI_GRID - THis structure organizes all image pixel values (masked and
unmasked) in two-dimensional matrices according to their band layers.

Required files:
SENSOR_Bands.mat

Directions for use:

1. 'Pick ASCII file' - User will be asked to select an ascii file for
analysis. This file should be of the .txt file of an image interleaved as
BIP

2. 'Left Corner Pixel Coordinates' - In the event that the user cropped
the Envi Standard File (file from which he/she downloaded the saved ascii
file), matlab image coordinates will not correspond with the ENVI
coordinates. This will compensate for the offset. The 'sample' (X) and
'line' coordinates for the upper left corner for an ENVI Standard File
can be found in 'Edit Header' within ENVI Classic.

3. 'Choose a sensor' - User can choose between AVIRIS, MODIS, Landsat TM
(Landsat 4 & 5), Landsat 7, and Landsat 8. These terms are case
sensitive.

4. 'Enter band numbers' - User must enter the band numbers that his/her
Envi Standard File (ESF) contains. For example, if the ascii file is saved
from an AVIRIS ESF that containing bands 10-15 & 20, the user must input
'10 11 12 13 14 15 20 '. Because these bands are consecutive, the user may
also input '10:15 20'. The user may input these numbers out of order, as
long as they are present. 

Failure to do line up the a wavelenght with its proper band number this will create 
inaccurate pixel Rrs spectra. For each sensor, band numbers and their corresponding 
wavelengths (as read by MaskPixel_Harvester) are listed below. 

If using landsat 4,5 or 7, user should crop out band 6 and
bands 8+ in ENVI BEFORE exporting data in an ascii file. If using Landsat
8, user should crop out bands 8+ BEFORE exporting data in an ascii file.
Corresponding sensor band numbers are listed below: 


AVIRIS - bands 1-224 correspond to their registered wavelengths

MODIS (may differ from actual band numbers)
  Band 1 - 412nm
  Band 2 - 443nm
  Band 3 - 469nm
  Band 4 - 488nm
  Band 5 - 531nm
  Band 6 - 547nm
  Band 7 - 555nm
  Band 8 - 645nm
  Band 9 - 667nm
  Band 10- 678nm

Landsat TM (may differ from actual band numbers)
  Band 1 - 485nm
  Band 2 - 560nm
  Band 3 - 660nm
  Band 4 - 830nm
  Band 5 - 1650nm
  Band 6 - 2215nm (band 7 actual)

Landsat 7 (do not use Band 6 or 8)
  Band 1 - 477.5nm
  Band 2 - 560nm
  Band 3 - 661nm
  Band 4 - 835nm
  Band 5 - 1648nm
  Band 6 - 2204.5nm (band 7 actual)

Landsat 8 (do not use Band 8-11)
  Band 1 - 440nm
  Band 2 - 480nm
  Band 3 - 560nm
  Band 4 - 655nm
  Band 5 - 865nm
  Band 6 - 1610nm
  Band 7 - 2200nm


Outputs:
  MASK_pix.sample - the sample number (ENVI) for individual masked pixels
  MASK_pix.line - the line number (ENVI) for individual masked pixels
  MASK_pix.wvl - the wavelengths for individual masked pixels
  MASK_pix.Rrs - the Rrs spectrum for individual masked pixels
  (corrsponding to the wavelengths)

  ENVI_GRID.wvl - wavelength corresponding to each masked 'layer'
  ENVI_GRID.layer - Rrs grid (layer) corresponding to the masked ESF
