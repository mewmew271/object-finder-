% MATLAB script for Assessment Item-1
% Task-4
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

imshow(binPic)
title('image showing all of the objects')
%highlights the borders of the shapes 
hold on;
boundaries = bwboundaries(binPic);
numberOfBoundaries = size(boundaries, 1);
for k = 1 : numberOfBoundaries
	thisBoundary = boundaries{k};
	plot(thisBoundary(:,2), thisBoundary(:,1), 'r', 'LineWidth', 2);
    
end

%finds the center of each shape
allBlobCentroids = [objectMeasurements.Centroid]; %setting the x and y coordinates for the center of each object
centroidsX = allBlobCentroids(1:2:end-1);
centroidsY = allBlobCentroids(2:2:end);
for k = 1 : numberOfObjects           % Loop through all objects.
	text(centroidsX(k)- 9, centroidsY(k), num2str(k), 'FontSize', 12, 'FontWeight', 'Bold', 'color', 'green'); 
    %puts a X in the center of each object 
end

hold off;
figure
star = 0;
for k = 1 : numberOfBoundaries
    boundrieOfImageY= boundaries{k}(1:size(boundaries{k},1));
    boundrieOfImageX= boundaries{k}(size(boundaries{k},1)+1:size(boundaries{k},1)+size(boundaries{k},1));
    
    tempX = boundrieOfImageX - centroidsX(k);%find the distance to the edge from the center 
    tempY = boundrieOfImageY - centroidsY(k);
    
    tempXY = tempX + tempY;
    tempXY = abs(tempXY);%absulute make all values postive
    if size(tempXY, 2) < 75
     tempXY = sgolayfilt(tempXY,3,17);%filter the line to smooth out any jaged edges  
    else 
      tempXY = sgolayfilt(tempXY,3,21);
    end 
%     plot(tempY, tempX)%not need plots the shape 
   
    x = 0;    
    for y = 2 : size(tempXY, 2)-1        
        if tempXY(y) < tempXY(y+1) && tempXY(y) <= tempXY(y-1)
        x = x +1;
        end 
    end 
    if x == 5 %if there are 5 dips on the image signature then it is a star 
       star = [k ,star]; %add to start of the array
       plot(1 : size(boundrieOfImageX,2), tempXY)%plot the shape signiture of matching shape 
       title('Image signatures of one of the detected starfish');
    end   
    tempX=0;
    tempY=0;
end

for y = 1 : size(star, 2)-1
    sizeOfStar = size(objectMeasurements(star(y)).PixelList, 1);
    for x = 1 : sizeOfStar %loop round each identifies starfish 
        finalPic(objectMeasurements(star(y)).PixelList(x+sizeOfStar), objectMeasurements(star(y)).PixelList(x)) = 1;
        %for each pixel set the pixel in the blank image to 1 
    end
end

figure
imshow(finalPic)
title('image showing the isolated starfish');
