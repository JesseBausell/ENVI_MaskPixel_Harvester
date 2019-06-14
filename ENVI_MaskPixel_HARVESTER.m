% ENVI_MaskPixel_Harvester
% Jesse Bausell
% July 10, 2016
%
%
% This program allows the user to upload masked ENVI imagery files (ascii) into 
% matlab and convert them to .mat/hdf5 files. It organizes these files into two 
% 'structures': 
%
% Inputs:
% ENVI-generated ascii file, BIP interleaved
%
% Outputs:
% MASK_pix - This structure contains the Rrs spectrum for each masked pixel
% ENVI_GRID - THis structure organizes all image pixel values (masked and
% unmasked) in two-dimensional matrices according to their band layers.
%
% Required files:
% SENSOR_Bands.mat
%
% Directions for use:
%
% Inputs:
%
% 1. 'Pick ASCII file' - User will be asked to select an ascii file for
% analysis. This file should be of the .txt file of an image interleaved as
% BIP
%
% 2. 'Left Corner Pixel Coordinates' - In the event that the user cropped
% the Envi Standard File (file from which he/she downloaded the saved ascii
% file), matlab image coordinates will not correspond with the ENVI
% coordinates. This will compensate for the offset. The 'sample' (X) and
% 'line' coordinates for the upper left corner for an ENVI Standard File
% can be found in 'Edit Header' within ENVI Classic.
%
% 3. 'Choose a sensor' - User can choose between AVIRIS, MODIS, Landsat TM
% (Landsat 4 & 5), Landsat 7, and Landsat 8. These terms are case
% sensitive.
%
% 4. 'Enter band numbers' - User must enter the band numbers that his/her
% Envi Standard File (ESF) contains. For example, if the ascii file is saved
% from an AVIRIS ESF that containing bands 10-15 & 20, the user must input
% '10 11 12 13 14 15 20 '. Because these bands are consecutive, the user may
% also input '10:15 20'. The user may input these numbers out of order, as
% long as they are present. 
%
% Failure to do line up the a wavelenght with its proper band number this will create 
% inaccurate pixel Rrs spectra. For each sensor, band numbers and their corresponding 
% wavelengths (as read by MaskPixel_Harvester) are listed below. 
%
% If using landsat 4,5 or 7, user should crop out band 6 and
% bands 8+ in ENVI BEFORE exporting data in an ascii file. If using Landsat
% 8, user should crop out bands 8+ BEFORE exporting data in an ascii file.
% Corresponding sensor band numbers are listed below: 
%
%
% AVIRIS - bands 1-224 correspond to their registered wavelengths
%
% MODIS (may differ from actual band numbers)
%   Band 1 - 412nm
%   Band 2 - 443nm
%   Band 3 - 469nm
%   Band 4 - 488nm
%   Band 5 - 531nm
%   Band 6 - 547nm
%   Band 7 - 555nm
%   Band 8 - 645nm
%   Band 9 - 667nm
%   Band 10- 678nm
%
% Landsat TM (may differ from actual band numbers)
%   Band 1 - 485nm
%   Band 2 - 560nm
%   Band 3 - 660nm
%   Band 4 - 830nm
%   Band 5 - 1650nm
%   Band 6 - 2215nm (band 7 actual)
%
% Landsat 7 (do not use Band 6 or 8)
%   Band 1 - 477.5nm
%   Band 2 - 560nm
%   Band 3 - 661nm
%   Band 4 - 835nm
%   Band 5 - 1648nm
%   Band 6 - 2204.5nm (band 7 actual)
%
% Landsat 8 (do not use Band 8-11)
%   Band 1 - 440nm
%   Band 2 - 480nm
%   Band 3 - 560nm
%   Band 4 - 655nm
%   Band 5 - 865nm
%   Band 6 - 1610nm
%   Band 7 - 2200nm
%
%
% Outputs:
%   MASK_pix.sample - the sample number (ENVI) for individual masked pixels
%   MASK_pix.line - the line number (ENVI) for individual masked pixels
%   MASK_pix.wvl - the wavelengths for individual masked pixels
%   MASK_pix.Rrs - the Rrs spectrum for individual masked pixels
%   (corrsponding to the wavelengths)
%
%   ENVI_GRID.wvl - wavelength corresponding to each masked 'layer'
%   ENVI_GRID.layer - Rrs grid (layer) corresponding to the masked ESF
%   
clear all; close all; clc; 
% Gets rid of any excess variables. 

