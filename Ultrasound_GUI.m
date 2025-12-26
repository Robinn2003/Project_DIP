function Ultrasound_GUI
    close all;

    %% Figure
    f = figure('Name','Ultrasound Analysis', ...
               'NumberTitle','off', ...
               'Position',[100 100 1200 700]);

    ax = axes('Parent',f,'Position',[0.05 0.15 0.6 0.8]);

    %% UI Controls
    uicontrol(f,'Style','pushbutton','String','Load DICOM', ...
        'Position',[900 600 150 40],'Callback',@loadImage);

    imgPopup = uicontrol(f,'Style','popupmenu', ...
        'String',{'Original','Denoised','Netmask'}, ...
        'Position',[900 480 150 30],'Callback',@updateDisplay);

    chkLayer1 = uicontrol(f,'Style','checkbox','String','Layer 1 (Top)', ...
        'Position',[900 430 150 30],'Callback',@updateDisplay);

    chkLayer2 = uicontrol(f,'Style','checkbox','String','Layer 2 (Mid)', ...
        'Position',[900 400 150 30],'Callback',@updateDisplay);

    chkLayer3 = uicontrol(f,'Style','checkbox','String','Layer 3 (Deep)', ...
        'Position',[900 370 150 30],'Callback',@updateDisplay);
    set(chkLayer1,'Visible','off');
    set(chkLayer2,'Visible','off');
    set(chkLayer3,'Visible','off');

    
    resultsBox = uicontrol(f,'Style','text', ...
    'Position',[900 150 350 200], ...
    'HorizontalAlignment','left', ...
    'FontSize',10, ...
    'String','Load an image to see results');

    %% Shared data
    data = struct( ...
        'I_crop',[], ...
        'I_clean',[], ...
        'mask',[], ...
        'results',[] ...
    );
    guidata(f,data);

    %% Callbacks

    function loadImage(~,~)
        [file,path] = uigetfile('*.dcm','Select Ultrasound DICOM');
        if file==0, return; end

        data = guidata(f);

        % Processing pipeline
        data.I_crop  = load_and_crop(fullfile(path,file));
        data.I_clean = denoise_ultrasound(data.I_crop);
        data.mask    = segment_layer(data.I_clean);
        data.results = analyze_layers(data.mask);
        data.resultsText = formatResults(data.results);
        data.resultsBox = resultsBox;
        % Only show available layer checkboxes
        set(chkLayer1,'Visible','off','Value',0);
        set(chkLayer2,'Visible','off','Value',0);
        set(chkLayer3,'Visible','off','Value',0);
        
        numLayers = length(data.results);
        
        if numLayers >= 1
            set(chkLayer1,'Visible','on');
        end
        if numLayers >= 2
            set(chkLayer2,'Visible','on');
        end
        if numLayers >= 3
            set(chkLayer3,'Visible','on');
        end


        guidata(f,data);
        updateDisplay();
    end

    function updateDisplay(~,~)
        data = guidata(f);
        if isempty(data.I_crop), return; end

        cla(ax);

        % Image Selection
        switch imgPopup.Value
            case 1
                imshow(data.I_crop,[],'Parent',ax);
                title(ax,'Original');

            case 2
                imshow(data.I_clean,[],'Parent',ax);
                title(ax,'Denoised');

            case 3
                imshow(data.mask,[],'Parent',ax);
                title(ax,'Netmask (Segmented Fascia)');
        end

        if isfield(data,'resultsText')
            set(data.resultsBox,'String',data.resultsText);
        end


        hold(ax,'on');

        if isempty(data.results), hold(ax,'off'); return; end

        if chkLayer1.Value && length(data.results)>=1
            plotLayer(data.results(1),'r');
        end
        if chkLayer2.Value && length(data.results)>=2
            plotLayer(data.results(2),'g');
        end
        if chkLayer3.Value && length(data.results)>=3
            plotLayer(data.results(3),'b');
        end

        hold(ax,'off');
    end

    function txt = formatResults(results)
        if isempty(results)
            txt = 'No valid layers detected.';
            return;
        end
    
        txt = sprintf('Detected layers: %d\n\n', length(results));
        for i = 1:length(results)
            txt = sprintf('%sLayer %d:\n  Mean thickness: %.2f px\n  Max thickness:  %.2f px\n\n', ...
                txt, i, results(i).MeanThickness, results(i).MaxThickness);
        end
    end


    function plotLayer(layer,color)
        midX = mean(layer.XData);
        midY = mean(layer.Y_Top);
        
        text(ax, midX, midY-10, ...
        sprintf('Mean thickness = %.2f px', layer.MeanThickness), ...
        'Color', color, ...
        'FontSize', 10, ...
        'FontWeight', 'bold', ...
        'BackgroundColor', 'w', ...
        'Margin', 2);


        plot(ax, layer.XData, layer.Y_Top, color, 'LineWidth',2);
        plot(ax, layer.XData, layer.Y_Bottom, color, 'LineWidth',2);
    end
end
