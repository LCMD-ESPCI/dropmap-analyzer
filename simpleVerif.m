%% SIMPLE VERIF %%
% Requires Matlab R2018b or later
% Requires Image Processing Toolbox
clearvars
try
[xlsFileName,pathName] = uigetfile('*.xls;*.xlsx','Select the datasheet to verify'); % Select Excel file
cd(pathName)
sheetArray=selectExcelSheet(xlsFileName,pathName,'Single','Verify');
dropIdx=sheetArray{1}(:,1)';
catch
    disp('No file or datasheet selected. Restart script.')
    return
end

try
[matFileName,pathName] = uigetfile('*.mat','Select the MAT file'); % Select Excel file
cd(pathName)
load(matFileName)
catch
    disp('No file selected. Restart script.')
    return
end

nChannels=size(data.Images,2);
nTime=size(data.Images,3);
for dd=dropIdx
    figure(111)
    hold on
    for tt=1:nTime
        for cc=1:nChannels
            subplot(nTime,nChannels,nChannels*(tt-1)+cc)
            imshow(data.Images{dd,cc,tt},[])
            title(sprintf('D=%i T=%i C=%i',dd,tt,cc))
        end
    end
    try
    k=waitforbuttonpress;
    catch
        disp('Verification over')
    end
end
disp('Verification over')