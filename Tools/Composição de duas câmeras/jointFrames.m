pkg load image

if ~exist("dirname")
dirname = uigetdir ()
end

path1=strcat(dirname, "\\1\\frame0.jpg");
path2=strcat(dirname, "\\2\\frame0.jpg");

k=0;
while exist(path1)
I1=imread(path1);
I2=imread(path2);

if(size(I1,2)>size(I2,2))
I1=imresize(I1,[NaN size(I2,2)]);
else
I2=imresize(I2,[NaN size(I1,2)]);
end


if(size(I1,3)>size(I2,3))
I2=cat(3, I2,I2, I2);
elseif (size(I2,3)>size(I1,3))
I1= cat(3, I1,I1, I1);
end

I12=[I1;I2];

a=findstr(dirname,"\\");
imwrite(I12,strcat(dirname,"\\frame" ,num2str(k),".jpg"));
k=k+1;
path1=strcat(dirname, "\\1\\frame" ,num2str(k),".jpg");
path2=strcat(dirname, "\\2\\frame" ,num2str(k),".jpg");

end
