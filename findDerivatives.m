function [Mag, Magx, Magy, Ori] = findDerivatives(I_gray)
%%  Description
%       compute gradient from grayscale image 
%%  Input: 
%         I_gray = (H, W), double matrix, grayscale image matrix 
%
%%  Output:
%         Mag  = (H, W), double matrix, the magnitued of derivative%  
%         Magx = (H, W), double matrix, the magnitude of derivative in x-axis
%         Magx = (H, W), double matrix, the magnitude of derivative in y-axis
% 				Ori = (H, W), double matrix, the orientation of the derivative
%
%% ****YOU CODE STARTS HERE**** 
%Define Sobel operators for calculation of horizontal and vertical
%derivatives
 dx=[-1,0,1;
     -2,0,2;
     -1,0,1];
 dy=[1,2,1;
     0,0,0;
     -1,-2,-1];
%Define standard deviation of guassian filter 
sigma=1; 
%Smooth the image with gaussian filter
I_gray=double(imgaussfilt(I_gray,sigma));
%Compute horizontal derivative 
Magx = imfilter(I_gray, double(dx),'conv', 'replicate');
%Compute vertical derivative
Magy = imfilter(I_gray, double(dy),'conv', 'replicate');
%Compute magnitude of derivatives
Mag=sqrt(Magx.^2+Magy.^2);
%Compute orientation of derivatives
Ori=atan2(Magy, Magx);

end