%% 1. Select the files
% The first section of code guides user in inputting the settings that the
% program is working with. User is asked to choose an ascii file (BIP
% interleaved), indicate reference coordinates, indicate which sensor the
% ascii file is from, and indicate which sensor-specific band numbers the
% asii file contains.

disp('Pick ASCII file'); % Asks user to select ascii file
[file_NAME, dir_NAME] = uigetfile('.txt'); clc; % User selects ascii file; command window cleared
disp('Left Corner Pixel Coordinates'); % Asks user to pick reference coordinates for upper left-hand corner
sample_corner = input('sample coordinate: ')-1; % Input reference coordinate for columns (samples)
line_corner = input('line coordinate: ')-1; clc; % Input reference coordinate for lines (rows)
disp('Choose a sensor: AVIRIS, MODIS, Landsat TM, Landsat 7, or Landsat 8'); % Asks user to choose a sensor
Inst_NAME = input('Sensor Name: ','s'); clc; % Input sensor with which you are working 
disp('Enter Band numbers in your file. You may use a colon to truncate arrays.'); % Asks user to input sensor's band numbers
Band_NUM = input('Bands: ','s'); % Input band numbers
Band_NUM = str2num(Band_NUM); % Convert band number input into a double array
Band_NUM = sort(Band_NUM,2,'ascend'); % Sort band numbers by ascending order
% Select file for wavelengths

%% 2. Disect the ASCII file and figure out the dimensions

fid_M = fopen([dir_NAME file_NAME]); % Open ascii file and assign file identifier
fgetl(fid_M); fgetl(fid_M); % discard the first two (header) lines of the file
headerLINE = fgetl(fid_M); % get header line with dimension numbers
ascii_DIMS = regexpi(headerLINE,'\d'); %find integer indices in the third header line

