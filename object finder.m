clear; close all; clc;

oriPic = imread('starfish.jpg');
grayPic = rgb2gray(oriPic);
finalPic =zeros(size(grayPic));

normalizedThresholdValue = 0.9; % In range 0 to 1.
thresholdValue = normalizedThresholdValue * max(max(grayPic)); % Gray Levels.
binPic = imbinarize(grayPic, normalizedThresholdValue);    % One way to threshold to binary
binPic = imcomplement(binPic);
binPic = imfill(binPic, 'holes');
binPic = imerode(binPic,strel('disk',4));
binPic = imdilate(binPic,strel('disk',3));

objectMeasurements = regionprops(binPic, grayPic, 'all');%finds the mesurements of the shapes 
numberOfObjects = size(objectMeasurements, 1);
boundaries = bwboundaries(binPic);
allBlobCentroids = [objectMeasurements.Centroid]; %setting the x and y coordinates for the center of each object
centroidsX = allBlobCentroids(1:2:end-1);
centroidsY = allBlobCentroids(2:2:end);

star = 0;
for k = 1 : numberOfObjects
    boundrieOfImageY= boundaries{k}(1:size(boundaries{k},1));
    boundrieOfImageX= boundaries{k}(size(boundaries{k},1)+1:size(boundaries{k},1)+size(boundaries{k},1));
    
    tempX = boundrieOfImageX - centroidsX(k);%find the distance to the edge from the center 
    tempY = boundrieOfImageY - centroidsY(k);
    
    tempXY = tempX + tempY;
    tempXY = abs(tempXY);%absulute make all values postive
    if size(tempXY, 2) < 75
     tempXY = sgolayfilt(tempXY,3,17);%filter the line to smooth out any jaged edges  
    else 
      tempXY = sgolayfilt(tempXY,3,21);% savitzky golay filter
    end 

    x = 0;    
    for y = 2 : size(tempXY, 2)-1        
        if tempXY(y) < tempXY(y+1) && tempXY(y) <= tempXY(y-1)
        x = x +1;
        end 
    end 
    if x == 5 %if there are 5 dips on the image signature then it is a star 
       star = [k ,star]; %add to start of the array    
       sizeOfStar = size(objectMeasurements(k).PixelList, 1);
    for x = 1 : sizeOfStar %loop round each identifies starfish 
        finalPic(objectMeasurements(k).PixelList(x+sizeOfStar), objectMeasurements(k).PixelList(x)) = 1;
        %for each pixel set the pixel in the blank image to 1 
    end
    end   
    tempX=0;
    tempY=0;
end

figure
imshow(finalPic)
title('image showing the isolated starfish');
