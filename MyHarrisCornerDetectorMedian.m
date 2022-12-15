% My Harris detector
% The code calculates
% the Harris Feature/Interest Points (FP or IP) 

% When you execute the code, the test image file will open
% then the code will print out and display the feature points.
% You can control the number of FPs by changing some parameters e.g. threshold

%%%
% corner: significant change in all direction for a sliding window
%%%

%%
% parameters
% corner response related
sigma = 2;
n_x_sigma = 6;
alpha = 0.04;       % empirical chosen as 0.04 to get calculate each element of R (corner response)

% maximum suppression related
threshold = 20;%20     % should be between 0 and 1000
r = 6;%6

%%
% filter kernels
dx = [1 0 -1; 2 0 -2; 1 0 -1];      % horizontal gradient filter 
dy = dx';                           % vertical gradient filter


%% load 'Im.jpg'
frame = imread('../data/Im.jpg');

%% Call FindCorners function
[I, r1, c1] = FindCornersMedian(frame, dx, dy, threshold, r, alpha);

%% Display
figure;
imshow(I);
hold on;
plot(c1,r1,'or');


function [I, row, col] = FindCornersMedian(frame, dx, dy, threshold, r, alpha)
%% Input
% frame: image read from source
% dx: horizontal gradient filter
% dy: vertical gradient filter
% g: Gaussian filter (filter size: 2*n_x_sigma*sigma)
% threshold: threshold for finding local maximum (0 ~ 1000)
% r: ordfilt2 neighbor range
% alpha: empirical chosen as 0.04 to calculate each element of R (corner response).

%% Output
% I: double type converted from "frame"
% row, col: the detected corners' locations

%% Convert frame to double type
I = im2double(frame);
figure;
imshow(frame);
[ymax, xmax, ch] = size(I);

%%%%%%%%%%%%%%%%%%%%%%%%%%% Interest Points %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%% get image gradient

% Grayscale
% [Your Code here]
I_gray=I(:,:,1)*0.299+I(:,:,2)*0.587+I(:,:,3)*0.114;

% calculate Ix using dx
% [Your Code here]
Ix= imfilter(I_gray,dx);

% calcualte Iy using dy
% [Your Code here]
Iy= imfilter(I_gray,dy);
%%% get all components of second moment matrix M = [[Ix2 IxIy];[IxIy Iy2]];
%%% note that Ix2 IxIy Iy2 are all Gaussian smoothed

% calculate Ix2 (element-wise multiplication of Ix)
% [Your Code here]

Ix2 = medfilt2(Ix.^2);
% calculate Iy2 (element-wise multiplication of Iy)
% [Your Code here]
Iy2 = medfilt2(Iy.^2);
% calculate IxIy (element-wise multiplication of Ix and Iy)
% [Your Code here]
Ixy = medfilt2(Ix.*Iy);
%% visualize IxIy
figure;
imagesc(Ixy);

%-------------------------- Demo Check Point -----------------------------%

%%
%%% get corner response function R = det(M)-alpha*trace(M)^2

% calculate R
% [Your Code here]
M = [sum(Ix2,'all') sum(Ixy,'all');sum(Ixy,'all') sum(Iy2,'all')];
R = Ix2.*Iy2-Ixy.^2-alpha*(Ix2+Iy2).^2;


%% make max R value to be 1000
if  max(R, [], "all") ~= 0
    R = (1000 / max(R, [], "all")) * R; % be aware of if max(R) is 0 or not
else
    R = 1000 * R; % be aware of if max(R) is 0 or not
end

%% using B = ordfilt2(A,order,domain) to implment a maxfilter

%%% find local maximum
% calculate MX using ordfilt2()
% [Your Code here]
sze = 2*r + 1; % domain width
MX=ordfilt2(R,sze*sze,ones(sze,sze));

% calculate RBinary. Hint: Find which locations of MX have local maximum larger
% than the threshold. And note that, ordfilt2() let neighborhood's values change to
% local maximum.
% [Your Code here]
RBinary = MX>threshold&MX==R;


%% get location of corner points not along image's edges to avoid the the influence of padding
offe = r-1;
R = R*0;
R(offe:size(RBinary, 1) - offe, offe:size(RBinary, 2) - offe) = RBinary(offe:size(RBinary, 1) - offe, offe:size(RBinary, 2) - offe);
[row,col] = find(R);

end