dimIND = nan(2,1); % empty NaN array for spatial dimension values of ascii file (# rows and # columns)
key = 1; % Reference variable for for-loop

for hh = 1:length(ascii_DIMS)-1
    % This particular for-loop cycles through integers on the third
    % header line to figure out if they are adjacent to each other
    % (based on index differences being equal or greater than 1. It
    % uses this system to determine number of columns, rows, and wavelengths.

    diff =  ascii_DIMS(hh+1) - ascii_DIMS(hh); % Difference between successive integers

    if diff > 1
        % If two successive integers are NOT adjacent
        dimIND(key) = hh+1; % set one of the dimension array values
        key = key + 1; % increase reference variable by 1
    end
end
     
coL = str2num(headerLINE(ascii_DIMS(1:dimIND(1)-1))); % determine number of columns
roW = str2num(headerLINE(ascii_DIMS(dimIND(1):dimIND(2)-1))); % determine number of rows
wvS = str2num(headerLINE(ascii_DIMS(dimIND(2):end))); % determine number of wavelengths      
fgetl(fid_M); % discard row after third header
    
%% 3. Now we re-organize ascii data into a 3D matrix 
% This section creates a 3D matrix (lat x lon x band). This will later be
% "sliced" into spatial grids for each wavelength (band number). It will
% also be subsectioned by spectra-containing pixels.

if ~isequal(length(Band_NUM),wvS)
    % This if-statement is a preliminary check to make sure that user
    % indicated the correct number of bands compared to the ascii file. If
    % user did not select the correct number of bands, an error is
    % generated.
    error('The number of bands input by the user must be the same as the number of bands in the ASCII file'); % error message
end
        
load('SENSOR_Bands'); % Load .mat file containing sensor-specific band information
instrumenTS = {'AVIRIS';'MODIS';'Landsat TM';'Landsat 7';'Landsat 8'}; % cell array with sensor names
inst_IND = strmatch(Inst_NAME,instrumenTS)+1; % Match user-input sensor name with sensor "position" in cell array
column2 = SENSOR_Bands(:,inst_IND); % Find wavelengths using column index

column2_IND = find(isnan(column2) == 0); % Substitute nan values for zeros
% Create array with two columns and multiple rows. One column is band
% number, the other is band wavelength (line below).
SENSOR_Bands = [SENSOR_Bands(column2_IND,1) column2(column2_IND)]; 
Rrs_MATRIX = nan(roW,coL,length(SENSOR_Bands)); % Create 3D matrix for ascii values 

for ii = 1:roW
    % This for-loop takes ascii value on each row one at a time. It then takes
    % subsections of rows and columns to create 2D numerical grids (lat x
    % lon) for each wavelength/band#. 
    
    fgetl(fid_M); punch_LINE = fgetl(fid_M); % Extract values for every other row
    punch_LINE = str2num(punch_LINE); % Create double out of string array

    for jj = 1:coL
        % All values for a given 2D grid (one for each band) are locked in
        % a single row. This for-loop indexes these values into the correct
        % grid position. It works one value at a time.
        Rrs_MATRIX(ii,jj,Band_NUM) = punch_LINE((jj-1)*wvS+1:jj*wvS); % 3D matrix          
    end
end
    
%% 4. Now we create a structure for masked pixels and their spectra (MASK_pix)

for kk = 1:length(Band_NUM)
    % For-loop cycles through 3D matrix wavelength by wavelength. It does
    % this "slice by slice" with each slice representing a 2D latxlon grid.

    pixeL_IND = find(Rrs_MATRIX(:,:,Band_NUM(kk)) > 0); % Find index of masked pixels in sliced grid
    if ~isempty(pixeL_IND)
        % If there are masked pixels containing real, non-zero Rrs values,
        % execute the for-loop directly below:
            for ll = 1:length(pixeL_IND)
                  % This for-loop cycles through all "masked" pixels
                  % (pixels with Rrs values) and organizes them into
                  % MASK_pix structure. This structure gives user the x,y
                  % coordinates, wavelengths, and Rrs spectum for each
                  % masked pixel.
                  MASK_pix(ll).sample = ceil(pixeL_IND(ll)/roW)+sample_corner; % pixel x-coordinate (column) 
                  MASK_pix(ll).line = pixeL_IND(ll) - ((MASK_pix(ll).sample-sample_corner-1)*roW)+line_corner; % pixel y-coordinate (row) 
                  MASK_pix(ll).wvl = SENSOR_Bands(:,2); % array of pixel wavelenghts
                  Rrs = Rrs_MATRIX(MASK_pix(ll).line-line_corner,MASK_pix(ll).sample-sample_corner,:); % "Drill" into 3D array and pick out pixel Rrs spectrum 
                  MASK_pix(ll).Rrs = Rrs(:); % Add pixel spectrum to structure
            end        
        break % break for-loop (I admit that this is redundant, but because it's always been here I don't want to get rid of it)       
    end
end

%% 5. Now we create a structure for 2d spatial grids (one for each wavelength).

for mm = 1:length(Band_NUM)
    % Creates spatial grids (lat x lon) for each band/wavelength, one
    % sensor band at a time
    ENVI_GRID(mm).wvl = SENSOR_Bands(Band_NUM(mm),2); % For each element, indicate wavelength
    ENVI_GRID(mm).layer = Rrs_MATRIX(:,:,Band_NUM(mm)); % 2D "slice" of 3D Rrs_MATRIX
end

%% 6. Save structures as a .mat/hdf5 file
% This file will contain both ENVI_GRID and MASK_pix structures, pixeL_IND
% to indicate indices of masked pixels, and line_corner and sample_corner,
% which indicate the reference coordinates of x and y pixels relative to
% ENVI image file.
save([dir_NAME file_NAME(1:end-4) '_pixels'],'ENVI_GRID','MASK_pix','pixeL_IND','line_corner','sample_corner','-v7.3');
clear all; close all; clc; % clear variables, close any open files/figures/clear command window