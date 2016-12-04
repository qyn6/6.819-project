function neighbors = getNeighbors(i,j,m,n)
%find pixel positions where scribbles are
neighbors = [];
for x=i-1:i+1
    for y=j-1:j+1
        if ~(x<1 || x>m || y>n || y<1)
            whee
        end
    end
end
