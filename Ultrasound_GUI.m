function Ultrasound_GUI
    close all;

    %% Figure
    f = figure('Name','Ultrasound Analysis', ...
               'NumberTitle','off', ...
               'Position',[100 100 1200 700]);

    ax = axes('Parent',f,'Position',[0.05 0.15 0.6 0.8]);

    %% UI CONTROLS
    uicontrol(f,'Style','pushbutton','String','Load DICOM', ...
        'Position',[750 600 150 40],'Callback',@loadImage);

    imgPopup = uicontrol(f,'Style','popupmenu', ...
        'String',{'Original','Denoised', 'Netmask', 'Calculated'}, ...
        'Position',[750 480 150 30],'Callback',@updateDisplay);

    chkSkin = uicontrol(f,'Style','checkbox','String','Skin', ...
        'Position',[750 430 120 30],'Callback',@updateDisplay);

    chkFascia = uicontrol(f,'Style','checkbox','String','Fascia', ...
        'Position',[750 400 120 30],'Callback',@updateDisplay);

    chkDeep = uicontrol(f,'Style','checkbox','String','Deep Fascia', ...
        'Position',[750 370 140 30],'Callback',@updateDisplay);

    %% Shared data
    data = struct( ...
    'I_crop',[], ...
    'I_clean',[], ...
    'I_netmask',[], ...
    'I_calculated',[], ...
    'skinMask',[], ...
    'fasciaMask',[], ...
    'deepMask',[] ...
    );
    guidata(f,data);

    %% ================= CALLBACKS =================

    function loadImage(~,~)
        [file,path] = uigetfile('*.dcm','Select Ultrasound DICOM');
        if file==0, return; end

        data = guidata(f);
        data.I_crop  = load_and_crop(fullfile(path,file));
        data.I_clean = denoise_ultrasound(data.I_crop);
        data.I_netmask = compute_netmask(data.I_clean); % TODO -> Chaimae
        data.I_calculated = calculate(data.I_clean); % TODO -> Wassim
        data.skinMask   = detect_skin(data.I_clean); % TODO -> get the right submask from chaimae function
        data.fasciaMask = detect_fascia(data.I_clean); % TODO
        data.deepMask   = detect_deep_fascia(data.I_clean); % TODO
        guidata(f,data);

        updateDisplay();
    end

    function updateDisplay(~,~)
        data = guidata(f);
        if isempty(data.I_crop), return; end

        cla(ax);

        switch imgPopup.Value
            case 1 % Original
            imshow(data.I_crop,[],'Parent',ax);
            title(ax,'Original');

        case 2 % Denoised
            imshow(data.I_clean,[],'Parent',ax);
            title(ax,'Denoised');

        case 3 % Netmask
            imshow(data.I_netmask,[],'Parent',ax);
            title(ax,'Netmask');

        case 4 % Thickness
            imshow(data.I_calculated,[],'Parent',ax);
            title(ax,'Thickness Measurement');
        end

        hold(ax,'on');

        % ---- LAYER OVERLAYS (NEXT STEP) ----
        if chkSkin.Value && ~isempty(data.skinMask)
            visboundaries(ax, data.skinMask, 'Color', 'r', 'LineWidth', 2);
            % plot(xSkin, ySkin, 'r','LineWidth',2)
        end
        if chkFascia.Value && ~isempty(data.fasciaMask)
            visboundaries(ax, data.fasciaMask, 'Color', 'g', 'LineWidth', 2);
            % plot(xFascia, yFascia, 'g','LineWidth',2)
        end
        if chkDeep.Value && ~isempty(data.deepMask)
            visboundaries(ax, data.deepMask, 'Color','b','LineWidth',2);
            % plot(xDeep, yDeep, 'b','LineWidth',2)
        end

        hold(ax,'off');
    end
end
