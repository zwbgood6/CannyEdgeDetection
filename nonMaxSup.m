function M = nonMaxSup(Mag, Ori)
%%  Description
%       compute the local minimal along the gradient.
%%  Input: 
%         Mag = (H, W), double matrix, the magnitude of derivative 
%         Ori = (H, W), double matrix, the orientation of derivative
%%  Output:
%         M = (H, W), logic matrix, the edge map
%
%% ****YOU CODE STARTS HERE**** 
[row, col] = size(Ori); % Extract the vertical size and horizontal size of image
x = 1:col;% Create vector of horizontal coordinates
y = 1:row;% Create vector of vertical coordinates
M=zeros(row, col);%Preallocate function output
[X,Y]=meshgrid(x,y);%Create meshgrid of pixel coordinates
Ori(Ori<0)=pi+Ori(Ori<0);%Condition orientation so they are all positive
x1=cos(Ori);%Compute horizontal offset 
y1=sin(Ori);%Compute Vertical offset 
Xquery1=X;%Preallocate coordinates of query points 
Yquery1=Y;%*
Xquery2=X;%*
Yquery2=Y;%*
for i=2:row-1
    for j=2:col-1
    Xquery1(i,j)=j+x1(i,j);%Compute both sets of query points
    Yquery1(i,j)=i-y1(i,j);%*
    Xquery2(i,j)=j-x1(i,j);%*
    Yquery2(i,j)=i+y1(i,j);%*
    end
end
N1 = interp2(X,Y,Mag,Xquery1, Yquery1);%Query pixel intensity at both neighbors
N2 = interp2(X,Y,Mag,Xquery2, Yquery2);%*

for m=2:row-1
    for n=2:col-1
        M(m,n)=Mag(m,n) == max([Mag(m,n),N1(m,n),N2(m,n)]);%Perform NMS
    end
end

M=logical(M);
end