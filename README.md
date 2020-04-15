# dropmap-analyzer
Monitor antibody or cytokine secretion of single cells in droplets over time
## Requirements: 
- 'MATLAB','9.6'
- 'Image Processing Toolbox','10.4'
## analyze.m: Analyze your images and measure droplet signal (with beadline assay)
### Before launching analysis you should know:
   - Beadline channel indexes
   - Bright field channel index
   - Average droplet radius in px
### INPUT: .tif files ( One per time point with vertical beadline & uint16 pixels)
Name them as follows: "name1.tif" "name2.tif" for all time points, like the example
### OUTPUT: .xlsx file & .mat file
### NOTE
This program is meant to process small size images (<4000\*4000px² typically)
It needs to be adapted for larger images and will take too much time.
For bigger images I would advice to crop them programatically and add a loop on sub-images.
Or you could use regionprops function on a binarized image which scales better.
## verify.m: Check droplets visually
### Before launching verification:
   - Process your data as required and know the droplets you want to check visually.
   - Save the indexes of these droplets of interest in a new datasheet. (You need to know the name of the datasheet)
   - This should be a one column datasheet comprised only of said indexes with no space inbetween rows
### INPUT: .xlsx file & .mat file
   - Select the Excel file and MAT file of interest.
   - Select the datasheet you saved the indexes in.
### NOTE
This program will display for each droplet the image in each channel for each time point of your experiment.
You can check the next droplet by clicking or pressing any key on your keyboard.
## Example image info:
- Cells: PBMCs
- Channel 1: TNFalpha - PE (beadline assay)
- Channel 2: CD3 - AF488
- Channel 3: INFgamma - AF647 (beadline assay)
- Channel 4: Bright field 
