function I_crop = load_and_crop(filename)

I = dicomread(filename);
I = double(I);
I = I./ max(I(:));

if ~ismatrix(I)
    I = I(:,:,1);
end

y1 = 279;
y2 = 797;
x1 = 44;
x2 = 704;
I_crop = I(x1:x2, y1:y2, :);


end