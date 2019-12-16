%% SIMPLE ANALYZER %%
% Assuming vertical beadline & uint16 images
% Provide .tif files (one per time point)
% Name them like this: name1.tif name2.tif for all time points
% Before launching analysis you should know:
%   beadline channel indexes
%   bright field channel index
%   average droplet radius in px
% INPUT: .tif files
% OUTPUT: .xlsx file & .mat file
% This program is meant to process small size images <4000*4000px²
% Indeed Hough algorithm is not efficient for large images
% So for big images you would need to crop them programatically and add a
% loop
% Requirements: 
%   'MATLAB','9.6';
%   'Image Processing Toolbox','10.4'
%% SETUP %%
clear all
data=table;

%% ASK FOR PARAMETERS %%
% Nice dialog box
dlg1Title = 'Enter parameters'; % Dialog box title
dlg1Dims = [1 50]; % Size of dialog box input fields
dlg1Prompt={'Beadline channel(s) (Measurement)','Bright Field channel (Droplet Detection)','NUmber of time points','Average droplet radius (px)'}; % Name of prompts
dlg1DefInputs={'2 3','4','3','25'}; % Default values
dlg1Answer = inputdlg(dlg1Prompt,dlg1Title,dlg1Dims,dlg1DefInputs); % Makes the dialog box
% Gather user inputs into according variables
blIndex=str2num(dlg1Answer{1});
bfIndex=str2num(dlg1Answer{2});
nTime=str2num(dlg1Answer{3});
averageRadius=str2num(dlg1Answer{4});
%% SELECT IMAGE FILE %%
[tifFileName,pathName] = uigetfile('*.tif','Select the first image to analyze'); % Select first image file (first time point)
nameParts=regexp(tifFileName,'\.','split'); % Retrieves core file name
fileName=nameParts{1:end-1};
fileName=fileName(1:end-1); % If multiple time points
cd(fileparts(pathName)); % go to the working directory
tic
imBF=imread(fullfile(pathName,tifFileName),bfIndex); % Read the image
% Need to know image size
xMax=size(imBF,2);
yMax=size(imBF,1);
%% DROPLET DETECTION WITH HOUGH ALGORITHM
disp('Looking for dark circles')
[centers, radii, ~] = imfindcircles(imBF,[round(averageRadius*0.7) round(averageRadius*1.3)],'ObjectPolarity','dark','Sensitivity',0.93); % Main function
data.Index=[1:length(radii)]'; % Store everything in data for convenience
data.Centers=centers;  % Store everything in data for convenience
data.Radii=radii;  % Store everything in data for convenience
% Filter droplets too close to border
border=averageRadius*1.2;
data(border>data.Centers(:,1) | data.Centers(:,1)>xMax-border,:)=[];
data(border>data.Centers(:,2) | data.Centers(:,2)>yMax-border,:)=[];
% Initiate signal variables
nDrops=length(data.Radii);
fprintf('Found %i drops\n',nDrops);
for cc=blIndex
    data.(['Beadline' num2str(cc)])=zeros(nDrops,nTime);
    data.(['MeanDrop' num2str(cc)])=zeros(nDrops,nTime);
    data.(['Ratio' num2str(cc)])=zeros(nDrops,nTime);
end
%% TIME LOOP FOR SIGNAL MEASUREMENT
disp('Starting time loop')
dropMask=cell(1,nDrops); % to store masks for each droplet
for tt=1:nTime
    
    thisFileName = strcat(fileName, num2str(tt), '.tif'); % Open relevant image
    % Calculate masks
    if tt==1
        [n, m]=size(imBF);
        [X1,X2] = ndgrid(1:n,1:m);
        for dd=1:nDrops
            dropMask{dd} = (X2-centers(dd,1)).^2 + (X1-centers(dd,2)).^2<(data.Radii(dd)-1)^2;
        end
    end
    % Signal measurement
    for cc=blIndex
        fprintf('Time %i | Channel %i\n',tt,cc);
        imF=imread(fullfile(pathName,thisFileName),cc);
        for dd=1:nDrops
            Y=imF.*uint16(dropMask{dd}); % Mask the image
            [~,~,v] = find(Y); %  Keep only droplet pixel values
            data.(['MeanDrop' num2str(cc)])(dd,tt)=mean(v); % compute mean
            colMean = sum(Y,1) ./ sum(Y~=0,1); % Compute column means
            %Change 1 to 2 if beadline is horizontal
            data.(['Beadline' num2str(cc)])(dd,tt)=max(colMean); % Find highest colum mean    
        end
    end
end
%% CALCULATE RATIOS
disp('Calculating ratios')
for cc=blIndex
    data.(['Ratio' num2str(cc)])=data.(['Beadline' num2str(cc)])./data.(['MeanDrop' num2str(cc)]);
end
%% WRITE THE DATA INTO XLSX FILE & MAT FILE
dateName=datestr(now,'yymmdd_HHMM'); % For unique filenames
csvName=[dateName '_' fileName '_data.csv']; % To store data
% writetable(data(:,1:3),xlsFileName,'Sheet','Info'); % Write positions in Excel file in case
writetable(data,csvName,'Delimiter',';');
save([dateName '_' fileName '_data.mat'],'data','-v7.3');
%% DISPLAY DROPLETS DETECTED
figure
imshow(imBF,[])
viscircles(data.Centers,data.Radii);
totalTime=toc;
%% SOME INFO
fprintf('Analysis over, %i droplets detected.\n',nDrops);
fprintf('Total time: %.0fs.\n',totalTime);




