function E = edgeLink(M, Mag, Ori)
%%  Description
%       use hysteresis to link edges
%%  Input: 
%        M = (H, W), logic matrix, output from non-max suppression
%        Mag = (H, W), double matrix, the magnitude of gradient
%        Ori = (H, W), double matrix, the orientation of gradient
%
%%  Output:
%        E = (H, W), logic matrix, the edge detection result.
%
%% ****YOU CODE STARTS HERE**** 
LowThresholdRatio=0.135;%Define highThresholdRatio 0.135
HighThresholdRatio=0.5;%Define lowThresholdRatio 0.5
LowThreshold=max(max(Mag))*LowThresholdRatio;%Compute high threshold
HighThreshold=HighThresholdRatio*LowThreshold;%Compute low threshold
row=size(Mag,1);%Extract vertical size of image
col=size(Mag,2);%Extract horizontal size of image
strongEdgesRow = zeros(1,row*col); % Preallocate strong edge row index
strongEdgesCol = strongEdgesRow; % Preallocate track of strong edge col index
weakEdgesRow = strongEdgesRow; % Preallocate track of weak edge row index
weakEdgesCol = strongEdgesRow; % Preallocate track of weak edge col index
strongIndex = 0;%Counter for number of strong edge pixels
weakIndex = 0;%Counter for number of weak edge pixels
img1=M.*Mag;%Extract pixel intensity for entire NMS map
E=zeros(row, col);%Preallocate function output 
Ori=Ori+pi/2;%Find edge orientation 
Ori(Ori<0)=pi+Ori(Ori<0);%Condition edge orientation to be positve
Ori1=Ori+pi;%Compute second direction of edge orientation 
x=1:col;% Create vector of horizontal coordinates
y=1:row;% Create vector of vertical coordinates 
[X,Y]=meshgrid(x,y);%Create meshgrid of pixel coordinates
x1=cos(Ori);%Compute horizontal offset 
y1=sin(Ori);%Compute Vertical offset
X1=X;%Preallocate coordinates of query points 
Y1=Y;%*
X2=X;%*
Y2=Y;%*
for i=2:row-1
    for j=2:col-1
    X1(i,j)=j+x1(i,j);%Compute both sets of query points
    Y1(i,j)=i-y1(i,j);%*
    X2(i,j)=j-x1(i,j);%*
    Y2(i,j)=i+y1(i,j);%*
    end
end
N1=interp2(X,Y,Mag,X1, Y1);%Query pixel intensity along edge
N2=interp2(X,Y,Mag,X2, Y2);%*
%Local Thresholding (uncomment line 50, 54, 55 for local thresholding)
%  [H,L]=LocalThreshold(Mag);
%Perform double thresholding
for i=2:row-1
    for j=2:col-1
%          highThreshold=H(i,j);
%          lowThreshold=L(i,j);
        if img1(i,j)>LowThreshold
            E(i,j)=1;
            strongIndex=strongIndex+1;
            strongEdgesRow(strongIndex)=i;
            strongEdgesCol(strongIndex)=j;
        elseif img1(i,j)<HighThreshold
            E(i,j)=0;
        else 
            weakIndex=weakIndex+1;
            weakEdgesRow(weakIndex)=i;
            weakEdgesCol(weakIndex)=j;
            E(i,j)=0.5;
        end
    end
end

%Define recursive function to check quality of weak edges
    function[imag]=VerifyWeakEdges(imag, row, col,N1,N2,Ori,Ori1,lowThreshold)
        for m=-1:1:1
            for n=-1:1:1%Iterate through nearby pixels
                if (row+m>0)&& (col+n > 0) && (row+m < size(imag,1)) &&...
                        (col+n < size(imag,2))%Check pixel is not out of bound
                    if (imag(row+m,col+n)==0.5)%Check pixel is in weak map 
                        theta=-atan2(m,n);%Find orientation to the weak pixel
                        if theta<0
                            theta=theta+2*pi;%Condition the orientation so it is positive
                        end
                        if (abs(theta-Ori(row,col))<=pi/50)...%Check that weak pixel location is similar to edge orientation
                                && (N1(row, col)>lowThreshold)%Check that interpolated pixel value along edge is still higher than low threshold
                            imag(row+m, col+n)=1;%Make the weak edge a strong edge
                            imag=VerifyWeakEdges(imag,row+m,col+n,N1,N2,Ori,Ori1,lowThreshold);%Use coordinate of newly converted strong edge to do recursion
                        elseif (abs(theta-Ori1(row,col))<=pi/50)...%CHeck if we can extend edge in the opposite direction
                                && (N2(row,col)>lowThreshold)
                            imag(row+m, col+n)=1;
                            imag=VerifyWeakEdges(imag,row+m,col+n,N1,N2,Ori,Ori1,lowThreshold);
                        end
                    end
                end
            end
        end
    end
%Iterating through all strong edges to find quality weak edges
for i=1:strongIndex
       E = VerifyWeakEdges(E, strongEdgesRow(i),...
             strongEdgesCol(i), N1,N2,Ori,Ori1,HighThreshold);
end
%Neglect all pixels in the weak map that did not pass verification
for k=1:weakIndex
    if E(weakEdgesRow(k),weakEdgesCol(k))==0.5
        E(weakEdgesRow(k),weakEdgesCol(k))=0;
    end
end
%type cast output to logical 
E=logical(E);

end