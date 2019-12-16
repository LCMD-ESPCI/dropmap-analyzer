# dropmap-analyzer
Monitor antibody or cytokine secretion of single cells in droplets over time
## Requirements: 
- 'MATLAB','9.6'
- 'Image Processing Toolbox','10.4'
## Before launching analysis you should know:
   - Beadline channel indexes
   - Bright field channel index
   - Average droplet radius in px
## INPUT: .tif files ( One per time point with vertical beadline & uint16 pixels)
    Name them as follows: "name1.tif" "name2.tif" for all time points, like the example
## OUTPUT: .xlsx file & .mat file
This program is meant to process small size images (<4000\*4000px² typically)
Indeed, Hough algorithm is not efficient for larger images and will take too much time.
For bigger images I would advice to crop them programatically and add a loop on sub-images.
Or you could use regionprops function on a binarized image which scales much better.

## Example image info:
- Cells: PBMCs
- Channel 1: TNFalpha - PE (beadline assay)
- Channel 2: CD3 - AF488
- Channel 3: INFgamma - AF647 (beadline assay)
- Channel 4: Bright field 
