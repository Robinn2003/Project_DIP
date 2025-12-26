%% 1. Laden van de medische afbeelding
bestandsnaam = 'BO2WL_F_10089_T1_CALF.dcm'; 
I_raw = dicomread(bestandsnaam);

% Squeeze verwijdert de 'loze' extra dimensies die de fout veroorzaken
I = squeeze(I_raw);

% Als het nog steeds meer dan 2 dimensies heeft (bijv. een stapel scans), 
% pakken we de eerste laag:
if ndims(I) > 2
    I = I(:,:,1);
end

% Omzetten naar bruikbaar formaat
I = im2double(mat2gray(I)); 

%% 2. De afbeelding bekijken
figure;
imshow(I, []);
title('Originele Scan');

%% 3. Een 'Initial Mask' maken
level = graythresh(I);
bw_start = imbinarize(I, level);

%% 4. Active Contour (De segmentatie)
% We gebruiken Chan-Vese, dit werkt goed voor medische beelden
mask = activecontour(I, bw_start, 300, 'Chan-Vese');

%% 5. Resultaat tonen
figure;
% imshowpair is handig: het laat de mask over de originele foto zien!
imshowpair(I, mask, 'blend');
title('Segmentatie resultaat (Blauw/Paars = Masker)');

% En nog een keer alleen de zwart-wit mask voor je opdracht:
figure;
imshow(mask);
title('Binary Mask (Laag 1)');

%% 6. De mask opschonen (optioneel maar beter voor je project)
% We houden alleen de grootste objecten over (verwijdert tekst en ruis)
mask_clean = bwareafilt(mask, 5); % Houdt de 5 grootste vlakken over

figure;
imshow(mask_clean);
title('Opgeschoonde Binary Mask (Zonder ruis)');

