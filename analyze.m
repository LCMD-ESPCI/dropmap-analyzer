%% SIMPLE ANALYZER %%
% Assuming vertical beadline
% Requires Matlab R2018b or later
% Requires Image Processing Toolbox
%% SETUP %%
clearvars
data=table;

%% ASK FOR PARAMETERS %%
% Nice dialog box
dlg1Title = 'Enter parameters'; % Dialog box title
dlg1Dims = [1 50]; % Size of dialog box input fields
dlg1Prompt={'Beadline channel(s)','Bright Field channel','Time points','Average droplets radius (px)'}; % Name of prompts
dlg1DefInputs={'1 3','4','3','25'}; % Default values
try
dlg1Answer = inputdlg(dlg1Prompt,dlg1Title,dlg1Dims,dlg1DefInputs); % Makes the dialog box
blIndex=str2num(dlg1Answer{1});
bfIndex=str2num(dlg1Answer{2});
nTime=str2num(dlg1Answer{3});
averageRadius=str2num(dlg1Answer{4});
catch ME
    disp('Cancelled dialog box. Restart the script')
    return    
end
% Gather user inputs into according variables

%% SELECT IMAGE FILE %%
try
[tifFileName,pathName] = uigetfile('*.tif','Select the first image to analyze'); % Select first image file (first time point)
cd(pathName)
catch
    disp('No file selected. Restart script.')
    return
end
tifInfo=imfinfo(tifFileName);
nChannels=size(tifInfo,1);
width=tifInfo.Width;
height=tifInfo.Height;
tic
nameParts=regexp(tifFileName,'\.','split'); % Retrieves core file name
fileName=nameParts{1:end-1};
fileName=fileName(1:end-1); % If multiple time points
cd(fileparts(pathName)); % go to the working directory
imBF=imread(fullfile(pathName,tifFileName),bfIndex); % Read the image
%% DROPLET DETECTION WITH HOUGH ALGORITHM
[centers, radii, ~] = imfindcircles(imBF,[averageRadius*0.8 averageRadius*1.2],'ObjectPolarity','dark','Sensitivity',0.95);

% Clear close to edge droplets
trashIndex=centers(:,2)>(width-averageRadius) | centers(:,2)<averageRadius | centers(:,1)>(height-averageRadius) | centers(:,1)<averageRadius;
centers(trashIndex,:)=[];
radii(trashIndex)=[];
nDrops=length(radii);
data.Index=(1:nDrops)';
data.Centers=centers;  % Store everything in data for convenience
data.Radii=radii;


% Initiate signal variables
for cc=blIndex
    data.(['Beadline' num2str(cc)])=zeros(nDrops,nTime);
    data.(['MeanDrop' num2str(cc)])=zeros(nDrops,nTime);
    data.(['Ratio' num2str(cc)])=zeros(nDrops,nTime);
end
%% TIME LOOP FOR SIGNAL MEASUREMENT
for tt=1:nTime
    for cc=blIndex
        thisFileName = strcat(fileName, num2str(tt), '.tif');
        imF=imread(fullfile(pathName,thisFileName),cc);
        centers2 = data.Centers;
        ngfluo = length(data.Radii) ;
        [n, m]=size(imF);
        [X1,X2] = ndgrid(1:n,1:m);
        for dd=1:nDrops
            dropMask = uint16((X2-centers2(dd,1)).^2 + (X1-centers2(dd,2)).^2<(data.Radii(dd)-1)^2);
            Y=imF.*dropMask;
            [~,~,v] = find(Y);
            data.(['MeanDrop' num2str(cc)])(dd,tt)=mean(v);
            colMean = sum(Y,1) ./ sum(Y~=0,1);
            data.(['Beadline' num2str(cc)])(dd,tt)=max(colMean);
            
        end
    end
end
%% SAVE IMAGES FOR VERIFICATION
for tt=1:nTime
    for cc=1:nChannels
        thisFileName = strcat(fileName, num2str(tt), '.tif');
        imF=imread(fullfile(pathName,thisFileName),cc);
        for dd=1:nDrops
            data.Images{dd,cc,tt}=imcrop(imF,[centers2(dd,:)-averageRadius averageRadius*2 averageRadius*2]);
        end
    end
end
%% CALCULATE RATIOS
for cc=blIndex
    data.(['Ratio' num2str(cc)])=data.(['Beadline' num2str(cc)])./data.(['MeanDrop' num2str(cc)]);
end
%% WRITE THE DATA INTO XLSX FILE & MAT FILE
xlsFileName=[fileName '_data.xlsx'];
jj=0;
for cc=blIndex
    data2=data(:,[1 (4+jj*3):(4+jj*3)+2]);
    writetable(data2,xlsFileName,'Sheet',['Channel ' num2str(cc)]);
    jj=jj+1;
end
writetable(data(:,1:3),xlsFileName,'Sheet','Info');
save([fileName '_data.mat'],'data','-v7.3');
%% DISPLAY DROPLETS DETECTED
figure
imshow(imBF,[])
viscircles(data.Centers,data.Radii);
totalTime=toc;
%% SOME INFO
fprintf('Analysis over, %i droplets detected.\n',nDrops);
fprintf('Total time: %.0fs.\n',totalTime);




