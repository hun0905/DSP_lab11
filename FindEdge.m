function [I, row, col] = FindEdge(frame, dx, dy, g, threshold, r, alpha)
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
Ix2 = imfilter(Ix.^2,g);

% calculate Iy2 (element-wise multiplication of Iy)
% [Your Code here]
Iy2 = imfilter(Iy.^2,g);

% calculate IxIy (element-wise multiplication of Ix and Iy)
% [Your Code here]
Ixy = imfilter(Ix.*Iy,g);

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
R = (1000 / max(R, [], "all")) * R; % be aware of if max(R) is 0 or not

%% using B = ordfilt2(A,order,domain) to implment a maxfilter

%%% find local maximum
% calculate MX using ordfilt2()
% [Your Code here]
sze = 2*r + 1; % domain width
MX=ordfilt2(R,1,ones(sze,sze));

% calculate RBinary. Hint: Find which locations of MX have local maximum larger
% than the threshold. And note that, ordfilt2() let neighborhood's values change to
% local maximum.
% [Your Code here]
RBinary = abs(MX)>abs(threshold)&MX==R&MX<0;


%% get location of corner points not along image's edges to avoid the the influence of padding
offe = r-1;
R = R*0;
R(offe:size(RBinary, 1) - offe, offe:size(RBinary, 2) - offe) = RBinary(offe:size(RBinary, 1) - offe, offe:size(RBinary, 2) - offe);
[row,col] = find(R);

end