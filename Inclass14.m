%Inclass 14

%Work with the image stemcells_dapi.tif in this folder

% (1) Make a binary mask by thresholding as best you can
file1= 'stemcells_dapi.tif' 
reader = bfGetReader(file1);
imshow(reader)
% Check the C, Z, and T: 
reader.getSizeC;
reader.getSizeZ;
reader.getSizeT; 
% They are all 1. 
% get index
chan = 1;
zplane = 1;
time = 1;
iplane1 = reader.getIndex(chan-1, zplane-1, time-1) +1 
img1 = bfGetPlane(reader, iplane1);
% have a look at the image
imshow(img1, [200 1000]);
% use function made in HW4 -> smooth_substract
img1_corr= smooth_substract (img1, 1, 2, 100); 
imshow(img1_corr, [0, 1000]) % doesnt look improved, but I will just carry on. Maybe the original image is processed. 
% simple maksing; make a loop to see which threshold value works the best, 
for i = 50:50:500
xmask1 = img1_corr > i;
figure 
imshow(xmask1)
end 
% i = 100 worked the best
xmask1 = img1_corr > 100;
imshow(xmask1)

% (2) Try to separate touching objects using watershed. Use two different
% ways to define the basins. (A) With erosion of the mask (B) with a
% distance transform. Which works better in this case?
%Method A%
CC = bwconncomp(xmask1);
stats = regionprops(CC, 'Area');
area = [stats.Area];
fusedCandidates = area>mean(area) + std(area); 
sublist = CC.PixelIdxList(fusedCandidates);
sublist = cat(1, sublist{:}); 
fusedMask = false(size(xmask1));
fusedMask(sublist) = 1; 
imshow(fusedMask, 'InitialMagnification', 'fit')
title('fusedmask')
%eroding the centers
s = round(1.2*sqrt(mean(area))/pi);
nucmin = imerode(fusedMask,strel('disk',s));
imshow(nucmin,'InitialMagnification', 'fit');
title('nucmin') 
%getting the regions outside
outside = ~imdilate(fusedMask, strel('disk',1));
imshow(outside, 'InitialMagnification', 'fit');
title('outside') 
%define basin for watershed
basin = imcomplement(bwdist(outside));
basin= imimposemin(basin, nucmin | outside); 
L = watershed(basin); 
imshow(L); colormap('jet'); caxis([0 20]);
%combining mask
newMask = L>1 | (xmask1 - fusedMask); 
imshow(newMask, 'InitialMagnification', 'fit');
%Method B%
D = bwdist (~xmask1);
figure
imshow(D, [], 'InitialMagnification', 'fit');
D = -D;
D(~xmask1) = -Inf; 
figure 
imshow(D, [], 'InitialMagnification', 'fit');
L = watershed (D);
L (~xmask1) = 0; 
rgb = label2rgb (L, 'jet', [.5 .5 .5]);
imshow(rgb, 'InitialMagnification', 'fit');
title('Watershed trial') 
figure 
imshow(xmask1)% for comparison 
title('just mask')

% both of them didnot work as good as the example in the lecture notes. 
% Method A worked slightly better. 

