clc; close all;
%% TEST SCRIPT VOOR DE GROEP (Integratie)
% Dit script roept de functies van Robin en die van jou achter elkaar aan.

filename = 'BO2WL_F_20050_T1_BIC.dcm';


% 1. Voer de stappen van Robin (Person 1) uit
disp('Bezig met laden en croppen...');
I_crop = load_and_crop(filename);
figure;
imshow(I_crop);
hold on;
title('Layer Boundaries on Ultrasound Image');

disp('Bezig met ruisonderdrukking...');
I_clean = denoise_ultrasound(I_crop);

% 2. Voer jouw stap (Person 2) uit
disp('Bezig met segmenteren van Layer 1...');
final_mask = segment_layer(I_clean);

% 3. Resultaat laten zien
disp('Klaar! Dit is het resultaat voor Wassim (Person 3):');


% 4. Layers analyseren
layers = analyze_layers(final_mask);
disp(['Found ' num2str(length(layers)) + 1 ' layers.']);
% Resultaat laten zien
for i = 1:length(layers)
    disp('------------------------------------------------');
    disp(['Fascia Line Number:   ' num2str(layers(i).LayerID)]);
    disp(['Mean Thickness: ' num2str(layers(i).MeanThickness, '%.2f') ' pixels']);
    disp(['Max Thickness:  ' num2str(layers(i).MaxThickness, '%.2f') ' pixels']);
    disp('------------------------------------------------');
    col = 'r';
    
    % Retrieve data calculated by analyze_layers
    x_vals = layers(i).XData;
    y_top  = layers(i).Y_Top;
    y_bot  = layers(i).Y_Bottom;
    
    % Plot Smooth Curves
    plot(x_vals, y_top, '-', 'Color', col, 'LineWidth', 3);
    plot(x_vals, y_bot, '-', 'Color', col, 'LineWidth', 3);
end

hold off;
disp('Visualization complete.');

