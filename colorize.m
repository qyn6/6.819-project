
g_name='example.bmp';
c_name='example_marked.bmp';
out_name='example_res.bmp';

%set solver=1 to use a multi-grid solver
%and solver=2 to use an exact matlab "\" solver
solver=2;

gI=double(imread(g_name))/255;
cI=double(imread(c_name))/255;
colorIm=(sum(abs(gI-cI),3)>0.01);
g = double(imread(g_name));
colorIm=double(colorIm);

sgI=rgb2ntsc(gI);
scI=rgb2ntsc(cI);

ntscIm(:,:,1)=sgI(:,:,1);
ntscIm(:,:,2)=scI(:,:,2);
ntscIm(:,:,3)=scI(:,:,3);

%
% max_d=floor(log(min(size(ntscIm,1),size(ntscIm,2)))/log(2)-2);
% iu=floor(size(ntscIm,1)/(2^(max_d-1)))*(2^(max_d-1));
% ju=floor(size(ntscIm,2)/(2^(max_d-1)))*(2^(max_d-1));
% id=1; jd=1;
% colorIm=colorIm(id:iu,jd:ju,:);
% ntscIm=ntscIm(id:iu,jd:ju,:);
%
% if (solver==1)
%   nI=getVolColor(colorIm,ntscIm,[],[],[],[],5,1);
%   nI=ntsc2rgb(nI);
% else
m=size(ntscIm,1); n=size(ntscIm,2);
imgSize=m*n;


nI(:,:,1)=ntscIm(:,:,1);

indsM=reshape([1:imgSize],m,n);
lblInds=find(colorIm);

wd=1;

len=0;
consts_len=0;
col_inds=zeros(imgSize*(2*wd+1)^2,1);
row_inds=zeros(imgSize*(2*wd+1)^2,1);
vals=zeros(imgSize*(2*wd+1)^2,1);
gvals=zeros(1,(2*wd+1)^2);


for j=1:n
    for i=1:m
        consts_len=consts_len+1;
        
        if (~colorIm(i,j))
            tlen=0;
            for ii=max(1,i-wd):min(i+wd,m)
                for jj=max(1,j-wd):min(j+wd,n)
                    
                    if (ii~=i)|(jj~=j)
                        len=len+1; tlen=tlen+1;
                        row_inds(len)= consts_len;
                        col_inds(len)=indsM(ii,jj);
                        gvals(tlen)=ntscIm(ii,jj,1);
                    end
                end
            end
            t_val=ntscIm(i,j,1);
            gvals(tlen+1)=t_val;
            c_var=mean((gvals(1:tlen+1)-mean(gvals(1:tlen+1))).^2);
            csig=c_var*0.6;
            mgv=min((gvals(1:tlen+1)-t_val).^2);
            if (csig<(-mgv/log(0.01)))
                csig=-mgv/log(0.01);
            end
            if (csig<0.000002)
                csig=0.000002;
            end
            
            gvals(1:tlen)=exp(-(gvals(1:tlen)-t_val).^2/csig);
            gvals(1:tlen)=gvals(1:tlen)/sum(gvals(1:tlen));
            vals(len-tlen+1:len)=-gvals(1:tlen);
        end
        
        
        len=len+1;
        row_inds(len)= consts_len;
        col_inds(len)=indsM(i,j);
        vals(len)=1;
        
    end
end


vals=vals(1:len);
col_inds=col_inds(1:len);
row_inds=row_inds(1:len);


A=sparse(row_inds,col_inds,vals,consts_len,imgSize);
b=zeros(size(A,1),1);


for t=2:3
    curIm=ntscIm(:,:,t);
    b(lblInds)=curIm(lblInds);
    new_vals=A\b;
    nI(:,:,t)=reshape(new_vals,m,n,1);
    figure;
    imshow(nI(:,:,t));
end



snI=nI;
nI=ntsc2rgb(nI);
% end

figure, imshow(nI)

imwrite(nI,out_name)



%Reminder: mex cmd
%mex -O getVolColor.cpp fmg.cpp mg.cpp  tensor2d.cpp  tensor3d.cpp
