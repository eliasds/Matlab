function [ ] = computationalImagingUI( )
%COMPUTATIONALIMAGINGUI Launches the UI
    addpath ([pwd '/shared']);
    
    default = struct ('load_filename','') ;
    default.script_list = {'algorithms/ppr/phaseRetrieval.m', ...
                           'algorithms/ppr/visualizeTF.m', ...
                           'algorithms/compare/compare.m', ...
                           'algorithms/gerchberg-saxton/gs.m', ...
                           'algorithms/tovideo/exportToVideo.m'} ;
    default.run_filename = default.script_list{1} ;
    gui = struct('load', struct('is_loading',false), 'run', struct('is_running', false), ...
                 'progress', struct('is_paused',false, 'is_canceled', false), ...
                 'view', struct(), 'data', struct(), 'results', struct()) ;
    
    gui.data = struct('images',zeros(0,0,0), 'reference_images',[], 'params',[], 'settings',struct(), ...
                      'results',struct('error_real',{cell(0,2)},'error_fft',{cell(0,2)})) ;
                  
    if exist('defaults.mat','file')
        saved_settings = load('defaults.mat') ;
        if isfield(saved_settings,'load_filename'), default.load_filename = saved_settings.load_filename ; end
        if isfield(saved_settings,'run_filename'), default.run_filename = saved_settings.run_filename ; end
    else
        save ('defaults.mat', '-struct', 'default') ;
    end
    icon_folder = [fileparts(mfilename('fullpath')) filesep 'icons' filesep] ;
             
    f = figure('MenuBar','None','Renderer', 'painters','WindowStyle','normal','Visible','on') ;
    gui.figure = f ;
    zoom (f, 'on') ;
    gui.zoom = zoom(f) ;
    set(gui.zoom,'ActionPostCallback',@zoomCallback) ;
    set(gui.zoom,'ButtonDownFilter',@zoomClick) ;
    mcolorbar(f,'clear') ;
    gui.colormaps = struct('jet', jet(64), 'gray', gray(128), 'fourier', jet(64)) ;
    
    ui_rootPanel = uiextras.VBox('Parent',f,'Spacing',5,'Padding',5) ;
    
    ui_loadAndRun = uiextras.HBox ('Parent', ui_rootPanel, 'Spacing', 5) ;
    ui_loadAndRunStack = uiextras.VBox('Parent', ui_loadAndRun, 'Spacing', 5) ;
    gui.run.loadnrun = uicontrol('String', '<html><center>Load<br>Run', 'Enable', 'off', 'Parent', ui_loadAndRun, 'Callback', @loadRunFile) ;
    ui_loadAndRun.Sizes = [-1, 50] ;
    
    %% Load File
    ui_loadFileInput = uiextras.HBox ('Parent', ui_loadAndRunStack, 'Spacing', 5) ;
    
    uicontrol('Style','text','String','File:','FontSize',10,'Parent',ui_loadFileInput, 'HorizontalAlignment','right') ;
    gui.load.filename = uicontrol('Style','edit','Parent',ui_loadFileInput,...
                                  'String', default.load_filename,...
                                  'BackgroundColor',[1,1,1],'FontSize',10, 'HorizontalAlignment','left', ...
                                  'KeyPressFcn', @updateFilename) ;
    gui.load.edit = uicontrol('String',['<HTML><img width="16" height="16" src="file:/' icon_folder 'edit.png' '">'],'Parent', ui_loadFileInput, 'Callback', @editDataFile) ;
    gui.load.select = uicontrol('String',['<HTML><img width="16" height="16" src="file:/' icon_folder 'file.png' '">'],'Parent', ui_loadFileInput, 'Callback', @pickDataFile) ;
    gui.load.btn = uicontrol('String','Load', 'Parent',ui_loadFileInput,'Callback', @loadDataFile,...
                             'FontSize', 10, 'Enable', 'off') ;
    ui_loadFileInput.Sizes = [60, -1, 30, 30, 90] ;
    
    %% Run Script
    ui_runAlgoScriptAdd = uiextras.HBox ('Parent', ui_loadAndRunStack, 'Spacing',5) ;
    uicontrol('Style','text','String','Script:','FontSize',10,'Parent',ui_runAlgoScriptAdd, 'HorizontalAlignment','right') ;
    
    [gui.run.filename, hComboBox] = javacomponent('javax.swing.JComboBox', [], uicontainer('Parent',ui_runAlgoScriptAdd,'Position',[0,0,200,30])) ;
    set(hComboBox,'units','norm','position',[0,0,1,1]) ;
    gui.run.filename.setEditable(true) ;
    for i=1:length(default.script_list), gui.run.filename.addItem(default.script_list{i}) ; end
    gui.run.filename.setSelectedItem(default.run_filename) ;
    set(gui.run.filename,'ActionPerformedCallback', @updateEnabled) ;
    gui.run.select = uicontrol('String',['<HTML><img width="16" height="16" src="file:/' icon_folder 'file.png' '">'],'Parent', ui_runAlgoScriptAdd, 'Callback', @pickRunFile) ;
    gui.run.btn = uicontrol('String','Run', 'FontSize', 10, 'Enable','off', 'Parent', ui_runAlgoScriptAdd, 'Callback', @runFile) ;
    ui_runAlgoScriptAdd.Sizes = [60, -1, 30 90] ;
    
    %% Tab panel
    gui.ui_tabPanel = uiextras.TabPanel ('Parent',ui_rootPanel, 'Padding', 5) ;
    ui_rootPanel.Sizes = [45,-1] ;
    %gui.ui_tabPanel = uiextras.TabPanel ('Parent',f, 'Padding', 5,...
    %                                     'Callback',@refreshFigure) ;
    %% Input Parameters
    gui = parametersGUI (gui.ui_tabPanel, gui) ;
    %% View Data Panel
    gui = dataGUI (gui.ui_tabPanel, gui) ;
    %% Settings Panel
    gui.view.settings = uitable('Parent',gui.ui_tabPanel,...
                                'ColumnEditable',[false,true,true],'ColumnName',{'Name','Value'},'ColumnFormat',{'char','char',{' ','Delete'}},...
                                'ColumnWidth',{140,210}, 'RowName',[], ...
                                'Data', cell(0,2)) ;
    
    
    %% Progress Panel
    gui = progressGUI (gui.ui_tabPanel, gui) ;
    %% Result Field Panel
    gui = resultsGUI (gui.ui_tabPanel, gui) ;
    %% Reconstruction Inspection Panel
    gui = reconstructionGUI (gui.ui_tabPanel, gui) ;
    %% Sweep Panel
    gui = sweepGUI (gui.ui_tabPanel, gui) ;
    %% Optimization Panel
    gui = optimizeGUI (gui.ui_tabPanel, gui) ;
    %% Finish Up
    gui.ui_tabPanel.TabNames = {'Parameters','Images','Settings','Progress','Result','Reconstruction', 'Sweep', 'Optimize'} ;
    
    
    set(gui.ui_tabPanel, 'SelectedChild', 1) ;
    
    gui.view.image_index = 1 ;
    gui.run.callbacks = struct ('status', @progressCallback_status, ...
                                'canceled', @progressCallback_canceled, ...
                                'progress', @progressCallback_progress, ...
                                'plot', @progressCallback_plot, ...
                                'result', @progressCallback_result, ...
                                'error', @progressCallback_error) ;
    
    getGUI (gui, f) ;
    updateDataGUI() ;
    updateResultsGUI() ;
    updateReconstructionGUI();
    updateSweepGUI();
    updateSweepOptimize();
    updateEnabled() ;
    set(f,'Visible','on');
end

function gui = getGUI (gui,fig)
    if ~exist('fig','var'), fig = gcbf ; end
    if isempty(fig), fig = gcf ; end
    if exist('gui','var')
        set(fig,'UserData',gui) ;
    else
        gui = get(fig,'UserData') ;
    end
end

function updateEnabled (~,~,~)
    gui = getGUI() ;
    is_busy = gui.run.is_running || gui.load.is_loading || gui.sweep.is_sweeping || gui.sweep.is_saving || gui.sweep.is_loading ;
    %% Does the data file exist?
    filename = get(gui.load.filename,'String') ;
    if ~is_busy && exist(filename,'file')
        set(gui.load.btn, 'Enable', 'on') ;
        set(gui.load.edit, 'Enable', 'on') ;
    else
        set(gui.load.btn, 'Enable', 'off') ;
        set(gui.load.edit, 'Enable', 'off') ;
    end
    %% Does the script exist and is data loaded?
    filename = gui.run.filename.getSelectedItem ;
    if ~is_busy && ~isempty(gui.data.images) && exist(filename,'file'), set(gui.run.btn, 'Enable', 'on') ;
    else set(gui.run.btn, 'Enable', 'off') ; end
    if ~is_busy && exist(get(gui.load.filename,'String'),'file') && exist(gui.run.filename.getSelectedItem,'file'), set(gui.run.loadnrun,'Enable','on');
    else set(gui.run.loadnrun,'Enable','off') ; end
    %% Is code running right now?
    if is_busy
        set(gui.load.select,'Enable','off') ;
        set(gui.run.select,'Enable','off') ;
        set(gui.load.filename,'Enable','off') ;
        set(gui.sweep.btn,'Enable','off') ;
        set(gui.optimize.btn,'Enable','off') ;
        gui.run.filename.setEnabled(false) ;
    else
        set(gui.load.select,'Enable','on') ;
        set(gui.run.select,'Enable','on') ;
        set(gui.load.filename,'Enable','on') ;
        set(gui.sweep.btn,'Enable','on') ;
        set(gui.optimize.btn,'Enable','on') ;
        gui.run.filename.setEnabled(true) ;
    end
    %% Is Paused?
    if gui.progress.is_paused, set(gui.progress.pause,'String','Resume') ;
    else set(gui.progress.pause,'String','Pause') ; end
    if ~is_busy && ~isempty(get(gui.sweep.primary_variable,'String')) && ~isempty(get(gui.sweep.primary_value,'String'))
        set(gui.sweep.btn,'Enable','on') ;
    else
        set(gui.sweep.btn,'Enable','off') ;
    end
    %% Does the Optimize Script Exist?
    filename = get(gui.sweep.sweep_script,'String') ;
    if exist(filename,'file')
        set(gui.sweep.sweep_script_enable,'Enable','on') ;
    else
        set(gui.sweep.sweep_script_enable,'Value',0) ;
        set(gui.sweep.sweep_script_enable,'Enable','off') ;
    end
    %% Does the Reference File Exist?
    filename = get(gui.load.ref_file,'String') ;
    if exist(filename,'file')
        set(gui.load.ref_enable,'Enable','on') ;
    else
        set(gui.load.ref_enable,'Value',0) ;
        set(gui.load.ref_enable,'Enable','off') ;
    end
end

function figMouseHover (~,~,~)
    sweepMouseHover () ;
    reconstructionMouseHover() ;
    reconstructionErrorMouseHover();
end

%% Load
function pickDataFile (~,~,~)
    gui = getGUI () ;
    filename = get(gui.load.filename,'String') ;
    if ~exist(filename,'file'), filename = pwd ; end
    [filename, path] = uigetfile('*.xml', 'Select Data File',filename) ;
    if ~ischar(filename), return ; end
    set(gui.load.filename,'String',[relativepath(path,pwd) filename]) ;
    loadDataFile('') ;
end
function editDataFile (~,~,~)
    gui = getGUI () ;
    filename = get(gui.load.filename,'String') ;
    edit(filename);
end
function loadDataFile (nogui, ~, ~)
    % Load an xml file and display the results
    nogui = exist('nogui','var') && ischar(nogui) && strcmp(nogui,'nogui') ;
    gui = getGUI () ;
    gui.load.is_loading = true ;
    getGUI(gui) ;
    updateEnabled() ;
    filename = get(gui.load.filename,'String') ;
    if ~nogui, set(gui.load.filename,'String',' Loading...','ForegroundColor',[0.7,0,0]) ; end
    try
        %% Get Parameters
        parameters = get(gui.load.parameters, 'Data') ;
        load_xml = '' ; for i=1:size(parameters,1), load_xml = [load_xml, '<setting name="' parameters{i,1} '">' parameters{i,2} '</setting>'] ; end %#ok<AGROW>
        load_params = loadMeasurementXML (['=<data>' load_xml '</data>']) ;
        if isfield(gui.sweep, 'parameters') && ~isempty(gui.sweep.parameters)
            for i=fieldnames(gui.sweep.parameters)', load_params.(i{1}) = gui.sweep.parameters.(i{1}) ; end
            if get(gui.sweep.sweep_script_enable,'Value') && strcmp(get(gui.sweep.sweep_script_enable,'Enable'),'on')
                load_params.settings = gui.data.sweep_settings ;
                load_params.images = gui.data.sweep_images ;
                load_params.params = gui.data.sweep_params ;
                filename = get(gui.sweep.sweep_script,'String') ;
            end
        end
        drawnow ;
        %% Load the File
        [gui.data.settings, gui.data.params, gui.data.images] = loadMeasurementXML (filename, load_params) ;
        if get(gui.load.ref_enable,'Value')
            ref_filename = get(gui.load.ref_file,'String') ;
            [~, ~, gui.data.reference_images] = loadMeasurementXML (ref_filename, load_params) ;
        else
            gui.data.reference_images = [] ;
        end
        %% Store the results
        gui.load.is_loading = false ;
        if ~gui.sweep.is_sweeping
            if ~nogui
                gui.view.image_index = 1 ;
                getGUI (gui) ;
                set(gui.view.settings, 'Data', paramToTable(gui.data.settings)) ;
                updateDataGUI() ;
                set(gui.load.filename,'String',filename,'ForegroundColor',[0,0,0]) ;
                set(gui.ui_tabPanel, 'SelectedChild', 2) ;
            else
                getGUI(gui) ;
            end
            updateEnabled() ;
            
            save_struct = struct('load_filename', filename, ...
                                 'parameters_ref_file', get(gui.load.ref_file,'String'), ...
                                 'parameters_ref_enable', get(gui.load.ref_enable,'Value')) ; %#ok<NASGU>
            save ('defaults.mat', '-struct', 'save_struct', '-append') ;
        else
            getGUI(gui) ;
            updateEnabled() ;
        end
    catch e
        gui.load.is_loading = false ;
        getGUI(gui) ;
        if ~nogui
            set(gui.load.filename,'String',filename,'ForegroundColor',[0,0,0]) ;
        end
        updateEnabled() ;
        errordlg(e.message) ;
        rethrow(e) ;
    end
end
function updateFilename (~,eventdata,~)
    persistent in_robot ;
    if strcmp(eventdata.Key,'return')
        if isempty(in_robot)
           loadDataFile();
        end
        return ;
    end
    in_robot = 1 ; %#ok<NASGU>
    import java.awt.Robot ;
    import java.awt.event.KeyEvent ;
    robot = Robot ;
    gui = getGUI() ;
    robot.keyPress(KeyEvent.VK_ENTER) ;
    robot.waitForIdle();
    robot.keyRelease(KeyEvent.VK_ENTER) ;
    drawnow ;
    in_robot = [] ;
    %% See if it's a valid file
    updateEnabled() ;
end

%% Run
function pickRunFile (~,~,~)
    gui = getGUI () ;
    filename = gui.run.filename.getSelectedItem ;
    if ~exist(filename,'file'), filename = pwd ; end
    [filename, pathname] = uigetfile('*.m', 'Select Script', filename) ;
    if isempty(filename), return ; end
    gui.run.filename.setSelectedItem([relativepath(pathname,pwd) filename]) ;
    updateEnabled() ;
end
function loadRunFile (~,~,~)
    loadDataFile() ;
    gui = getGUI() ;
    if ~isempty(gui.data.images)
        runFile() ;
    end
end
function runFile (~,~,~)
    gui = getGUI () ;
    filename = gui.run.filename.getSelectedItem ;
    %% Clear Progress Variables:
    gui.run.is_running = true ;
    if ~gui.sweep.is_sweeping
        gui.progress.is_canceled = false ;
        gui.progress.is_paused = false ;
        set(gui.progress.status,'String',[]) ;
        set(gui.ui_tabPanel, 'SelectedChild', 4) ;
    end
    gui.progress.start_time = tic ;
    getGUI (gui) ;
    updateEnabled() ;
    drawnow ;
    %% Run Script
    old_path = pwd ;
    [script_path, name, ~] = fileparts(filename) ;
    gui.run.callbacks.result('clear') ;
    progressCallback_plot() ;
    progressCallback_status (['Running script ' name ' on file ' get(gui.load.filename,'String')]) ;
    if ~isempty(script_path), cd (script_path) ; end
    try
        fnhandle = str2func(name) ;
        result_field = fnhandle(gui.data.images, gui.data.params, gui.data.settings, gui.run.callbacks) ;
        if ~isempty(old_path), cd (old_path) ; end
        gui = getGUI() ;
        %% Update Results
        if isempty(gui.data.results.field), gui.data.results.field = result_field ; end
        if isempty(gui.data.results.error_metric), gui.data.results.error_metric = getErrorMetric(gui, gui.data.results) ; end
        gui.data.results.log = get(gui.progress.status,'String') ;
        gui.run.is_running = false ;
        
        if ~gui.sweep.is_sweeping
            gui.progress.is_paused = false ;
            gui.progress.is_canceled = false ;
            getGUI(gui) ;
            updateResultsGUI() ;
            updateReconstructionGUI() ;
            updateEnabled() ;
        else
            getGUI(gui) ;
            updateEnabled() ;
        end
    catch e
        if ~isempty(old_path), cd (old_path) ; end
        gui = getGUI () ;
        gui.run.is_running = false ;
        if ~gui.sweep.is_sweeping
            gui.is_paused = false ;
            gui.is_canceled = false ;
            getGUI(gui) ;
            updateEnabled() ;
            gui.run.callbacks.status(['<font color="red">Error: ' e.message '</font>']) ;
            updateResultsGUI() ;
            updateReconstructionGUI() ;
        else
            getGUI(gui) ;
            updateEnabled() ;
            gui.run.callbacks.status(['<font color="red">Error: ' e.message '</font>']) ;
        end
        drawnow ;
        errordlg(['Script Failed with error: ' e.message]) ;
        rethrow (e) ;
    end
end
function error = getErrorMetric (gui, results)
    error = nan ;
    if isfield(results, 'error')
        error = results.error ;
    elseif isfield(gui.data.results,'reconstruction')
        if ~isempty(gui.data.reference_images)
            error = std(gui.data.refrence_images(:) - gui.data.results.reconstruction(:)) / std(gui.data.refrence_images(:)) ;
        else
            error = std(gui.data.images(:) - gui.data.results.reconstruction(:)) / std(gui.data.images(:)) ;
        end
    end
end

%% Sweep
function gui = sweepGUI (ui_tabPanel, gui)
    %% Saved Settings
    default = struct ('sweep_secondary','',...
                      'sweep_primary','',...
                      'sweep_secondary_value','',...
                      'sweep_primary_value','',...
                      'sweep_script','',...
                      'sweep_script_enable',false,...
                      'sweep_primary_optimize_max','',...
                      'sweep_primary_optimize_min','',...
                      'sweep_primary_optimize_tol','',...
                      'sweep_primary_optimize_mode',1) ;
    if exist('defaults.mat','file')
        saved_settings = load('defaults.mat') ;
        if isfield(saved_settings,'sweep_primary'), default.sweep_primary = saved_settings.sweep_primary ; end
        if isfield(saved_settings,'sweep_secondary'), default.sweep_secondary = saved_settings.sweep_secondary ; end
        if isfield(saved_settings,'sweep_primary_value'), default.sweep_primary_value = saved_settings.sweep_primary_value ; end
        if isfield(saved_settings,'sweep_secondary_value'), default.sweep_secondary_value = saved_settings.sweep_secondary_value ; end
        if isfield(saved_settings,'sweep_script'), default.sweep_script = saved_settings.sweep_script ; end
        if isfield(saved_settings,'sweep_script_enable'), default.sweep_script_enable = saved_settings.sweep_script_enable ; end
        if isfield(saved_settings,'sweep_primary_optimize_max'), default.sweep_primary_optimize_max = saved_settings.sweep_primary_optimize_max ; end
        if isfield(saved_settings,'sweep_primary_optimize_min'), default.sweep_primary_optimize_min = saved_settings.sweep_primary_optimize_min ; end
        if isfield(saved_settings,'sweep_primary_optimize_tol'), default.sweep_primary_optimize_tol = saved_settings.sweep_primary_optimize_tol ; end
        if isfield(saved_settings,'sweep_primary_optimize_mode'), default.sweep_primary_optimize_mode = saved_settings.sweep_primary_optimize_mode ; end
    end
    
    gui.sweep = struct('is_sweeping',false,'is_saving',false,'is_loading',false) ;

    ui_sweep = uiextras.VBoxFlex ('Parent', ui_tabPanel, 'Spacing', 5) ;
    
    ui_sweepScript = uiextras.HBox ('Parent', ui_sweep, 'Spacing', 5) ;
                                    uicontrol('Style','text','String','Sweep Script:',             'Parent', ui_sweepScript, 'HorizontalAlignment','right') ;
    gui.sweep.sweep_script     =    uicontrol('Style','edit','String',default.sweep_script,         'Parent', ui_sweepScript, 'HorizontalAlignment','left','BackgroundColor',[1,1,1], 'KeyPressFcn', enterEventHandler (@(~,~,~)0)) ;
    gui.sweep.select              = uicontrol('String',['<HTML><img width="16" height="16" src="file:/' strrep(fullfile([pwd '/icons/file.png']),filesep,'/') '">'],'Parent', ui_sweepScript, 'Callback', @sweepPickScript) ;
    gui.sweep.sweep_script_enable = uicontrol('Style','checkbox','String','','Value',default.sweep_script_enable,             'Parent', ui_sweepScript, 'HorizontalAlignment','right') ;
    ui_sweepScript.Sizes = [120,-1,30,20] ;
    
    ui_sweepInputs = uiextras.Grid ('Parent', ui_sweep, 'Spacing', 5) ;
    
                                    uicontrol('Style','text','String','Primary Variable:',             'Parent', ui_sweepInputs, 'HorizontalAlignment','right') ;
                                    uicontrol('Style','text','String','Value:',                      'Parent', ui_sweepInputs, 'HorizontalAlignment','right') ;
                                    uicontrol('Style','text','String','Secondary Variable:',             'Parent', ui_sweepInputs, 'HorizontalAlignment','right') ;
                                    uicontrol('Style','text','String','Value:',                      'Parent', ui_sweepInputs, 'HorizontalAlignment','right') ;
    ui_sweepInputsPrimary = uiextras.HBox('Parent',ui_sweepInputs, 'Spacing', 5) ;
    gui.sweep.primary_variable =    uicontrol('Style','edit','String',default.sweep_primary,         'Parent', ui_sweepInputsPrimary, 'HorizontalAlignment','left','BackgroundColor',[1,1,1], 'KeyPressFcn', enterEventHandler (@runSweep)) ;
    gui.sweep.primary_variable_mode = uicontrol('Style','popupmenu','String',{'List', 'Optimize'}, 'Parent', ui_sweepInputsPrimary, 'Callback',@updateSweepOptimize, 'Value',default.sweep_primary_optimize_mode) ;
    ui_sweepInputsPrimary.Sizes = [-1, 100] ;
    ui_sweepOptimizeInputs = uiextras.HBox('Parent',ui_sweepInputs) ;gui.sweep.primary_optimize_view1 = ui_sweepOptimizeInputs ;
    gui.sweep.primary_value =       uicontrol('Style','edit','String',default.sweep_primary_value,   'Parent', ui_sweepOptimizeInputs, 'HorizontalAlignment','left','BackgroundColor',[1,1,1], 'KeyPressFcn', enterEventHandler (@runSweep)) ;
    ui_sweepOptimizeInputs = uiextras.HBox('Parent',gui.sweep.primary_optimize_view1, 'Spacing', 5, 'Visible', 'off') ;gui.sweep.primary_optimize_view2 = ui_sweepOptimizeInputs ;
                                    uicontrol('Style','text','String','Min:',                        'Parent', ui_sweepOptimizeInputs, 'HorizontalAlignment','right') ;
    gui.sweep.primary_optimize_min = uicontrol('Style','edit','String',default.sweep_primary_optimize_min,  'Parent', ui_sweepOptimizeInputs, 'HorizontalAlignment','left','BackgroundColor',[1,1,1], 'KeyPressFcn', enterEventHandler (@runSweep)) ;
                                        uicontrol('Style','text','String','Max:',                    'Parent', ui_sweepOptimizeInputs, 'HorizontalAlignment','right') ;
    gui.sweep.primary_optimize_max = uicontrol('Style','edit','String',default.sweep_primary_optimize_max,  'Parent', ui_sweepOptimizeInputs, 'HorizontalAlignment','left','BackgroundColor',[1,1,1], 'KeyPressFcn', enterEventHandler (@runSweep)) ;
                                        uicontrol('Style','text','String','Tol:',              'Parent', ui_sweepOptimizeInputs, 'HorizontalAlignment','right') ;
    gui.sweep.primary_optimize_tol = uicontrol('Style','edit','String',default.sweep_primary_optimize_tol,  'Parent', ui_sweepOptimizeInputs, 'HorizontalAlignment','left','BackgroundColor',[1,1,1], 'KeyPressFcn', enterEventHandler (@runSweep)) ;
    gui.sweep.primary_optimize_view1.Sizes = [-1,0] ;
    gui.sweep.primary_optimize_view2.Sizes = [40,-1,40,-1,40,-1] ;
    
    gui.sweep.secondary_variable =  uicontrol('Style','edit','String',default.sweep_secondary,       'Parent', ui_sweepInputs, 'HorizontalAlignment','left','BackgroundColor',[1,1,1], 'KeyPressFcn', enterEventHandler (@runSweep)) ;
    gui.sweep.secondary_value =     uicontrol('Style','edit','String',default.sweep_secondary_value, 'Parent', ui_sweepInputs, 'HorizontalAlignment','left','BackgroundColor',[1,1,1], 'KeyPressFcn', enterEventHandler (@runSweep)) ;
    set(ui_sweepInputs,'ColumnSizes',[120,-1],'RowSizes',[-1,-1,-1,-1]) ;
    
    ui_sweepOutputs =               uiextras.HBox('Parent', ui_sweep, 'Spacing', 10) ;
    gui.sweep.results =             axes ('Parent',uicontainer('Parent',ui_sweepOutputs), 'Units','Normalized', 'OuterPosition', [0,0,1,1]) ;
    %setAllowAxesZoom(gui.zoom,gui.sweep.results,false) ;
    ui_sweepOutputsSettings =       uiextras.VBox('Parent', ui_sweepOutputs, 'Spacing', 5) ;
    gui.sweep.cache_images =        uicontrol('Style','checkbox','String','Cache Inputs',            'Parent', ui_sweepOutputsSettings) ;
    gui.sweep.enable_zoom  =        uicontrol('Style','checkbox','String','Enable Zoom',            'Parent', ui_sweepOutputsSettings, 'Callback',@updateSweepGUI) ;
    gui.sweep.x_style =             uicontrol('Style','popupmenu','String',{'Linear X', 'Log X'}, 'Parent', ui_sweepOutputsSettings, 'Callback',@updateSweepGUI) ;
    gui.sweep.y_style =             uicontrol('Style','popupmenu','String',{'Linear Y', 'Log Y'}, 'Parent', ui_sweepOutputsSettings, 'Callback',@updateSweepGUI) ;
    gui.sweep.save_sweep =          uicontrol('String','Save', 'Parent', ui_sweepOutputsSettings, 'Callback',@saveSweep) ;
    gui.sweep.load_sweep =          uicontrol('String','Load', 'Parent', ui_sweepOutputsSettings, 'Callback',@loadSweep) ;
    
    gui.sweep.selected_data = uicontrol('Style', 'edit', 'Max',1e6, 'String','<HTML>', 'Parent', ui_sweepOutputsSettings) ;
    jTextEdit = findjobj(gui.sweep.selected_data, 'class', 'UIScrollPane') ;
    jTextEdit(end).getComponent(0).getComponent(0).setContentType('text/html') ;
    gui.sweep.load_sweep =          uicontrol('String','Save Optimization', 'Parent', ui_sweepOutputsSettings, 'Callback',@saveSweepOptimization) ;
                                    uiextras.Empty('Parent', ui_sweepOutputsSettings) ;
    ui_sweepOutputsSettings.Sizes = [25, 25, 25, 25, 30, 30, 75, 35, -1] ;
    ui_sweepOutputs.Sizes = [-1, 180] ;
    
    ui_progressBar =                uiextras.HBox('Parent', ui_sweep) ;
    [gui.sweep.progress_bar, hProgress] = javacomponent('javax.swing.JProgressBar', [], uicontainer('Parent',ui_progressBar,'Position',[0,0,300,200])) ;
    set(hProgress,'units','norm','position',[0,0,1,1]) ;
    gui.sweep.progress_bar.setMinimum(0) ; gui.sweep.progress_bar.setMaximum(100) ; gui.sweep.progress_bar.setStringPainted(true);
    gui.sweep.eta =                 uicontrol('Style','text','Parent',ui_progressBar) ;
    ui_progressBar.Sizes = [-1,50] ;
    
    ui_sweepButtons = uiextras.HBox('Parent', ui_sweep) ;
    gui.sweep.btn =                 uicontrol('String','Run', 'Parent', ui_sweepButtons, 'Callback', @runSweep) ;
    gui.sweep.cancel =                 uicontrol('String','Cancel', 'Parent', ui_sweepButtons, 'Callback', @progressCancel) ;
    ui_sweep.Sizes = [20,100,-1,20,30] ;
end
function runSweep (~,~,~)
    gui = getGUI() ;
    if gui.sweep.is_sweeping, return ; end
    
    if get(gui.sweep.sweep_script_enable,'Value') && strcmp(get(gui.sweep.sweep_script_enable,'Enable'),'on')
        loadDataFile('nogui') ;
        gui = getGUI() ;
        gui.data.sweep_images = gui.data.images ;
        gui.data.sweep_params = gui.data.params ;
        gui.data.sweep_settings = gui.data.settings ;
    end
    
    gui.sweep.is_sweeping = true ;
    gui.progress.callback = @(gui,progress) gui.sweep.progress_bar.setValue(100*(gui.sweep.progress + progress * (gui.sweep.next_progress - gui.sweep.progress))) ;

    
    cache_images = get(gui.sweep.cache_images,'Value') ;
    
    %% Run the Sweep
    try
        %% Load Parameters
        primary_variable = get(gui.sweep.primary_variable,'String') ;
        secondary_variable = get(gui.sweep.secondary_variable,'String') ;
        primary_variable_value = get(gui.sweep.primary_value,'String') ;
        secondary_variable_value = get(gui.sweep.secondary_value,'String') ;

        load_xml = ['<setting name="' primary_variable '">' primary_variable_value '</setting>'] ;
        if ~isempty(secondary_variable) && ~isempty(secondary_variable_value)
            load_xml = [load_xml '<setting name="' secondary_variable '">' secondary_variable_value '</setting>'] ;
        end
        if get(gui.sweep.primary_variable_mode,'Value') ~= 1
            load_xml = [load_xml '<setting name="opt_min">' get(gui.sweep.primary_optimize_min,'String') '</setting>'] ;
            load_xml = [load_xml '<setting name="opt_max">' get(gui.sweep.primary_optimize_max,'String') '</setting>'] ;
            load_xml = [load_xml '<setting name="opt_tol">' get(gui.sweep.primary_optimize_tol,'String') '</setting>'] ;
            optimize_variable = true ;
        else
            optimize_variable = false ;
        end
        load_params = loadMeasurementXML (['=<data>' load_xml '</data>']) ;
        primary_variable_value = load_params.(primary_variable) ;
        if isfield(load_params, secondary_variable)
            secondary_variable_value = num2cell(load_params.(secondary_variable)) ;
            primary_variable_value = repmat(reshape(load_params.(primary_variable),1,[]),length(secondary_variable_value),1) ;

        else
            secondary_variable_value = {1} ;
            secondary_variable = '' ;
        end

        if optimize_variable
            optimize_min = load_params.opt_min ;
            optimize_max = load_params.opt_max ;
            optimize_tol = load_params.opt_tol ;
            primary_variable_value = nan(length(secondary_variable_value), ceil(log2((optimize_max - optimize_min)/optimize_tol))) ;
        end


        gui.data.sweep = struct('datafile',get(gui.load.filename,'String'),...
                                'scriptfile',gui.run.filename.getSelectedItem,...
                                'primary_variable', primary_variable,...
                                'secondary_variable', secondary_variable) ;
        gui.data.sweep.primary_variable_value = primary_variable_value ;
        gui.data.sweep.secondary_variable_value = secondary_variable_value ;
        gui.data.sweep.results = cell(size(primary_variable_value)) ;
        gui.data.sweep.metric = nan(size(primary_variable_value)) ;
        if cache_images
            gui.data.sweep.images = cell(length(secondary_variable_value), length(primary_variable_value)) ;
            gui.data.sweep.params = cell(length(secondary_variable_value), length(primary_variable_value)) ;
        end
        
        
        gui.sweep.start_time = tic ;
        gui.progress.is_canceled = false ;
        gui.progress.is_paused = false ;
        set(gui.progress.status,'String',[]) ;
        for sv=1:length(secondary_variable_value)
            for pv=1:size(primary_variable_value,2)
                if optimize_variable
                    delta = inf ;
                    if pv == 1, gui.data.sweep.primary_variable_value(sv,pv) = optimize_min ;
                    elseif pv == 2, gui.data.sweep.primary_variable_value(sv,pv) = optimize_max ;
                    else
                        [~, I] = sort(gui.data.sweep.metric(sv,:)) ;
                        delta = gui.data.sweep.primary_variable_value(sv,I(2)) - gui.data.sweep.primary_variable_value(sv,I(1)) ;
                        gui.data.sweep.primary_variable_value(sv,pv) = gui.data.sweep.primary_variable_value(sv,I(1)) + delta / 2 ;
                    end
                    if abs(delta) <= optimize_tol
                        break ;
                    end
                end
                % Progress variables for progress bars
                gui.sweep.progress = ((sv-1)*length(secondary_variable_value) + (pv-1))/(length(secondary_variable_value)*length(primary_variable_value)) ;
                gui.sweep.next_progress = ((sv-1)*length(secondary_variable_value) + pv)/(length(secondary_variable_value)*length(primary_variable_value)) ;

                % Set up parameters for loadDataFile
                gui.sweep.parameters = struct(gui.data.sweep.primary_variable, gui.data.sweep.primary_variable_value(sv,pv)) ;
                if ~isempty(gui.data.sweep.secondary_variable), gui.sweep.parameters.(gui.data.sweep.secondary_variable) = gui.data.sweep.secondary_variable_value{sv} ; end
                getGUI (gui) ;
                
                updateSweepGUI() ;
                drawnow ;
                
                % Run Sweep
                loadDataFile('nogui') ;
                runFile() ;
                gui = getGUI() ;
                % Save Results
                if gui.progress.is_canceled, break ; end
                gui.data.sweep.results{sv,pv} = gui.data.results ;
                gui.data.sweep.metric(sv,pv) = gui.data.results.error_metric ;
                if cache_images
                    gui.data.sweep.images{sv,pv} = gui.data.images ;
                    gui.data.sweep.params{sv,pv} = gui.data.params ;
                end
                
                % Keep order when optimizing
                if optimize_variable
                    [gui.data.sweep.primary_variable_value(sv,:), I] = sort(gui.data.sweep.primary_variable_value(sv,:)) ;
                    gui.data.sweep.results(sv,:) = gui.data.sweep.results(sv,I) ;
                    gui.data.sweep.metric(sv,:) = gui.data.sweep.metric(sv,I) ;
                    if cache_images
                        gui.data.sweep.images(sv,:) = gui.data.sweep.images(sv,I) ;
                        gui.data.sweep.params(sv,:) = gui.data.sweep.images(sv,I) ;
                    end
                end
            end
            if gui.progress.is_canceled, break ; end
        end
        % Reset Everything
        gui.sweep.is_sweeping = false ; gui.progress.is_paused = false ; gui.progress.is_canceled = false ;
        gui.data.sweep_images = [] ; gui.data.sweep_params = [] ; gui.data.sweep_settings = [] ;
        gui.sweep.parameters = [] ;
        gui.progress.callback = [] ;
        getGUI(gui) ;
        updateSweepGUI() ;
        updateEnabled();
        drawnow ;
        % Save Settings
        save_struct = struct('sweep_primary', get(gui.sweep.primary_variable,'String'), ...
                             'sweep_secondary', get(gui.sweep.secondary_variable,'String'), ...
                             'sweep_primary_value', get(gui.sweep.primary_value,'String'), ...
                             'sweep_secondary_value', get(gui.sweep.secondary_value,'String'), ...
                             'sweep_script', get(gui.sweep.sweep_script,'String'), ...
                             'sweep_script_enable', get(gui.sweep.sweep_script_enable,'Value'), ...
                             'sweep_primary_optimize_max', get(gui.sweep.primary_optimize_max,'String'), ...
                             'sweep_primary_optimize_min', get(gui.sweep.primary_optimize_min,'String'), ...
                             'sweep_primary_optimize_tol', get(gui.sweep.primary_optimize_tol,'String'), ...
                             'sweep_primary_optimize_mode', get(gui.sweep.primary_variable_mode,'Value')) ; %#ok<NASGU>
        save ('defaults.mat', '-struct', 'save_struct', '-append') ;
    catch e
        % Reset Everything
        gui.sweep.is_sweeping = false ; gui.progress.is_paused = false ; gui.progress.is_canceled = false ;
        gui.data.sweep_images = [] ; gui.data.sweep_params = [] ; gui.data.sweep_settings = [] ;
        gui.sweep.parameters = [] ;
        gui.progress.callback = [] ;
        getGUI(gui) ;
        updateSweepGUI() ;
        updateEnabled();
        drawnow ;
        % Save Settings
        save_struct = struct('sweep_primary', get(gui.sweep.primary_variable,'String'), ...
                             'sweep_secondary', get(gui.sweep.secondary_variable,'String'), ...
                             'sweep_primary_value', get(gui.sweep.primary_value,'String'), ...
                             'sweep_secondary_value', get(gui.sweep.secondary_value,'String'), ...
                             'sweep_script', get(gui.sweep.sweep_script,'String'), ...
                             'sweep_script_enable', get(gui.sweep.sweep_script_enable,'Value'), ...
                             'sweep_primary_optimize_max', get(gui.sweep.primary_optimize_max,'String'), ...
                             'sweep_primary_optimize_min', get(gui.sweep.primary_optimize_min,'String'), ...
                             'sweep_primary_optimize_tol', get(gui.sweep.primary_optimize_tol,'String'), ...
                             'sweep_primary_optimize_mode', get(gui.sweep.primary_variable_mode,'Value')) ; %#ok<NASGU>
        save ('defaults.mat', '-struct', 'save_struct', '-append') ;
        errordlg(['Script Failed with error: ' e.message]) ;
        rethrow(e) ;
    end
end
function updateSweepGUI (~,~,~)
    gui = getGUI() ;
    zoom(gui.figure,'out') ;
    if isfield(gui.data, 'sweep')
        set (gui.sweep.results, 'ColorOrder', varycolor(length(gui.data.sweep.secondary_variable_value))) ;
        cla (gui.sweep.results) ; hold (gui.sweep.results,'on') ; plots = zeros(1,size(gui.data.sweep.primary_variable_value,1)) ;
        ColorSet = varycolor(length(plots)) ;
        for i=1:size(gui.data.sweep.primary_variable_value,1)
            plots(i) = plot (gui.sweep.results, gui.data.sweep.primary_variable_value(i,:), gui.data.sweep.metric(i,:), ...
                                 '-', 'Color', ColorSet(i,:), 'Marker','.', 'MarkerSize',20, 'ButtonDownFcn', @sweepMouseClick) ;
        end
        xlabel(gui.sweep.results,gui.data.sweep.primary_variable, 'Interpreter', 'none') ;
        gui.sweep.current_marker = plot (gui.sweep.results,1,1,'.r','MarkerSize',30,'Visible','off') ;
        gui.sweep.select_marker = plot (gui.sweep.results,1,1,'ok','MarkerSize',10,'Visible','off') ;
        hold (gui.sweep.results,'off');
        if length(gui.data.sweep.primary_variable_value) > 1 % allows the data to be centered when only one primary variable is used
            xl = [min(gui.data.sweep.primary_variable_value(:))-eps, max(gui.data.sweep.primary_variable_value(:))+eps] ;
            if isequal(~isnan(xl),[1,1]), xlim (gui.sweep.results,'auto') ; end
        end
        if ~isempty(gui.data.sweep.secondary_variable)
            legend(plots, cellfun(@(x)['@' gui.data.sweep.secondary_variable '=' valueToChar(x)], gui.data.sweep.secondary_variable_value,'UniformOutput',false),'Interpreter','none') ;
        end
        getGUI(gui) ;
        set(gui.sweep.results, 'ButtonDownFcn', @sweepMouseClick) ;
        set(gcf,'WindowButtonMotionFcn', @figMouseHover) ;
        set(get(gui.sweep.results,'Children'),'HitTest','off');
    end
    title(gui.sweep.results,'Sweep Progress') ;
    ylabel(gui.sweep.results,'Error') ;
    if get(gui.sweep.x_style,'Value') == 2, set(gui.sweep.results, 'XScale', 'Log') ;
    else set(gui.sweep.results, 'XScale', 'Linear') ; end
    if get(gui.sweep.y_style,'Value') == 2, set(gui.sweep.results, 'YScale', 'Log') ;
    else set(gui.sweep.results, 'YScale', 'Linear') ; end
    
    if gui.sweep.is_sweeping
        algorithm_progress = gui.progress.progress_bar.getValue / 100 ;
        gui.sweep.progress_bar.setValue(100*(gui.sweep.progress + algorithm_progress * (gui.sweep.next_progress - gui.sweep.progress))) ;
        set(gui.sweep.eta,'String',getETA(gui.sweep.start_time, gui.sweep.progress)) ;
        if ~isempty(gui.data.sweep.secondary_variable)
            gui.sweep.progress_bar.setString(['@' gui.data.sweep.primary_variable '=' valueToChar(gui.sweep.parameters.(gui.data.sweep.primary_variable)) ', @' gui.data.sweep.secondary_variable '=' valueToChar(gui.sweep.parameters.(gui.data.sweep.secondary_variable))])
            gui.run.callbacks.status(['<font color="blue">Sweep: @' gui.data.sweep.primary_variable '=' valueToChar(gui.sweep.parameters.(gui.data.sweep.primary_variable)) ', @' gui.data.sweep.secondary_variable '=' valueToChar(gui.sweep.parameters.(gui.data.sweep.secondary_variable)) '</font>']) ;
        else
            gui.sweep.progress_bar.setString(['@' gui.data.sweep.primary_variable '=' valueToChar(gui.sweep.parameters.(gui.data.sweep.primary_variable))])
            gui.run.callbacks.status(['<font color="blue">Sweep: @' gui.data.sweep.primary_variable '=' valueToChar(gui.sweep.parameters.(gui.data.sweep.primary_variable)) '</font>']) ;
        end
    else
        gui.sweep.progress_bar.setValue(100) ;
        gui.sweep.progress_bar.setString('Complete') ;
        set(gui.sweep.eta,'String','') ;
    end
    zoom(gui.figure,'reset') ;
    setAllowAxesZoom(gui.zoom,gui.sweep.results,get(gui.sweep.enable_zoom,'Value')) ;
end
function updateSweepOptimize (~,~,~)
    gui = getGUI() ;
    if get(gui.sweep.primary_variable_mode,'Value') == 1
        gui.sweep.primary_optimize_view1.Sizes = [-1,0] ;
        set(gui.sweep.primary_optimize_view2,'Visible','off') ;
        set(gui.sweep.primary_value,'Visible','on') ;
    else
        gui.sweep.primary_optimize_view1.Sizes = [0,-1] ;
        set(gui.sweep.primary_optimize_view2,'Visible','on') ;
        set(gui.sweep.primary_value,'Visible','off') ;
    end
end
function sweepMouseHover (~,~,~)
    h = hittest ;
    if ~isa(handle(h),'axes'), return ; end
    gui = getGUI() ;
    if h ~= gui.sweep.results, return ; end
    if ~isfield(gui.sweep,'select_marker') || ~ishandle(gui.sweep.select_marker), return ; end
    if gui.load.is_loading, set(gui.sweep.select_marker,'Visible','off') ;
    else set(gui.sweep.select_marker,'Visible','on') ; end
    pos = get(gui.sweep.results,'CurrentPoint');
    
    I = getClosestPoint (gui.sweep.results, pos(1,1), pos(1,2), ...
                          gui.data.sweep.primary_variable_value(:), ...
                          reshape(gui.data.sweep.metric,[],1)) ;
    if I == 0
        sel_data_str = '' ;
    else
        [j,i] = ind2sub(size(gui.data.sweep.metric),I) ;
        set(gui.sweep.select_marker,'XData', gui.data.sweep.primary_variable_value(j,i), ...
                                    'YData', gui.data.sweep.metric(j,i), ...
                                    'Visible', 'on') ;
        sel_data_str = {['<b>@' gui.data.sweep.primary_variable ' =</b> ' valueToChar(gui.data.sweep.primary_variable_value(i))]} ;
        if ~isempty (gui.data.sweep.secondary_variable)
            sel_data_str = [sel_data_str ...
                            {['<br><b>@' gui.data.sweep.secondary_variable ' =</b> ' valueToChar(gui.data.sweep.secondary_variable_value{j})]}] ;
        end
        sel_data_str = [sel_data_str {'<br><b>Error:</b> ' sprintf('%.3e', gui.data.sweep.metric(j,i))}] ;
    end
    set(gui.sweep.selected_data,'String',sel_data_str) ;
end
function sweepMouseClick (~,~,~)
    gui = getGUI() ;
    %if isequal(get(gui.sweep.results,'Color'),[1,1,1]*0.98), return ; end
    set(gui.sweep.results,'Color',[1,1,1]*0.98) ;
    pos = get(gui.sweep.results,'CurrentPoint');
    I = getClosestPoint (gui.sweep.results, pos(1,1), pos(1,2), ...
                          gui.data.sweep.primary_variable_value(:), ...
                          reshape(gui.data.sweep.metric,[],1)) ;
    if I ~= 0
        [j,i] = ind2sub(size(gui.data.sweep.metric),I) ;

        if isfield(gui.data.sweep,'images')
            gui.data.images = gui.data.sweep.images{j,i} ;
            gui.data.params = gui.data.sweep.params{j,i} ;
            gui.view.image_index = 1 ;
            set(gui.view.settings, 'Data', paramToTable(gui.data.settings)) ;
        else
            if get(gui.sweep.sweep_script_enable,'Value') && strcmp(get(gui.sweep.sweep_script_enable,'Enable'),'on')
                loadDataFile('nogui') ;
                gui = getGUI() ;
                gui.data.sweep_images = gui.data.images ;
                gui.data.sweep_params = gui.data.params ;
                gui.data.sweep_settings = gui.data.settings ;
            end
            gui = getGUI() ;
            gui.sweep.parameters = struct(gui.data.sweep.primary_variable, gui.data.sweep.primary_variable_value(j,i)) ;
            if ~isempty(gui.data.sweep.secondary_variable), gui.sweep.parameters.(gui.data.sweep.secondary_variable) = gui.data.sweep.secondary_variable_value{j} ; end
            gui.sweep.is_sweeping = true ;
            gui.data.sweep_images = gui.data.images ; gui.data.sweep_params = gui.data.params ; gui.data.sweep_settings = gui.data.settings ;
            getGUI(gui) ;
            loadDataFile ('nogui') ;
            gui = getGUI() ;
            gui.data.sweep_images = [] ; gui.data.sweep_params = [] ; gui.data.sweep_settings = [] ;
            gui.sweep.is_sweeping = false ;
            gui.sweep.parameters = [] ;
        end
        gui.data.results = gui.data.sweep.results{j,i} ;
        set(gui.progress.status,'String',gui.data.results.log) ;
        if ishandle(gui.sweep.current_marker)
            set(gui.sweep.current_marker,'XData', gui.data.sweep.primary_variable_value(j,i), ...
                                        'YData', gui.data.sweep.metric(j,i), ...
                                        'Visible', 'on') ;
        end
    end
    
    getGUI(gui) ;
    updateDataGUI() ;
    updateResultsGUI() ;
    updateReconstructionGUI() ;
    updateEnabled();
    set(gui.ui_tabPanel, 'SelectedChild', 5) ;
    set(gui.sweep.results,'Color',[1,1,1]) ;
    
end
function saveSweep (~,~,~)
    persistent path ;
    if isempty(path), path = pwd ; end
    gui = getGUI() ;
    [filename, path] = uiputfile('*.mat', 'Save Sweep',path) ;
    gui.is_saving = true ;
    getGUI(gui) ;
    updateEnabled() ;
    drawnow ;
    sweep = gui.data.sweep ; %#ok<NASGU>
    save ([path filename],'sweep') ;
    gui.is_saving = false ;
    getGUI(gui) ;
    updateEnabled() ;
end
function loadSweep (~,~,~)
    persistent path ;
    if isempty(path), path = pwd ; end
    [filename, path] = uigetfile('*.mat', 'Load Sweep',path) ;
    
    gui = getGUI() ;
    gui.sweep.is_loading = true ; getGUI(gui) ; updateEnabled() ; drawnow ;
    sweepFile = load ([path filename]) ;
    if ~isfield(sweepFile,'sweep'), errordlg('Invalid saved sweep.') ; return ; end
    gui.data.sweep = sweepFile.sweep ;
    set(gui.load.filename,'String',gui.data.sweep.datafile) ;
    gui.run.filename.setSelectedItem(gui.data.sweep.scriptfile) ;
    gui.sweep.is_loading = false ; getGUI(gui) ; updateEnabled() ;
    updateSweepGUI();
end
function saveSweepOptimization (~,~,~)
    persistent path ;
    if isempty(path), path = pwd ; end
    gui = getGUI() ;
    [filename, path] = uiputfile('*.mat', 'Save Sweep',path) ;
    filename = [path filename] ;
    [~,I] = min(gui.data.sweep.metric,[],2) ;
    data = zeros(1,length(I)) ;
    for i=1:length(data), data(i) = gui.data.sweep.primary_variable_value(i,I(i)) ; end
    data_struct = struct(gui.data.sweep.primary_variable, data) ; %#ok<NASGU>
    if exist(filename,'file')
        save (filename, '-struct', 'data_struct', '-append') ;
    else
        save (filename, '-struct', 'data_struct') ;
    end
end
function sweepPickScript(~,~,~)
    gui = getGUI () ;
    filename = get(gui.sweep.sweep_script,'String') ;
    if ~exist(filename,'file'), filename = pwd ; end
    [filename, path] = uigetfile('*.xml', 'Select Sweep Script',filename) ;
    if ~ischar(filename), return ; end
    set(gui.sweep.sweep_script,'String',[relativepath(path,pwd) filename]) ;
    set(gui.sweep.sweep_script_enable,'Value',true) ;
    updateEnabled();
end

%% Optimize
function gui = optimizeGUI (ui_tabPanel, gui)
    %% Saved Settings
    default = struct ('optimize_script','',...
                      'optimize_script_enable',false) ;
    if exist('defaults.mat','file')
        saved_settings = load('defaults.mat') ;
        if isfield(saved_settings,'optimize_script'), default.optimize_script = saved_settings.optimize_script ; end
        if isfield(saved_settings,'optimize_script_enable'), default.optimize_script_enable = saved_settings.optimize_script_enable ; end
    end
    
    gui.optimize = struct('is_running',false) ;

    ui_sweep = uiextras.VBoxFlex ('Parent', ui_tabPanel, 'Spacing', 5) ;
    
    ui_sweepScript = uiextras.HBox ('Parent', ui_sweep, 'Spacing', 5) ;
                                   uicontrol('Style','text','String','Script:',             'Parent', ui_sweepScript, 'HorizontalAlignment','right') ;
    gui.optimize.script    = uicontrol('Style','edit','String',default.optimize_script,         'Parent', ui_sweepScript, 'HorizontalAlignment','left','BackgroundColor',[1,1,1], 'KeyPressFcn', enterEventHandler (@(~,~,~)0)) ;
    gui.optimize.select          = uicontrol('String',['<HTML><img width="16" height="16" src="file:/' strrep(fullfile([pwd '/icons/file.png']),filesep,'/') '">'],'Parent', ui_sweepScript, 'Callback', @optimizePickScript) ;
    gui.optimize.script_enable   = uicontrol('Style','checkbox','String','','Value',default.optimize_script_enable,             'Parent', ui_sweepScript, 'HorizontalAlignment','right') ;
    ui_sweepScript.Sizes = [120,-1,30,20] ;
    
    ui_sweepOutputs =               uiextras.HBoxFlex('Parent', ui_sweep, 'Spacing', 10) ;
    gui.optimize.results =             axes ('Parent',uicontainer('Parent',ui_sweepOutputs), 'Units','Normalized', 'OuterPosition', [0,0,1,1]) ;
    setAllowAxesZoom(gui.zoom, gui.optimize.results, false) ;
    
    gui.optimize.optimization_parameters = uicontrol('Style', 'edit', 'Max',1e6, 'String','', 'Parent', ui_sweepOutputs, ...
                                                     'HorizontalAlignment','left','BackgroundColor',[1,1,1]) ;
    gui.optimize.joptimization_parameters = findjobj(gui.optimize.optimization_parameters) ;
    gui.optimize.joptimization_parameters = gui.optimize.joptimization_parameters.getComponent(0).getComponent(0) ;
    gui.optimize.joptimization_parameters.setContentType('text/html') ;
    gui.optimize.joptimization_parameters.setText('<pre>') ;
    ui_sweepOutputs.Sizes = [-7, -5] ;
    
    ui_progressBar =                uiextras.HBox('Parent', ui_sweep) ;
    [gui.optimize.progress_bar, hProgress] = javacomponent('javax.swing.JProgressBar', [], uicontainer('Parent',ui_progressBar,'Position',[0,0,300,200])) ;
    set(hProgress,'units','norm','position',[0,0,1,1]) ;
    gui.optimize.progress_bar.setMinimum(0) ; gui.optimize.progress_bar.setMaximum(100) ; gui.optimize.progress_bar.setStringPainted(true);
    gui.optimize.eta =                 uicontrol('Style','text','Parent',ui_progressBar) ;
    ui_progressBar.Sizes = [-1,50] ;
    
    ui_sweepButtons = uiextras.HBox('Parent', ui_sweep) ;
    gui.optimize.btn    = uicontrol('String','Run', 'Parent', ui_sweepButtons, 'Callback', @runOptimization) ;
    gui.optimize.cancel = uicontrol('String','Cancel', 'Parent', ui_sweepButtons, 'Callback', @progressCancel) ;
    
    
    ui_sweep.Sizes = [20,-1,20, 30] ;
end
function parseOptimizationScript (~,~,~)
    gui = getGUI() ;
    %if gui.sweep.is_sweeping, return ; end
    %{
    set "____" to ____
    minimize "____" for ____
    minimize "____" between ____ and ____ to ____
    %}
    
    optimization_steps = cell(0,1) ;
    
    optimize_script = char(gui.optimize.joptimization_parameters.getText()) ;
    optimize_script = regexprep(optimize_script,'.*<pre>|</pre>.*','') ;
    optimize_script = regexprep(optimize_script,'(<font color(-[0-9]+)?="[^"]*">)|</font>|<font class="[0-9]+"[^<]*</font>|<s>|</s>','');
    optimize_script = regexprep(optimize_script,'\n','<br>');
    optimize_script = regexp(optimize_script,'<br>','split');
    format_str = '' ;
    for i=1:length(optimize_script)
        if ~isempty(format_str), format_str = [format_str '<font color="black"> <br></font>'] ; end %#ok<AGROW>
        try
            str = optimize_script{i} ;
            str = strrep(str,'&quot;','"') ;
            optimization_line = regexp(str, '(?<operation>minimize|maximize)\s+"(?<fieldname>[A-Za-z_0-9]*)"\s+between\s+(?<min>.*)\s+and(?<max>.*)\s+to(?<precision>.*)\s*', 'names') ;
            if isempty(optimization_line), optimization_line = regexp(str, '(?<operation>minimize|maximize)\s+"(?<fieldname>[A-Za-z_0-9]*)"\s+for\s+(?<list>.*)\s*', 'names') ; end
            if isempty(optimization_line), optimization_line = regexp(str, '(?<operation>set)\s+"(?<fieldname>[A-Za-z_0-9]*)"\s+to\s+(?<value>.*)\s*', 'names') ; end
            if isempty(optimization_line)
                throw 'Invalid optimization command' ;
            end
            optimization_item = struct ('index', length(optimization_steps) + 1, 'direction', optimization_line.operation, 'name', optimization_line.fieldname, ...
                                    'values',[], 'results', []) ;
            if isfield(optimization_line, 'list'),
                optimization_item.type = 'list' ;
                load_xml = ['<setting name="list">' optimization_line.list '</setting>'] ;
                params = loadMeasurementXML (['=<data>' load_xml '</data>']) ;
                optimization_item.list = params.list ;
                optimization_item.runs = length(optimization_item.list) ;
            elseif isfield(optimization_line, 'min')
                optimization_item.type = 'search' ;
                load_xml = ['<setting name="min">' optimization_line.min '</setting>' ...
                            '<setting name="max">' optimization_line.max '</setting>' ...
                            '<setting name="precision">' optimization_line.precision '</setting>'] ;
                params = loadMeasurementXML (['=<data>' load_xml '</data>']) ;
                optimization_item.min = params.min ;
                optimization_item.max = params.max ;
                optimization_item.precision = params.precision ;
                if ~isnumeric(optimization_item.min) || ~isnumeric(optimization_item.max) || ~isnumeric(optimization_item.precision)
                    throw 'Invalid min/max/precision' ;
                end
                optimization_item.runs = ceil(log2((optimization_item.max - optimization_item.min)/optimization_item.precision)) ;
            elseif isfield(optimization_line, 'value')
                optimization_item.type = 'set' ;
                load_xml = ['<setting name="value">' optimization_line.value '</setting>'] ;
                params = loadMeasurementXML (['=<data>' load_xml '</data>']) ;
                optimization_item.value = params.value;
                optimization_item.runs = 0 ;
            else
                throw 'Invalid line' ;
            end
            optimization_steps{optimization_item.index} = optimization_item ;
            format_str = sprintf('%s<font color-%d="green">%s</font><font class="%d"> </font> ', format_str,optimization_item.index, strtrim(optimize_script{i}), optimization_item.index) ;
        catch e
            format_str = sprintf('%s<font color="red"><s>%s</s></font>', format_str, strtrim(optimize_script{i})) ;
        end
    end
    gui.optimize.joptimization_parameters.setText(['<pre>' format_str]) ;
    
    if get(gui.optimize.script_enable,'Value') && strcmp(get(gui.optimize.script_enable,'Enable'),'on')
        loadDataFile('nogui') ;
        gui = getGUI() ;
        gui.data.sweep_images = gui.data.images ;
        gui.data.sweep_params = gui.data.params ;
        gui.data.sweep_settings = gui.data.settings ;
    end
    
    gui.optimize.script = optimization_steps ;
    getGUI(gui) ;
end
function runOptimization (~,~,~)
    parseOptimizationScript() ;
    gui = getGUI();
    
    gui.optimize.is_running = true ;
    gui.sweep.is_sweeping = true ;
    gui.progress.is_paused = false ;
    gui.progress.is_canceled = false ;
    
    gui.optimize.progress = 0 ;
    gui.optimize.total_progress = sum(arrayfun(@(x)x{1}.runs,gui.optimize.script)) ;
    gui.progress.callback = @(gui,progress) gui.optimize.progress_bar.setValue(100*(gui.optimize.progress + progress) / gui.optimize.total_progress) ;

    getGUI(gui) ;
    updateOptimizeGUI() ;
    updateEnabled();
    
    for i=1:length(gui.optimize.script)
        cont = optimizeScript(i) ;
        if ~cont
            break ;
        end
    end
    
    gui = getGUI() ;
    gui.sweep.is_sweeping = false ;
    gui.optimize.is_running = false ;
    gui.progress.is_paused = false ;
    gui.progress.is_canceled = false ;
    gui.data.sweep_images = [] ; gui.data.sweep_params = [] ; gui.data.sweep_settings = [] ;
    gui.progress.callback = [] ;
    getGUI(gui) ;
    updateOptimizeGUI() ;
    updateEnabled();
end
function all_good = optimizeScript (index)
    gui = getGUI() ;
    param = gui.optimize.script{index} ;

    variable_values = nan(1, param.runs) ;
    variable_results = nan(1, param.runs) ;
    switch param.direction
        case 'minimize'
            compare_function = @min ;
        case 'maximize'
            compare_function = @max ;
        case 'set'
            compare_function = [] ;
        otherwise
            throw 'Invalid compare method' ;
    end
    switch param.type
        case 'set'
            param.target = param.value ;
            gui.optimize.script{param.index} = param ;
        case 'list'
            variable_values = param.list ;
            if isnumeric(variable_values), variable_values = num2cell(variable_values) ; end
            for i=1:param.runs
                % Set up parameters for loadDataFile
                gui.sweep.parameters = struct() ;
                for s=1:(param.index-1)
                    p = gui.optimize.script{s} ;
                    gui.sweep.parameters.(p.name) = p.target ;
                end
                gui.sweep.parameters.(param.name) = variable_values{i} ;

                getGUI (gui) ;
                
                updateOptimizeGUI() ;

                % Run Sweep
                loadDataFile('nogui') ;
                runFile() ;
                gui = getGUI() ;
                
                % Store Results
                if gui.progress.is_canceled, break ; end
                variable_results(i) = gui.data.results.error_metric ;
                [param.value, I] = compare_function(variable_results) ;
                param.target = variable_values{I} ;
                param.values = variable_values ;
                param.results = variable_results ;
                gui.optimize.script{param.index} = param ;
                gui.optimize.progress = gui.optimize.progress + 1 ;
                gui.progress.callback(gui,0) ;
            end
            if ~gui.progress.is_canceled
                
            else
                
            end
        case 'search'
            for i=1:param.runs
                if i == 1, variable_values(i) = param.min ;
                elseif i == 2, variable_values(i) = param.max ;
                else
                    [~, I] = sort(variable_results) ;
                    delta = variable_values(I(2)) - variable_values(I(1)) ;
                    variable_values(i) = variable_values(I(1)) + delta / 2 ;
                end
                
                gui.sweep.parameters = struct() ;
                for s=1:(param.index-1)
                    p = gui.optimize.script{s} ;
                    gui.sweep.parameters.(p.name) = p.target ;
                end
                gui.sweep.parameters.(param.name) = variable_values(i) ;
                getGUI (gui) ;
                
                updateOptimizeGUI() ;

                % Run Sweep
                loadDataFile('nogui') ;
                runFile() ;
                gui = getGUI() ;
                
                % Store Results
                if gui.progress.is_canceled, break ; end
                variable_results(i) = gui.data.results.error_metric ;
                [param.value, I] = compare_function(variable_results) ;
                param.target = variable_values(I) ;
                param.values = variable_values ;
                param.results = variable_results ;
                gui.optimize.script{param.index} = param ;
                gui.optimize.progress = gui.optimize.progress + 1 ;
                gui.progress.callback(gui,0) ;
            end
    end
    gui.sweep.parameters = [] ;
    getGUI(gui) ;
    all_good = ~gui.progress.is_canceled ;
end
function updateOptimizeGUI (~,~,~)
    gui = getGUI() ;
    
    optimize_script = char(gui.optimize.joptimization_parameters.getText()) ;
    
    axes(gui.optimize.results) ; %#ok<MAXES>
    cla ;
    set(gca, 'YScale', 'log', 'YGrid', 'on') ;
    hold on ;
    last_index = 0 ;
    ColorSet = varycolor(length(gui.optimize.script) + 1) ;
    ColorSet = ColorSet (2:end,:) ;
    for i=1:length(gui.optimize.script)
        param = gui.optimize.script{i} ;
        plot (last_index + (1:length(param.results)), param.results, 'o-', 'Color', ColorSet(i,:)) ;
        last_index = last_index + length(param.results) ;
        optimize_script = strrep(optimize_script, ['color-' num2str(param.index) '="green">'], ...
                            ['color="#' dec2hex(round(ColorSet(i,1)*255),2) dec2hex(round(ColorSet(i,2)*255),2) dec2hex(round(ColorSet(i,3)*255),2) '">']) ;
        if isfield(param, 'target') && ~isempty(param.target)
            optimize_script = regexprep(optimize_script, sprintf('<font class="%d"[^<]+</font>', param.index), ...
                                sprintf('<font class="%d"> --&gt; %.4e</font>', param.index, param.target)) ;
        end
    end
    gui.optimize.joptimization_parameters.setText(optimize_script) ;
    drawnow ;
end
function optimizePickScript(~,~,~)
    gui = getGUI () ;
    filename = get(gui.optimize.script,'String') ;
    if ~exist(filename,'file'), filename = pwd ; end
    [filename, path] = uigetfile('*.xml', 'Select Optimization Script',filename) ;
    if ~ischar(filename), return ; end
    set(gui.optimize.script,'String',[relativepath(path,pwd) filename]) ;
    set(gui.optimize.script_enable,'Value',true) ;
    updateEnabled();
end

%% Parameters
function gui = parametersGUI (ui_tabPanel, gui)
    default = struct ('parameters_ref_file','',...
                      'parameters_ref_enable',0) ;
    if exist('defaults.mat','file')
        saved_settings = load('defaults.mat') ;
        if isfield(saved_settings,'parameters_ref_file'), default.parameters_ref_file = saved_settings.parameters_ref_file ; end
        if isfield(saved_settings,'parameters_ref_enable'), default.parameters_ref_enable = saved_settings.parameters_ref_enable ; end
    end


    ui_loadFile = uiextras.VBox ('Parent', ui_tabPanel, 'Spacing', 5) ;
    
    ui_loadRef            = uiextras.HBox ('Parent', ui_loadFile, 'Spacing', 5) ;
                            uicontrol('Style','text','String','Refrence Data:',             'Parent', ui_loadRef, 'HorizontalAlignment','right','FontSize',10) ;
    gui.load.ref_file     = uicontrol('Style','edit','String',default.parameters_ref_file,         'Parent', ui_loadRef, 'HorizontalAlignment','left','BackgroundColor',[1,1,1], 'KeyPressFcn', enterEventHandler (@(~,~,~)0)) ;
    gui.load.ref_selec    = uicontrol('String',['<HTML><img width="16" height="16" src="file:/' strrep(fullfile([pwd '/icons/file.png']),filesep,'/') '">'],'Parent', ui_loadRef, 'Callback', @parametersPickRef) ;
    gui.load.ref_enable   = uicontrol('Style','checkbox','String','','Value',default.parameters_ref_enable,             'Parent', ui_loadRef, 'HorizontalAlignment','right') ;
    ui_loadRef.Sizes = [120,-1,30,20] ;
    
    
    ui_loadFileParams = uiextras.HBox ('Parent', ui_loadFile) ;
    uicontrol('String','Parameters:','Style','text','Parent',ui_loadFileParams,'FontSize',14) ;
    gui.load.parameters = uitable('Parent',ui_loadFileParams,...
                                  'ColumnEditable',[false,true,true],'ColumnName',{'Name','Value','Delete'},'ColumnFormat',{'char','char',{' ','Delete'}},...
                                  'ColumnWidth',{140,210,48}, 'RowName',[], ...
                                  'Data', cell(0,3),'CellEditCallback',@editLoadParameter) ;
    
    ui_loadFileParamsAdd = uiextras.HBox('Parent',ui_loadFile, 'Spacing', 5) ;
    uiextras.Empty('Parent',ui_loadFileParamsAdd) ;
    uicontrol('String','Add:','Style','text','Parent',ui_loadFileParamsAdd,'FontSize',12) ;
    gui.load.add_parameter = uicontrol('Style','edit','Parent',ui_loadFileParamsAdd, ...
                              'BackgroundColor',[1,1,1],'FontSize',14, 'HorizontalAlignment','left') ;
    uicontrol('String','Add','Parent',ui_loadFileParamsAdd,'FontSize',12,'Callbac',@addParameter) ;
    
    ui_loadFile.Sizes = [25,-1,25] ;
    ui_loadFileParams.Sizes = [150,-1] ;
    ui_loadFileParamsAdd.Sizes = [150,80,-1,80] ;
    
end
function addParameter (~,~,~)
    gui = getGUI() ;
    param_name = get(gui.load.add_parameter,'String') ;
    parameters = get(gui.load.parameters, 'Data') ;
    parameters = [parameters; [{param_name}, {''}, {' '}]] ;
    set(gui.load.parameters, 'Data',parameters) ;
    set(gui.load.add_parameter,'String','') ;
end
function editLoadParameter (h,eventdata,~)
    if eventdata.Indices(2) == 3 && strcmp(eventdata.EditData,'Delete')
        parameters = get(h,'Data') ;
        parameters(eventdata.Indices(1),:) = [] ;
        set(h,'Data',parameters) ;
    end
end
function parametersPickRef(~,~,~)
    gui = getGUI () ;
    filename = get(gui.load.ref_file,'String') ;
    if ~exist(filename,'file'), filename = pwd ; end
    [filename, path] = uigetfile('*.xml', 'Select Reference File',filename) ;
    if ~ischar(filename), return ; end
    set(gui.load.ref_file,'String',[relativepath(path,pwd) filename]) ;
    set(gui.load.ref_enable,'Value',true) ;
    updateEnabled();
end

%% View Images
function gui = dataGUI (ui_tabPanel, gui)
    ui_viewData = uiextras.HBoxFlex ('Parent',ui_tabPanel,'Spacing',10) ;
    ui_viewDataPlots = uiextras.VBox ('Parent',ui_viewData,'Spacing',20) ;
    ui_viewDataProperties = uiextras.VBoxFlex('Parent',ui_viewData,'Spacing',5) ;
    ui_viewDataPropertiesControl = uiextras.HBox('Parent',ui_viewDataProperties) ;
    
    gui.view.previous_image = uicontrol('String','Previous','Parent',ui_viewDataPropertiesControl, 'Callback', @(~,~,~)selectImage('data-previous')) ;
    gui.view.count_image = uicontrol('String','0 / 0','Style','text','Parent',ui_viewDataPropertiesControl,'FontSize',16) ;
    gui.view.next_image = uicontrol('String','Next','Parent',ui_viewDataPropertiesControl, 'Callback', @(~,~,~)selectImage('data-next')) ;
    gui.view.properties = uitable ('Parent', ui_viewDataProperties, 'RowName',[],'ColumnName',{'Name','Value'},...
                                   'ColumnWidth',{100,160}) ;
    gui.view.histogram = axes ('Parent',uicontainer('Parent',ui_viewDataProperties), 'Units','Normalized', 'OuterPosition', [0,0,1,1]) ;
    setAllowAxesZoom(gui.zoom,gui.view.histogram,false) ;
    %Plot Controls:
    ui_viewPlotControls = uiextras.Grid('Parent',ui_viewDataProperties) ;
    gui.view.show_dc = uicontrol('String','Show DC','Style','Checkbox','Parent',ui_viewPlotControls, 'Callback', @updateDataGUI) ;
    gui.view.constant_colorbar = uicontrol('String','Constant Colorbar','Style','Checkbox','Parent',ui_viewPlotControls, 'Callback', @updateDataGUI) ;
    gui.view.fourier_crop = uicontrol('String','Crop','Style','Checkbox','Parent',ui_viewPlotControls, 'Callback', @updateDataGUI) ;
    gui.view.showNA   = uicontrol('String','Show NA','Style','Checkbox','Parent',ui_viewPlotControls, 'Callback', @updateDataGUI) ;
    gui.view.field_colormap = uicontrol('Style', 'popupmenu', 'Parent', ui_viewPlotControls, 'String', {'jet', 'gray'}, 'Callback', @updateDataGUI) ;
    gui.view.fourier_crop_factor = uicontrol('Style','Slider','Parent',ui_viewPlotControls, ...
                                    'Value',1.4, 'Min',1, 'Max',3, 'SliderStep',[0.1,0.5], 'Callback',@updateDataGUI) ;
    gui.view.show_log = uicontrol('String','Log Scale','Style','Checkbox','Parent',ui_viewPlotControls, 'Callback', @updateDataGUI) ;
    set(ui_viewPlotControls, 'ColumnSizes', [-1 -1 -1], 'RowSizes', [-1 -1 -1] );
    ui_viewDataProperties.Sizes = [30,-3,-2,75] ;
    
    gui.view.intensity        = axes ('Parent',uicontainer('Parent',ui_viewDataPlots), 'Units','Normalized', 'OuterPosition', [0,0,1,1]) ;
    fourierSelectorPadding    = uiextras.HBox('Parent',ui_viewDataPlots) ;
    uiextras.Empty ('Parent', fourierSelectorPadding) ;
    gui.view.fourier_selector = uicontrol('Style','popupmenu','String',{'Fourier'}, 'Parent', fourierSelectorPadding, 'Callback',@updateDataGUI, 'Value',1) ;
    uiextras.Empty ('Parent', fourierSelectorPadding) ;
    fourierSelectorPadding.Sizes = [-1, 150, -1] ;
    gui.view.fourier          = axes ('Parent',uicontainer('Parent',ui_viewDataPlots), 'Units','Normalized', 'OuterPosition', [0,0,1,1]) ;
    ui_viewDataPlots.Sizes = [-1,20,-1] ;
end
function selectImage (value)
    gui = getGUI () ;
    switch value
        case 'data-next'
            gui.view.image_index = min(size(gui.data.images,3),gui.view.image_index + 1) ;
            getGUI (gui) ;
            updateDataGUI() ;
        case 'data-previous'
            gui.view.image_index = max(gui.view.image_index - 1,1) ;
            getGUI (gui) ;
            updateDataGUI() ;
        case 'reconstruction-next'
            gui.results.reconstruction_image_index = min(size(gui.data.images,3),gui.results.reconstruction_image_index + 1) ;
            getGUI (gui) ;
            updateReconstructionGUI()
        case 'reconstruction-previous'
            gui.results.reconstruction_image_index = max(gui.results.reconstruction_image_index - 1,1) ;
            getGUI (gui) ;
            updateReconstructionGUI()
    end
end
function updateDataGUI (~,~,~)
    gui = getGUI() ;
    zoom(gui.figure,'out') ;
    gui.view.image_index = max(1,min(gui.view.image_index, size(gui.data.images,3))) ;
    if ~isempty(gui.data.images) && size(gui.data.images,3) >= gui.view.image_index
        img = gui.data.images(:,:,gui.view.image_index) ;
        param = gui.data.params{gui.view.image_index} ;
        x = (0:(size(gui.data.images,1)-1))*param.pixel_size ;
        y = (0:(size(gui.data.images,2)-1))*param.pixel_size ;
        fx = (floor(-size(gui.data.images,1)/2):ceil(size(gui.data.images,1)/2-1))/(size(gui.data.images,1)*param.pixel_size) ;
        fy = (floor(-size(gui.data.images,2)/2):ceil(size(gui.data.images,2)/2-1))/(size(gui.data.images,2)*param.pixel_size) ;
    else
        img = [] ;
        param = struct('NA',1,'wavelength',1) ;
        x = []; y=[]; fx = []; fy=[] ;
    end
    
    
    if ~isfield(param,'NA')
        set (gui.view.showNA, 'Enable','off');
    else
        set (gui.view.showNA, 'Enable','on');
    end
    
    
    view_types = {'Fourier'} ;
    if isfield (param,'pupil'), view_types = [view_types, {'Pupil (Amplitude)', 'Pupil (Phase)'}] ; end
    if isfield (param,'illumination') && ~ischar(param.illumination), view_types = [view_types, {'Illumination'}] ; end
    if ~isequal(get(gui.view.fourier_selector,'String'),view_types')
        set(gui.view.fourier_selector,'Value',1) ;
    end
    set(gui.view.fourier_selector,'String', view_types) ;
    switch view_types{get(gui.view.fourier_selector,'Value')}
        case 'Pupil (Amplitude)'
            [Fx,Fy] = ndgrid(fx*param.wavelength, fy*param.wavelength) ;
            img_fft = abs(param.pupil(Fx,Fy)) ;
        case 'Pupil (Phase)'
            [Fx,Fy] = ndgrid(fx*param.wavelength, fy*param.wavelength) ;
            img_fft = angle(param.pupil(Fx,Fy)) * 180 / pi + 180 ;
        case 'Illumination'
            [Fx,Fy] = ndgrid(fx*param.wavelength, fy*param.wavelength) ;
            img_fft = real(param.illumination(Fx,Fy)) ;
        case 'Fourier'
            img_fft = abs(fftshift(fft2(img))) / length(img) ;
    end
    
    set(gui.view.properties, 'Data', paramToTable(param)) ;
    
    if ~get(gui.view.show_dc,'Value')
        img_fft = removeDC(img_fft) ;
    end
    if get(gui.view.show_log,'Value')
        img_fft = log10(img_fft) ;
    end
    
    %% Plot Real Image
    cla(gui.view.intensity) ;
    
    [scale_factor, label] = valueToScale ([x(:); y(:)]) ;
    imagesc(x*scale_factor, y*scale_factor, img, 'Parent',gui.view.intensity) ;
    xlabel (gui.view.intensity, label) ;
    ylabel (gui.view.intensity, label) ;
    title (gui.view.intensity, 'Image Intensity') ;
    axis (gui.view.intensity, 'xy') ;
    axis (gui.view.intensity, 'image') ;
    axis (gui.view.intensity, 'tight') ;
    
    if get(gui.view.constant_colorbar,'Value')
        mcolorbar(gui.view.intensity, gui.colormaps.(getCurrentPopupString(gui.view.field_colormap)), ...
            'clim', [min(gui.data.images(:)), max(gui.data.images(:))]) ;
    else
        mcolorbar(gui.view.intensity, gui.colormaps.(getCurrentPopupString(gui.view.field_colormap))) ;
    end
    
    hold(gui.view.intensity,'on');
    gui.view.intensity_info = plot(gui.view.intensity,0,0,'r.','Visible','off','HitTest','off') ;
    gui.view.intensity_infotext = text(0.95,0.95,{},'Parent',gui.view.intensity,'Visible','off') ;
    set(gui.view.intensity,'UserData',struct('click',@dataGUI_clickreal)) ;
    
    %% Plot Fourier Transform
    [scale_factor, label] = valueToScale (1./[fx(:); fy(:)]) ;
    imagesc(fx/scale_factor, fy/scale_factor, img_fft, 'Parent',gui.view.fourier) ;
    xlabel (gui.view.fourier, [label '^{-1}']) ;
    ylabel (gui.view.fourier, [label '^{-1}']) ;
    title (gui.view.fourier, 'Image Intensity Spectrum') ;
    axis (gui.view.fourier, 'xy') ;
    axis (gui.view.fourier, 'equal') ;
    axis (gui.view.fourier, 'tight') ;
    if get(gui.view.fourier_crop,'Value')
        fourier_crop_factor = get(gui.view.fourier_crop_factor,'Value') ;
        xlim (gui.view.fourier,[-1,1]*param.NA/param.wavelength/scale_factor*fourier_crop_factor) ;
        ylim (gui.view.fourier,[-1,1]*param.NA/param.wavelength/scale_factor*fourier_crop_factor) ;
    end
    mcolorbar(gui.view.fourier, jet(64)) ;
    
    %% Show NA
    if get(gui.view.showNA,'Value') && isfield(param,'NA')
        rectangle ('Position', [-1,-1,2,2]*param.NA/param.wavelength/scale_factor, 'Curvature', [1,1], 'EdgeColor', [1,1,1], 'LineWidth', 2, 'Parent', gui.view.fourier) ;
    end
    
    %% Plot Histogram
    hist(gui.view.histogram,img(:), 50) ;
    xlabel (gui.view.histogram, 'Intensity') ;
    title (gui.view.histogram, 'Image Intensity Histogram') ;
    if min(gui.data.images(:)) ~= max(gui.data.images(:))
        if ~isempty(gui.data.images), xlim (gui.view.histogram, [min(gui.data.images(:)), max(gui.data.images(:))]) ; end
    end
    text(0.95,0.95,{...
        sprintf('Mean: %.3f',mean(img(:))),...
        sprintf('Std: %.3f', std(img(:)))...
    },'Units','Normalized','Parent',gui.view.histogram,'HorizontalAlignment','right','VerticalAlignment','top') ;
    
    if size(gui.data.images,3) == 0 || gui.view.image_index == size(gui.data.images,3), set(gui.view.next_image,'Enable','off') ;
    else set(gui.view.next_image,'Enable','on') ; end
    if size(gui.data.images,3) == 0 || gui.view.image_index == 1, set(gui.view.previous_image,'Enable','off') ; 
    else set(gui.view.previous_image,'Enable','on') ; end
    if size(gui.data.images,3) == 0, set(gui.view.count_image,'String','0 / 0') ;    
    else set(gui.view.count_image,'String',sprintf('%.0f / %.0f', gui.view.image_index, size(gui.data.images,3))) ; end
    
    getGUI(gui);
    zoom(gui.figure,'reset') ;
end
function dataGUI_clickreal(x,y)
    gui = getGUI() ;
    h = get(gui.view.intensity,'children') ;
    h = h(arrayfun(@(x)isa(handle(x),'image'),h));
    xl = get(h,'XData') ;
    yl = get(h,'YData') ;
    x = xl(x) ;
    y = yl(y) ;
    set(gui.view.intensity_info,'XData',x,'YData',y,'Visible','on') ;
    h_axLabels = get(gui.view.intensity,{'XLabel' 'YLabel'});
    txt = {sprintf('From Center:'), ...
           sprintf('  \\Delta x = %.2f%s', x - mean(xl), get(h_axLabels{1},'String')), ...
           sprintf('  \\Delta y = %.2f%s', y - mean(yl), get(h_axLabels{2},'String'))} ;
    set(gui.view.intensity_infotext,'Position',[x,y],'String',txt,'Visible','on');
end

%% View Results
function gui = resultsGUI (ui_tabPanel, gui)
    hPanel = uiextras.HBoxFlex ('Parent', ui_tabPanel, 'Spacing', 10) ;
    vPanel_left  = uiextras.VBoxFlex ('Parent', hPanel, 'Spacing', 10) ;
    vPanel_right = uiextras.VBoxFlex ('Parent', hPanel, 'Spacing', 10) ;
    vPanel_options = uiextras.VBox ('Parent', hPanel, 'Spacing', 5) ;
    hPanel.Sizes = [-1,-1,100] ;
    
    gui.results = struct() ;
    gui.data.results.fields = cell(0,2) ;
    gui.data.results.fields_fourier = cell(0,2) ;
    gui.data.results.params = [] ;
    gui.data.results.callback_real = @(x,y) 1 ;
    gui.data.results.callback_fourier = @(x,y) 1 ;
    
    gui.results.left_select = uicontrol('Style', 'popupmenu', 'Parent', vPanel_left, ...
                                        'String', ' ', 'Callback', @updateResultsGUI) ;
    gui.results.left_real    = axes ('Parent',uicontainer('Parent',vPanel_left), 'Units','Normalized', 'OuterPosition', [0,0,1,1]) ;
    gui.results.left_fourier = axes ('Parent',uicontainer('Parent',vPanel_left), 'Units','Normalized', 'OuterPosition', [0,0,1,1]) ;
    vPanel_left.Sizes = [25,-1,-1] ;
    
    gui.results.right_select = uicontrol('Style', 'popupmenu', 'Parent', vPanel_right, ...
                                        'String', ' ', 'Callback', @updateResultsGUI) ;
    gui.results.right_real    = axes ('Parent',uicontainer('Parent',vPanel_right), 'Units','Normalized', 'OuterPosition', [0,0,1,1]) ;
    gui.results.right_fourier = axes ('Parent',uicontainer('Parent',vPanel_right), 'Units','Normalized', 'OuterPosition', [0,0,1,1]) ;
    vPanel_right.Sizes = [25,-1,-1] ;
    
    
    gui.results.field_showNA   = uicontrol('String','Show NA','Style','Checkbox','Parent',vPanel_options, 'Callback', @updateResultsGUI) ;
    gui.results.field_showDC   = uicontrol('String','DC','Style','Checkbox','Parent',vPanel_options, 'Callback', @updateResultsGUI) ;
    gui.results.field_logScale = uicontrol('String','Log','Style','Checkbox','Parent',vPanel_options, 'Callback', @updateResultsGUI) ;
    gui.results.field_crop = uicontrol('String','Crop','Style','Checkbox','Parent',vPanel_options, 'Callback', @updateResultsGUI) ;
    gui.results.field_cropFactor = uicontrol('Style','Slider','Parent',vPanel_options, ...
                                             'Value',1.4, 'Min',1, 'Max',3, 'SliderStep',[0.1,0.5], 'Callback',@updateResultsGUI) ;
    gui.results.field_colormap = uicontrol('Style', 'popupmenu', 'Parent', vPanel_options, 'Value', 1, 'String', {'jet', 'gray'}, 'Callback', @updateResultsGUI) ;
    uiextras.Empty('Parent', vPanel_options) ;
    vPanel_options.Sizes = [25,25,25,25,25,25,-1] ;
end
function updateResultsGUI (~,~,~)
    gui = getGUI() ;
    zoom(gui.figure,'out') ;
    real_options = gui.data.results.fields(:,1) ;
    fft_options = gui.data.results.fields_fourier(:,1) ;
    plot_options = [real_options; fft_options] ;
    if isempty(plot_options), plot_options = ' ' ; end
    if ~isequal(plot_options,get(gui.results.left_select,'String'))
        set(gui.results.left_select,'String',plot_options) ;
        set(gui.results.left_select,'Value',1) ;
    end
    if ~isequal(plot_options,get(gui.results.right_select,'String'))
        set(gui.results.right_select,'String',plot_options) ;
        set(gui.results.right_select,'Value',min(length(plot_options),2)) ;
    end
    
    if isfield(gui.data,'params') && ~isempty(gui.data.params)
        param = gui.data.params{1} ;
        img_size = size(gui.data.images) ;
        x = (0:(img_size(1)-1))*param.pixel_size ;
        y = (0:(img_size(2)-1))*param.pixel_size ;
        fx = (floor(-img_size(1)/2):ceil(img_size(1)/2-1))/(img_size(1)*param.pixel_size) ;
        fy = (floor(-img_size(2)/2):ceil(img_size(2)/2-1))/(img_size(2)*param.pixel_size) ;
        [scale_factor_re, label_re] = valueToScale ([x(:); y(:)]) ;
        [scale_factor_ft, label_ft] = valueToScale (1./[fx(:); fy(:)]) ;
    else
        return ;
    end
    %% Left Image
    left_select = get(gui.results.left_select,'Value') ;
    if left_select <= length(real_options)
        img = gui.data.results.fields{left_select,2} ;
        img_fft = abs(fftshift(fft2(img)) / length(img)) ;
        imagesc(x*scale_factor_re, y*scale_factor_re, img, 'Parent', gui.results.left_real) ;
    elseif left_select <= length(real_options) + length(fft_options)
        cla(gui.results.left_real) ;
        img_fft = real(gui.data.results.fields_fourier{left_select - length(real_options),2}) ;
    else
        img = []; img_fft = [] ;
        cla(gui.results.left_real) ;
    end
    xlabel (gui.results.left_real, label_re) ; ylabel (gui.results.left_real, label_re) ;
    axis (gui.results.left_real, 'xy') ; axis (gui.results.left_real, 'image') ;
    mcolorbar(gui.results.left_real, gui.colormaps.(getCurrentPopupString(gui.results.field_colormap))) ;
    if get(gui.results.field_logScale,'Value'), img_fft = log10(img_fft) ; end
    if ~get(gui.results.field_showDC,'Value'), img_fft = removeDC(img_fft,'nan') ; end
    imagesc(fx/scale_factor_ft, fy/scale_factor_ft, img_fft, 'Parent', gui.results.left_fourier) ;
    xlabel (gui.results.left_fourier, [label_ft '^{-1}']) ; ylabel (gui.results.left_fourier, [label_ft '^{-1}']) ;
    axis (gui.results.left_fourier, 'xy') ; axis (gui.results.left_fourier, 'image') ;
    mcolorbar(gui.results.left_fourier, gui.colormaps.fourier) ;
    if get(gui.results.field_showNA,'Value')
        rectangle ('Position', [-1,-1,2,2]*param.NA/param.wavelength/scale_factor_ft, 'Curvature', [1,1], 'EdgeColor', [1,1,1], 'LineWidth', 2, 'Parent', gui.results.left_fourier) ;
    end
    set(gui.results.left_fourier,'UserData', struct('click',gui.data.results.callback_fourier)) ;
    set(gui.results.left_real,'UserData', struct('click',gui.data.results.callback_real)) ;

    
    %% Right image
    right_select = get(gui.results.right_select,'Value') ;
    if right_select <= length(real_options)
        img = gui.data.results.fields{right_select,2} ;
        img_fft = abs(fftshift(fft2(img)) / length(img)) ;
    elseif right_select <= length(real_options) + length(fft_options)
        img_fft = real(gui.data.results.fields_fourier{right_select - length(real_options),2}) ;
        img = zeros(size(img_fft)) ;
    else
        img = []; img_fft = [] ;
        cla(gui.results.right_real) ;
    end
    imagesc(x*scale_factor_re, y*scale_factor_re, img, 'Parent', gui.results.right_real) ;
    xlabel (gui.results.right_real, label_re) ; ylabel (gui.results.right_real, label_re) ;
    axis (gui.results.right_real, 'xy') ; axis (gui.results.right_real, 'image') ;
    mcolorbar(gui.results.right_real, gui.colormaps.(getCurrentPopupString(gui.results.field_colormap))) ;
    if get(gui.results.field_logScale,'Value'), img_fft = log10(img_fft) ; end
    if ~get(gui.results.field_showDC,'Value'), img_fft = removeDC(img_fft,'nan') ; end
    imagesc(fx/scale_factor_ft, fy/scale_factor_ft, img_fft, 'Parent', gui.results.right_fourier) ;
    xlabel (gui.results.right_fourier, [label_ft '^{-1}']) ; ylabel (gui.results.right_fourier, [label_ft '^{-1}']) ;
    axis (gui.results.right_fourier, 'xy') ; axis (gui.results.right_fourier, 'image') ;
    mcolorbar(gui.results.right_fourier, gui.colormaps.fourier) ;
    if get(gui.results.field_showNA,'Value')
        rectangle ('Position', [-1,-1,2,2]*param.NA/param.wavelength/scale_factor_ft, 'Curvature', [1,1], 'EdgeColor', [1,1,1], 'LineWidth', 2, 'Parent', gui.results.right_fourier) ;
    end
    set(gui.results.right_fourier,'UserData', struct('click',gui.data.results.callback_fourier)) ;
    set(gui.results.right_real,'UserData', struct('click',gui.data.results.callback_real)) ;
    
    if get(gui.results.field_crop,'Value')
        fourier_crop_factor = get(gui.results.field_cropFactor,'Value') ;
        xlim (gui.results.right_fourier,[-1,1]*param.NA/param.wavelength/scale_factor_ft*fourier_crop_factor) ;
        ylim (gui.results.right_fourier,[-1,1]*param.NA/param.wavelength/scale_factor_ft*fourier_crop_factor) ;
        xlim (gui.results.left_fourier,[-1,1]*param.NA/param.wavelength/scale_factor_ft*fourier_crop_factor) ;
        ylim (gui.results.left_fourier,[-1,1]*param.NA/param.wavelength/scale_factor_ft*fourier_crop_factor) ;
    end
    drawnow ;
    zoom(gui.figure,'reset') ;
end

%% View Reconstruction
function gui = reconstructionGUI (ui_tabPanel, gui)
    gui.results.reconstruction_edgecropamounts = [0, 0.01, 0.02, 0.05, 0.1, 0.2] ;
    gui.results.reconstruction_fourierzoomamounts = [Inf, 0.5, 0.75, 1, 1.1, 1.2, 1.3, 1.5, 2, 3] ;
    gui.results.reconstruction_errormetricoptions = {struct('name', 'L2 Norm',              'fn', @(x,y)norm(x(:)-y(:),2),   'yscale', 'linear', 'code', 'L2'), ...
                                                     struct('name', 'L2 Norm (Log Plot)',   'fn', @(x,y)norm(x(:)-y(:),2),   'yscale', 'log',    'code', 'L2'), ...
                                                     struct('name', 'Max Error',            'fn', @(x,y)max(abs(x(:)-y(:))), 'yscale', 'linear', 'code', 'LINFINITY'), ...
                                                     struct('name', 'Max Error (Log Plot)', 'fn', @(x,y)max(abs(x(:)-y(:))), 'yscale', 'log',    'code', 'LINFINITY')} ;

    ui_resultsReconstruction = uiextras.GridFlex ('Parent', ui_tabPanel, 'Spacing', 10) ;
    gui.results.reconstruction_input = axes ('Parent',uicontainer('Parent',ui_resultsReconstruction), 'Units','Normalized', 'OuterPosition', [0,0,1,1]) ;
    gui.results.reconstruction_recon = axes ('Parent',uicontainer('Parent',ui_resultsReconstruction), 'Units','Normalized', 'OuterPosition', [0,0,1,1]) ;
    
    ui_resultsReconstructionHist = uiextras.VBox ('Parent',ui_resultsReconstruction,'Spacing',5) ;
    ui_resultsReconstructionHistH = uiextras.HBox ('Parent',ui_resultsReconstructionHist,'Spacing',5) ;
    ui_resultsReconstructionError = uiextras.VBox ('Parent',ui_resultsReconstructionHistH,'Spacing',5) ;
    ui_resultsReconstructionOptions = uiextras.Grid ('Parent', ui_resultsReconstructionHistH, 'Spacing', 5) ;
    gui.results.reconstruction_hist = axes ('Parent',uicontainer('Parent',ui_resultsReconstructionHist), 'Units','Normalized', 'OuterPosition', [0,0,1,1]) ;
    gui.results.reconstruction_error = axes ('Parent',uicontainer('Parent',ui_resultsReconstruction), 'Units','Normalized', 'OuterPosition', [0,0,1,1]) ;
    set(ui_resultsReconstruction,'ColumnSizes',[-1,-1],'RowSizes',[-1,-1]) ;
    ui_resultsReconstructionHistH.Sizes = [-1,130*2] ;
    
    setAllowAxesZoom(gui.zoom,gui.results.reconstruction_hist,false) ;
    
    errorSelectorPadding    = uiextras.HBox('Parent',ui_resultsReconstructionError) ;
    uiextras.Empty ('Parent', errorSelectorPadding) ;
    gui.results.reconstruction_errormetric = uicontrol('Style','popupmenu','String',arrayfun(@(x)x{1}.name,gui.results.reconstruction_errormetricoptions,'UniformOutput',false), 'Parent', errorSelectorPadding, 'Callback',@updateReconstructionGUI, 'Value',1) ;
    uiextras.Empty ('Parent', errorSelectorPadding) ;
    errorSelectorPadding.Sizes = [-1, 150, -1] ;
    gui.results.reconstruction_errorplot = axes ('Parent',uicontainer('Parent',ui_resultsReconstructionError), 'Units','Normalized', 'OuterPosition', [0,0,1,1]) ;
    uiextras.Empty ('Parent', ui_resultsReconstructionError) ;
    ui_resultsReconstructionError.Sizes = [25,180,-1] ;
    
    gui.results.reconstruction_previous = uicontrol('String','Previous', 'Parent', ui_resultsReconstructionOptions, 'Callback', @(~,~,~)selectImage('reconstruction-previous')) ;
    gui.results.reconstruction_mode = uicontrol('Style','popupmenu','String',{'Real Space', 'Fourier Space'}, 'Parent', ui_resultsReconstructionOptions, 'Callback',@updateReconstructionGUI) ;
    gui.results.recon_field_colormap = uicontrol('Style', 'popupmenu', 'Parent', ui_resultsReconstructionOptions, 'String', {'jet', 'gray'}, 'Callback', @updateReconstructionGUI) ;
    gui.results.reconstruction_showDC   = uicontrol('String','Show DC','Style','Checkbox','Parent',ui_resultsReconstructionOptions, 'Callback', @updateReconstructionGUI) ;
    gui.results.reconstruction_logScale = uicontrol('String','Log','Style','Checkbox','Parent',ui_resultsReconstructionOptions, 'Callback', @updateReconstructionGUI) ;
    uiextras.Empty('Parent',ui_resultsReconstructionOptions) ;
    uiextras.Empty('Parent',ui_resultsReconstructionOptions) ;
    
    gui.results.reconstruction_next = uicontrol('String','Next', 'Parent', ui_resultsReconstructionOptions, 'Callback', @(~,~,~)selectImage('reconstruction-next')) ;
    gui.results.reconstruction_image_count = uicontrol('String','0 / 0','Style','text','Parent',ui_resultsReconstructionOptions,'FontSize',16) ;
    gui.results.reconstruction_constColorbar = uicontrol('String','Constant Colorbar','Style','Checkbox','Parent',ui_resultsReconstructionOptions, 'Callback', @updateReconstructionGUI) ;
    gui.results.reconstruction_showNA = uicontrol('String','Show NA','Style','Checkbox','Parent',ui_resultsReconstructionOptions, 'Callback', @updateReconstructionGUI) ;
    edgecroptext = strcat({''}, num2str(gui.results.reconstruction_edgecropamounts'*100,'%.0f%%')) ;
        edgecroptext{1} = 'No Edge Crop' ;
        gui.results.reconstruction_edgecropfactor = uicontrol('Style', 'popupmenu', 'Parent', ui_resultsReconstructionOptions, 'Callback', @updateReconstructionGUI, 'String', edgecroptext) ;
    fourierzoomtext = strcat({''}, num2str(gui.results.reconstruction_fourierzoomamounts','%.1f NA'));
        fourierzoomtext{1} = 'No Filter' ;
        gui.results.reconstruction_fourierzoomfactor = uicontrol('Style', 'popupmenu', 'Parent', ui_resultsReconstructionOptions, 'Callback', @updateReconstructionGUI, 'String', fourierzoomtext) ;
    set(ui_resultsReconstructionOptions,'ColumnSizes',[130,130], 'RowSizes',[25,25,25,25,25,25,-1]) ;
    gui.results.reconstruction_image_index = 1 ;
end
function updateReconstructionGUI (~,~,~)
    gui = getGUI() ;
    zoom(gui.figure,'out') ;
    fourier_crop_factor = gui.results.reconstruction_fourierzoomamounts(get(gui.results.reconstruction_fourierzoomfactor,'Value')) ;
    gui.results.reconstruction_image_index = max(min(gui.results.reconstruction_image_index, size(gui.data.images,3)), size(gui.data.images,3) >= 1) ;
    if gui.results.reconstruction_image_index > 0 && isfield(gui.data.results,'reconstruction') && isequal(size(gui.data.results.reconstruction), size(gui.data.images))
        guiimages = gui.data.images ;
        guirecon = gui.data.results.reconstruction ;
        edge_crop = round([size(guiimages,1), size(guiimages,2)] * gui.results.reconstruction_edgecropamounts(get(gui.results.reconstruction_edgecropfactor,'Value'))) ;
        guiimages = guiimages(edge_crop(1) + (1:(size(guiimages,1)-2*edge_crop(1))), ...
                              edge_crop(2) + (1:(size(guiimages,2)-2*edge_crop(2))),:) ;
        guirecon = guirecon(edge_crop(1) + (1:(size(guirecon,1)-2*edge_crop(1))), ...
                            edge_crop(2) + (1:(size(guirecon,2)-2*edge_crop(2))),:) ;
        param = gui.data.params{gui.results.reconstruction_image_index} ;
        x = ((0:(size(guiimages,1)-1)) + edge_crop(1))*param.pixel_size ;
        y = ((0:(size(guiimages,2)-1)) + edge_crop(2))*param.pixel_size ;
        fx = (floor(-size(guiimages,1)/2):ceil(size(guiimages,1)/2-1))/(size(guiimages,1)*param.pixel_size) ;
        fy = (floor(-size(guiimages,2)/2):ceil(size(guiimages,2)/2-1))/(size(guiimages,2)*param.pixel_size) ;
        
        if isfield(param,'NA') && isfield(param,'wavelength') && (fourier_crop_factor * param.NA / param.wavelength < 1 / param.pixel_size)
            [fxx, fyy] = meshgrid(fx, fy) ;
            filt = (fxx.^2 + fyy.^2) <= (fourier_crop_factor * param.NA / param.wavelength)^2 ;
            for i=1:size(guiimages,3)
                guiimages(:,:,i) = ifft2(ifftshift(fftshift(fft2(guiimages(:,:,i))) .* filt)) ;
                guirecon(:,:,i)  = ifft2(ifftshift(fftshift(fft2(guirecon(:,:,i)))  .* filt)) ;
            end
        end
        
        img       = guiimages(:,:,gui.results.reconstruction_image_index) ;
        img_recon = guirecon (:,:,gui.results.reconstruction_image_index) ;
    else
        guiimages = [1] ; guirecon = [1] ;
        img = [1] ; img_recon = [1] ;
        param = struct() ;
        x = [1]; y=[1]; fx = [1]; fy=[1] ;
    end
    
    %% Error Histogram
    error_pts = img(:) - img_recon(:) ;
    cla(gui.results.reconstruction_hist) ;
    if isfield(gui.results, 'reconstruction_hist_legend') && ishandle(gui.results.reconstruction_hist_legend), delete(gui.results.reconstruction_hist_legend) ; end
    hold(gui.results.reconstruction_hist,'on') ;
    if length(error_pts) > 1
        hist(gui.results.reconstruction_hist, img(:),50) ;
        hist(gui.results.reconstruction_hist, error_pts + mean(img(:)),50) ;
        hist(gui.results.reconstruction_hist, img(:),50) ;
        if isfield(gui.data.results,'reconstruction') && size(guirecon,3) == size(guiimages,3)
            xlim(gui.results.reconstruction_hist, [min([min(guiimages(:)), min(guiimages(:)-guirecon(:) + mean(guiimages(:)))]), ...
                                                   max([max(guiimages(:)), max(guiimages(:)-guirecon(:) + mean(guiimages(:)))])]) ;
        end
        hg = findobj(gui.results.reconstruction_hist,'Type','patch') ; set(hg(1),'FaceColor','none','EdgeColor','r') ;
        set(hg(2),'FaceColor','g','EdgeColor','g') ; set(hg(3),'FaceColor','r','EdgeColor','r') ;
        xlabel (gui.results.reconstruction_hist, 'Intensity') ;
        title (gui.results.reconstruction_hist, 'Histogram of Error') ;
        gui.results.reconstruction_hist_legend = legend (hg(2:3),'Error', 'Image') ;
        text(0.05,0.95,{...
            sprintf('Error Mean: %.1e [%.1e, %.1e]',mean(error_pts),min(error_pts),max(error_pts)),...
            sprintf('Error Std: %.1e', std(error_pts)),...
            sprintf('Img Mean: %.1e [%.1e, %.1e]',mean(img(:)),min(img(:)),max(img(:))),...
            sprintf('Img Std: %.1e', std(img(:)))...
        },'Units','Normalized','Parent',gui.results.reconstruction_hist,'HorizontalAlignment','left','VerticalAlignment','top') ;
    end
    
    %% Error Metric
    error_fn = gui.results.reconstruction_errormetricoptions{get(gui.results.reconstruction_errormetric,'Value')} ;
    if size(guiimages,3) == size(guirecon,3) && gui.results.reconstruction_image_index > 0
        cla(gui.results.reconstruction_errorplot);hold(gui.results.reconstruction_errorplot,'on');
        error_metric = arrayfun(@(x)error_fn.fn(guiimages(:,:,x),guirecon(:,:,x)), 1:size(guiimages,3)) ;
        gui.results.reconstruction_errorplotcurve = plot(gui.results.reconstruction_errorplot,1:length(error_metric), error_metric, 'ko-','MarkerSize',5) ;
        plot (gui.results.reconstruction_errorplot,gui.results.reconstruction_image_index,error_metric(gui.results.reconstruction_image_index),'.k','MarkerSize',15) ;
        gui.results.reconstruction_errormetricselect_marker = plot (gui.results.reconstruction_errorplot,1,1,'.b','MarkerSize',15,'Visible','off') ;
        xlim(gui.results.reconstruction_errorplot,[1-eps,length(error_metric)+eps]) ;
        set(gui.results.reconstruction_errorplot,'YScale',error_fn.yscale) ;
        gui.results.reconstruction_errormetric_text = text('Parent',gui.results.reconstruction_errorplot, 'Position', [0,0], 'String', '','VerticalAlignment','top','HorizontalAlignment','right','Visible','off') ;
    else
        cla(gui.results.reconstruction_errorplot) ;
    end
    xlabel(gui.results.reconstruction_errorplot, 'Image #', 'FontSize', 8);
    ylabel(gui.results.reconstruction_errorplot, 'Error', 'FontSize', 8);
    set(gui.results.reconstruction_errorplot, 'ButtonDownFcn', @reconstructionErrorMouseClick) ;
    set(gcf,'WindowButtonMotionFcn', @figMouseHover) ;
    set(get(gui.results.reconstruction_errorplot,'Children'),'HitTest','off');

    %% Plots
    switch get(gui.results.reconstruction_mode,'Value')
        case 1 %real space
            [scale_factor, label] = valueToScale ([x(:); y(:)]) ;
            cx = x*scale_factor ; cy = y*scale_factor ;
            img_error = img - img_recon ;
            mimg = img ; mimg_recon = img_recon ; mimg_error = img_error ;
        case 2 %fourier space
            [scale_factor, label] = valueToScale (1./[fx(:); fy(:)]) ;
            label = [label '^{-1}'] ;
            cx = fx/scale_factor ; cy = fy/scale_factor ;
            
            img = fftshift(fft2(img)) / length(img) ;
            img_recon = fftshift(fft2(img_recon)) / length(img_recon) ;
            img_error = img - img_recon ;
            if ~get(gui.results.reconstruction_showDC,'Value')
                img = removeDC(img) ;
                img_recon = removeDC(img_recon) ;
                img_error = removeDC(img_error) ;
            end
            if get(gui.results.reconstruction_logScale,'Value')
                mimg = log10(img) ;
                mimg_recon = log10(img_recon) ;
            else mimg = img ; mimg_recon = img_recon ; end
            mimg = abs(mimg) ; mimg_recon = abs(mimg_recon) ; mimg_error = abs(img_error) ;
    end
    gui.results.current_values = struct('img', img, 'recon', img_recon, 'error', img_error, 'unit_str', label) ;
    
    %% Plot Original Image
    gui.results.reconstruction_input_img = imagesc(cx, cy, mimg, 'Parent',gui.results.reconstruction_input) ;
    xlabel (gui.results.reconstruction_input, label) ;
    ylabel (gui.results.reconstruction_input, label) ;
    title (gui.results.reconstruction_input, 'Input Image Intensity') ;
    axis (gui.results.reconstruction_input, 'xy') ;
    axis (gui.results.reconstruction_input, 'image') ;
    axis (gui.results.reconstruction_input, 'tight') ;
    if get(gui.results.reconstruction_constColorbar,'Value') && get(gui.results.reconstruction_mode,'Value') == 1
        mcolorbar(gui.results.reconstruction_input, gui.colormaps.(getCurrentPopupString(gui.results.recon_field_colormap)), ...
            'clim', [min(guiimages(:)), max(guiimages(:))]) ;
    else
        mcolorbar(gui.results.reconstruction_input, gui.colormaps.(getCurrentPopupString(gui.results.recon_field_colormap))) ;
    end
    gui.results.reconstruction_input_text = text('Parent',gui.results.reconstruction_input, 'Position', [0,0], 'String', '','VerticalAlignment','bottom','Margin',2,'Color','k','BackgroundColor','w') ;
    
    %% Plot Reconstructed Image
    gui.results.reconstruction_recon_img = imagesc(cx, cy, mimg_recon, 'Parent',gui.results.reconstruction_recon) ;
    xlabel (gui.results.reconstruction_recon, label) ;
    ylabel (gui.results.reconstruction_recon, label) ;
    title (gui.results.reconstruction_recon, 'Reconstructed Image Intensity') ;
    axis (gui.results.reconstruction_recon, 'xy') ;
    axis (gui.results.reconstruction_recon, 'image') ;
    axis (gui.results.reconstruction_recon, 'tight') ;
    if get(gui.results.reconstruction_constColorbar,'Value') && get(gui.results.reconstruction_mode,'Value') == 1
        mcolorbar(gui.results.reconstruction_recon, gui.colormaps.(getCurrentPopupString(gui.results.recon_field_colormap)), ...
            'clim', [min(guirecon(:)), max(guirecon(:))]) ;
    else
        mcolorbar(gui.results.reconstruction_recon, gui.colormaps.(getCurrentPopupString(gui.results.recon_field_colormap))) ;
    end
    gui.results.reconstruction_recon_text = text('Parent',gui.results.reconstruction_recon, 'Position', [0,0], 'String', '','VerticalAlignment','bottom','Margin',2,'Color','k','BackgroundColor','w') ;
    
    %% Plot Error
    gui.results.reconstruction_error_img = imagesc(cx, cy, mimg_error, 'Parent',gui.results.reconstruction_error) ;
    xlabel (gui.results.reconstruction_error, label) ;
    ylabel (gui.results.reconstruction_error, label) ;
    title (gui.results.reconstruction_error, 'Error in Reconstructed Image Intensity') ;
    axis (gui.results.reconstruction_error, 'xy') ;
    axis (gui.results.reconstruction_error, 'image') ;
    axis (gui.results.reconstruction_error, 'tight') ;
    if get(gui.results.reconstruction_constColorbar,'Value') && get(gui.results.reconstruction_mode,'Value') == 1
        mcolorbar(gui.results.reconstruction_error, gui.colormaps.(getCurrentPopupString(gui.results.recon_field_colormap)), ...
            'clim', [min(guiimages(:) - guirecon(:)), max(guiimages(:) - guirecon(:))]) ;
    else
        mcolorbar(gui.results.reconstruction_error, gui.colormaps.(getCurrentPopupString(gui.results.recon_field_colormap))) ;
    end
    gui.results.reconstruction_error_text = text('Parent',gui.results.reconstruction_error, 'Position', [0,0], 'String', '','VerticalAlignment','bottom','Margin',2,'Color','k','BackgroundColor','w') ;
    
    %% Show NA
    if get(gui.results.reconstruction_showNA,'Value') && isfield(param,'NA') && isfield(param,'wavelength')
        rectangle ('Position', [-1,-1,2,2]*param.NA/param.wavelength/scale_factor, 'Curvature', [1,1], 'EdgeColor', [1,1,1], 'LineWidth', 2, 'Parent', gui.results.reconstruction_error) ;
        rectangle ('Position', [-1,-1,2,2]*param.NA/param.wavelength/scale_factor, 'Curvature', [1,1], 'EdgeColor', [1,1,1], 'LineWidth', 2, 'Parent', gui.results.reconstruction_recon) ;
        rectangle ('Position', [-1,-1,2,2]*param.NA/param.wavelength/scale_factor, 'Curvature', [1,1], 'EdgeColor', [1,1,1], 'LineWidth', 2, 'Parent', gui.results.reconstruction_input) ;
    end

    
    switch get(gui.results.reconstruction_mode,'Value')
        case 2 %fourier space
            %Zoom fourier space
            if isfield(param, 'NA') && isfield(param,'wavelength')
                lim = [-1,1]*param.NA/param.wavelength*fourier_crop_factor ;
                xl = [max(fx(1), lim(1)), min(fx(end),lim(2))]/scale_factor ;
                yl = [max(fy(1), lim(1)), min(fy(end),lim(2))]/scale_factor ;
                xlim (gui.results.reconstruction_input,xl) ; ylim (gui.results.reconstruction_input,yl) ;
                xlim (gui.results.reconstruction_recon,xl) ; ylim (gui.results.reconstruction_recon,yl) ;
                xlim (gui.results.reconstruction_error,xl) ; ylim (gui.results.reconstruction_error,yl) ;
            end
            set(gui.results.reconstruction_input,'UserData', struct('click',gui.data.results.callback_fourier)) ;
            set(gui.results.reconstruction_recon,'UserData', struct('click',gui.data.results.callback_fourier)) ;
            set(gui.results.reconstruction_error,'UserData', struct('click',gui.data.results.callback_fourier)) ;
        case 1
            set(gui.results.reconstruction_input,'UserData', struct('click',gui.data.results.callback_real)) ;
            set(gui.results.reconstruction_recon,'UserData', struct('click',gui.data.results.callback_real)) ;
            set(gui.results.reconstruction_error,'UserData', struct('click',gui.data.results.callback_real)) ;
    end
    
    if isfield(gui.data.results,'reconstruction') && size(guirecon,3) == size(guiimages,3)
        if size(guiimages,3) == 0 || gui.results.reconstruction_image_index == size(guiimages,3), set(gui.results.reconstruction_next,'Enable','off') ;
        else set(gui.results.reconstruction_next,'Enable','on') ; end
        if size(guiimages,3) == 0 || gui.results.reconstruction_image_index == 1, set(gui.results.reconstruction_previous,'Enable','off') ; 
        else set(gui.results.reconstruction_previous,'Enable','on') ; end
        if size(guiimages,3) == 0, set(gui.results.reconstruction_image_count,'String','0 / 0') ;    
        else set(gui.results.reconstruction_image_count,'String',sprintf('%.0f / %.0f', gui.results.reconstruction_image_index, size(guiimages,3))) ; end
    else
        set(gui.results.reconstruction_next,'Enable','off') ;
        set(gui.results.reconstruction_previous,'Enable','off') ;
        set(gui.results.reconstruction_image_count,'String','- - -') ;
    end
    
    %% Update Edge Crop dropdown to include distances
    if isfield(param,'pixel_size')
        edgecrop_distancespx = round(gui.results.reconstruction_edgecropamounts * size(gui.data.images,1)) ;
        edgecrop_distances = edgecrop_distancespx * param.pixel_size ;
        [scale_factor, label] = valueToScale (edgecrop_distances) ;
        %set(gui.results.reconstruction_edgecropfactor, 'String', strcat({''}, num2str(gui.results.reconstruction_edgecropamounts'*100,'%.0f%% '),  num2str(edgecrop_distances'*scale_factor,[' (%.0f' label ')']))) ;
        set(gui.results.reconstruction_edgecropfactor, 'String', ...
            arrayfun(@(x)sprintf('%.0f%% (%.0fpx = %.0f%s)', gui.results.reconstruction_edgecropamounts(x)*100, edgecrop_distancespx(x), edgecrop_distances(x)*scale_factor, label), 1:length(edgecrop_distances),'UniformOutput',false)) ;
    end

    set(gui.figure,'WindowButtonMotionFcn', @figMouseHover) ;
    getGUI(gui) ;
    drawnow ;
    zoom(gui.figure,'reset') ;
end
function reconstructionMouseHover (~,~,~)
    gui = getGUI() ;
    if ~ishandle(gui.results.reconstruction_input_text), return; end
    h = hittest ;
    h = ancestor(h,'axes') ;
    set (gui.results.reconstruction_input_text, 'Visible','off') ;
    set (gui.results.reconstruction_recon_text, 'Visible','off') ;
    set (gui.results.reconstruction_error_text, 'Visible','off') ;
    if isempty(h), return ; end
    if ~(h == ancestor(gui.results.reconstruction_input_img, 'axes') || ...
         h == ancestor(gui.results.reconstruction_recon_img, 'axes') || ...
         h == ancestor(gui.results.reconstruction_error_img, 'axes'))
        return ;
    end
    %img = findall(h, 'Type', 'image') ;
    xvals = flipud(get(gui.results.reconstruction_input_img,'XData')) ;
    yvals = flipud(get(gui.results.reconstruction_input_img,'YData')) ;
    pos = get(h, 'CurrentPoint') ;
    [~, yc] = min(abs(xvals - pos(1))) ;
    [~, xc] = min(abs(yvals - pos(3))) ;
    xv = xvals(yc) ; yv = yvals(xc) ;
    
    xd = diff(xvals(1:2)) * 0.5 * 1.5 ;
    yd = diff(yvals(1:2)) * 0.5 * 1.5 ;
    
    xl = xlim(h) ;
    if xvals(yc) > (xl(1) + (xl(2)-xl(1))*2/3)
        hdir = 'right' ; xd = -xd ;
    elseif xvals(yc) > (xl(1) + (xl(2)-xl(1))*1/3)
        hdir = 'center' ; xd = 0 ;
    else
        hdir = 'left' ;
    end
    
    if yvals(xc) > mean(ylim(h))
        vdir = 'top' ; yd = -yd ;
    else
        vdir = 'bottom' ;
    end
    
    set (gui.results.reconstruction_input_text, 'String', ...
              {sprintf('(%.3f%s, %.3f%s)', xv, gui.results.current_values.unit_str, yv, gui.results.current_values.unit_str), ...
               sprintf('Amplitude: %f', abs(gui.results.current_values.img(xc,yc))), ...
               sprintf('Phase: %f', 180/pi*angle(gui.results.current_values.img(xc,yc)))}, ...
         'Position', [xv+xd, yv+yd],'Visible','on','HorizontalAlignment',hdir,'VerticalAlignment',vdir) ;
    set (gui.results.reconstruction_recon_text, 'String', ...
              {sprintf('Amplitude: %f', abs(gui.results.current_values.recon(xc,yc))), ...
               sprintf('Phase: %f', 180/pi*angle(gui.results.current_values.recon(xc,yc)))}, ...
         'Position', [xv+xd, yv+yd],'Visible','on','HorizontalAlignment',hdir,'VerticalAlignment',vdir) ;
    set (gui.results.reconstruction_error_text, 'String', ...
              {sprintf('Amplitude: %f', abs(gui.results.current_values.error(xc,yc))), ...
               sprintf('Phase: %f', 180/pi*angle(gui.results.current_values.error(xc,yc)))}, ...
         'Position', [xv+xd, yv+yd],'Visible','on','HorizontalAlignment',hdir,'VerticalAlignment',vdir) ;
end
function reconstructionErrorMouseHover (~,~,~)
    h = hittest ;
    gui = getGUI() ;
    if ~isfield(gui.results,'reconstruction_errorplotcurve'), return ; end
    if h ~= gui.results.reconstruction_errorplot
        set(gui.results.reconstruction_errormetricselect_marker,'Visible','off') ;
        set(gui.results.reconstruction_errormetric_text,'Visible','off') ;
        return ;
    end
    pos = get(gui.results.reconstruction_errorplot,'CurrentPoint');
    
    yd = get(gui.results.reconstruction_errorplotcurve,'YData') ;
    I = getClosestPoint (gui.results.reconstruction_errorplot, pos(1,1), pos(1,2), ...
                         get(gui.results.reconstruction_errorplotcurve,'XData'), yd) ;
    set(gui.results.reconstruction_errormetricselect_marker,'XData', I, 'YData', yd(I), 'Visible', 'on') ;
    
    axes(gui.results.reconstruction_errorplot); %#ok<MAXES>
    xl = xlim ; yl = ylim ;
    set(gui.results.reconstruction_errormetric_text,'Position',[xl(2),yl(2)], 'Visible','on', ...
        'String', sprintf('#%.0f: %f', I, yd(I))) ;
end
function reconstructionErrorMouseClick (~,~,~)
    h = hittest ;
    if ~isa(handle(h),'axes'), return ; end
    gui = getGUI() ;
    if h ~= gui.results.reconstruction_errorplot, return ; end
    pos = get(gui.results.reconstruction_errorplot,'CurrentPoint');
    
    I = getClosestPoint (gui.results.reconstruction_errorplot, pos(1,1), pos(1,2), ...
                         get(gui.results.reconstruction_errorplotcurve,'XData'), get(gui.results.reconstruction_errorplotcurve,'YData')) ;
    
    gui.results.reconstruction_image_index = I ;
    getGUI (gui) ;
    updateReconstructionGUI()
end

%% Progress
function gui = progressGUI (ui_tabPanel, gui)
    ui_runProgress = uiextras.HBoxFlex ('Parent', ui_tabPanel, 'Spacing', 10) ;
    ui_runReport = uiextras.VBoxFlex ('Parent', ui_runProgress, 'Spacing', 5) ;
    
    gui.progress.status = uicontrol('Style', 'edit', 'Max',1e6, 'String','<HTML>', 'Parent', ui_runReport) ;
    gui.progress.jstatus = findjobj(gui.progress.status) ;
    gui.progress.jstatus = gui.progress.jstatus.getComponent(0).getComponent(0) ;
    gui.progress.jstatus.setContentType('text/html') ;
    %gui.progress.progress = uicontrol('Style', 'pushbutton', 'String', '<HTML><div width="100" background="red">abc</div>', 'Enable','off', 'Parent', ui_runReport) ;
    
    ui_progressBar = uiextras.HBox ('Parent', ui_runReport) ;
    [gui.progress.progress_bar, hProgress] = javacomponent('javax.swing.JProgressBar', [], uicontainer('Parent',ui_progressBar,'Position',[0,0,200,30])) ;
    set(hProgress,'units','norm','position',[0,0,1,1]) ;
    gui.progress.progress_bar.setMinimum(0) ; gui.progress.progress_bar.setMaximum(100) ;
    gui.progress.eta = uicontrol('Style','text','Parent',ui_progressBar) ;
    ui_progressBar.Sizes = [-1, 50] ;
    
    ui_runReportbtns = uiextras.Grid('Parent',ui_runReport,'Spacing', 5) ;
    gui.progress.cancel = uicontrol('String','Cancel', 'Parent', ui_runReportbtns, 'Callback', @progressCancel) ;
    gui.progress.save = uicontrol('String','Save', 'Parent', ui_runReportbtns, 'Callback', @progressSave) ;
    gui.progress.pause = uicontrol('String','Pause', 'Parent', ui_runReportbtns, 'Callback', @progressPause) ;
    gui.progress.save = uicontrol('String','Load', 'Parent', ui_runReportbtns, 'Callback', @progressLoad) ;
    set(ui_runReportbtns, 'ColumnSizes', [-1,-1], 'RowSizes', [-1, -1]) ;
    
    gui.progress.cancel = uicontrol('String','Reset', 'Parent', ui_runReport, 'Callback', @progressReset) ;
    
    ui_runReport.Sizes = [-1, 20, 80,25] ;
    
    
    gui.progress.plot_panel = {uiextras.VBoxFlex('Parent', ui_runProgress)} ;
    gui.progress.plots = cell(1,0) ;
    
    gui.progress.callback = [] ;
end
function progressCancel(~,~,~)
    gui = getGUI () ;
    gui.progress.is_canceled = true ;
    getGUI (gui) ;
end
function progressPause(~,~,~)
    gui = getGUI() ;
    if gui.progress.is_paused
        progressCallback_status('Script unpaused.') ;
        gui.progress.is_paused = false ;
    else
        progressCallback_status('Script paused.') ;
        gui.progress.is_paused = true ;
    end
    getGUI(gui) ;
    updateEnabled() ;
end
function progressSave(~,~,~)
    persistent path ;
    if isempty(path), path = pwd ; end
    gui = getGUI() ;
    [filename, path] = uiputfile('*.mat', 'Save Results',path) ;
    gui.is_saving = true ;
    getGUI(gui) ;
    updateEnabled() ;
    drawnow ;
    results = struct() ;
    results.field = gui.data.results.field ;
    results.images = gui.data.images ;
    results.params = gui.data.params ; %#ok<STRNU>
    save ([path filename],'-struct','results') ;
    gui.is_saving = false ;
    getGUI(gui) ;
    updateEnabled() ;
end
function progressLoad(~,~,~)
    persistent path ;
    if isempty(path), path = pwd ; end
    [filename, path] = uigetfile('*.mat', 'Load Results',path) ;
    
    gui = getGUI() ;
    gui.sweep.is_loading = true ; getGUI(gui) ; updateEnabled() ; drawnow ;
    resultsFile = load ([path filename]) ;
    try
        gui.data.results = resultsFile.results ;
        gui.data.images = resultsFile.images ;
        gui.data.params = resultsFile.params ;
    catch e
        errordlg('Invalid Results file') ;
    end
    gui.sweep.is_loading = false ;
    getGUI(gui) ;
    updateResultsGUI() ;
    updateReconstructionGUI() ;
    updateEnabled() ;
end
function progressReset(~,~,~)
    button = questdlg('Are you sure you want to reset the disabled buttons. Do this only if something went wrong.') ;
    if ~strcmp(button, 'Yes'), return ; end
    gui = getGUI() ;
    gui.run.is_running = false ;
    gui.load.is_loading = false ;
    gui.sweep.is_sweeping = false ;
    gui.sweep.is_saving = false ;
    gui.sweep.is_loading = false ;
    getGUI(gui) ;
    cd(fileparts(mfilename('fullpath'))) ;
    updateEnabled() ;
end

%% Zoom
function zoomCallback (~, ~)
    h = ancestor(hittest,'axes') ;
    if isempty(h), return ; end
    gui = getGUI() ;
    switch h
        case gui.results.left_real
            xl = xlim(gui.results.left_real) ;
            yl = ylim(gui.results.left_real) ;
            xlim(gui.results.right_real,xl) ;
            ylim(gui.results.right_real,yl) ;
        case gui.results.right_real
            xl = xlim(gui.results.right_real) ;
            yl = ylim(gui.results.right_real) ;
            xlim(gui.results.left_real,xl) ;
            ylim(gui.results.left_real,yl) ;
        case gui.results.left_fourier
            xl = xlim(gui.results.left_fourier) ;
            yl = ylim(gui.results.left_fourier) ;
            xlim(gui.results.right_fourier,xl) ;
            ylim(gui.results.right_fourier,yl) ;
        case gui.results.right_fourier
            xl = xlim(gui.results.right_fourier) ;
            yl = ylim(gui.results.right_fourier) ;
            xlim(gui.results.left_fourier,xl) ;
            ylim(gui.results.left_fourier,yl) ;
        case gui.results.reconstruction_input
            xl = xlim(gui.results.reconstruction_input) ;
            yl = ylim(gui.results.reconstruction_input) ;
            xlim(gui.results.reconstruction_recon,xl) ;
            ylim(gui.results.reconstruction_recon,yl) ;
            xlim(gui.results.reconstruction_error,xl) ;
            ylim(gui.results.reconstruction_error,yl) ;
        case gui.results.reconstruction_recon
            xl = xlim(gui.results.reconstruction_recon) ;
            yl = ylim(gui.results.reconstruction_recon) ;
            xlim(gui.results.reconstruction_input,xl) ;
            ylim(gui.results.reconstruction_input,yl) ;
            xlim(gui.results.reconstruction_error,xl) ;
            ylim(gui.results.reconstruction_error,yl) ;
        case gui.results.reconstruction_error
            xl = xlim(gui.results.reconstruction_error) ;
            yl = ylim(gui.results.reconstruction_error) ;
            xlim(gui.results.reconstruction_recon,xl) ;
            ylim(gui.results.reconstruction_recon,yl) ;
            xlim(gui.results.reconstruction_input,xl) ;
            ylim(gui.results.reconstruction_input,yl) ;
    end
end
function flag = zoomClick (~,~)
    ctrl_pressed = ismember('control', get(gcbf,'currentModifier')) ;
    if ctrl_pressed
        flag = true ;
        ax = ancestor(hittest,'axes') ;
        if isempty(ax), return ; end
        pos = get(ax,'CurrentPoint');
        h = get(ax,'children') ;
        h = h(arrayfun(@(x)isa(handle(x),'image'),h));
        if isempty(h), return ; end
        xvals = get(h,'XData') ; yvals = get(h,'YData') ;
        [~,x] = min(abs(xvals - pos(1,1))) ;
        [~,y] = min(abs(yvals - pos(1,2))) ;
        ud = get(ax,'UserData') ;
        if isstruct(ud) && isfield(ud,'click')
            ud.click(x,y) ;
        end
    else
        flag = false ;    
    end
end

%% Progress Callbacks
function progressCallback_status (message)
    gui = getGUI() ;
    message = ['<b>[' datestr(now,'HH:MM:SS.FFF') ']</b> ' message] ;
    status_vals = get(gui.progress.status,'String') ;
    status_vals = [status_vals(:)' message(:)' '<br>'] ;
    set(gui.progress.status,'String',status_vals) ;
    %ui.progress.jstatus.setCaretPosition(gui.progress.jstatus.getDocument.getLength);
    drawnow ;
    while 1
        drawnow ;
        gui = getGUI() ;
        if ~gui.progress.is_paused, break ; end
    end
end
function iscanceled = progressCallback_canceled ()
    gui = getGUI() ;
    iscanceled = gui.progress.is_canceled ;
    if iscanceled, progressCallback_status ('<font color="red">Script canceled by user.</font>') ; end
    drawnow ;
    while gui.progress.is_paused
        drawnow ;
        gui = getGUI() ;
    end
end
function progressCallback_progress (progress)
    gui = getGUI () ;
    gui.progress.progress_bar.setValue (progress*100) ;
    set(gui.progress.eta,'String',getETA(gui.progress.start_time,progress)) ;
    if ~isempty(gui.progress.callback)
        gui.progress.callback(gui, progress) ;
    end
    drawnow ;
    while gui.progress.is_paused
        drawnow ;
        gui = getGUI() ;
    end
end
function valid = progressCallback_plot(n)
    gui = getGUI() ;
    if nargin == 0
        while ~isempty(gui.progress.plots)
            delete(handle(gui.progress.plots{1}.container)) ;
            gui.progress.plots(1) = [] ;
        end
        getGUI(gui) ;
    else
        if length(gui.progress.plots) < n
            for i=(length(gui.progress.plots)+1):n
                c = uicontainer('Parent',gui.progress.plot_panel{1}) ;
                p = axes ('Parent', c, 'Units','Normalized', 'OuterPosition', [0,0,1,1]) ;
                gui.progress.plots{i} = struct('container', c, ...
                                               'plot', p) ;
            end
        end
        getGUI(gui) ;
        axes(gui.progress.plots{n}.plot) ;
    end
    valid = 1 ;
end
function progressCallback_result(type,varargin)
    gui = getGUI() ;
    switch type
        case 'clear'
            gui.data.results = struct() ;
            gui.data.results.field = [] ;
            gui.data.results.fields = cell(0,2) ;
            gui.data.results.fields_fourier = cell(0,2) ;
            gui.data.results.callback_fourier = @(~,~)1 ;
            gui.data.results.callback_real = @(~,~)1 ;
            gui.data.results.error_metric = [] ;
        case 'E'
            gui.data.field = varargin{1} ;
        case 'field' %real space result
            gui.data.results.fields = [gui.data.results.fields; {varargin{1}, varargin{2}}] ;
        case 'fourier' %fourier space result - it doesn't make sense to show any real space data
            gui.data.results.fields_fourier = [gui.data.results.fields_fourier; {varargin{1}, varargin{2}}] ;
        case 'reconstruction' %the reconstructed image stack
            gui.data.results.reconstruction = real(varargin{1}) ;
        case 'inspect_fourier' %function to call for clicking on fourier plot
            gui.data.results.callback_fourier = varargin{1} ;
        case 'inspect_real' %function to call for clicking on real space plot
            gui.data.results.callback_fourier = varargin{1} ;
        case 'error'
            gui.data.results.error_metric = varargin{1} ;
    end
    getGUI(gui) ;
end
function [error, options] = progressCallback_error(input_img, recon_img, options)
    %this computes the error metric based on the settings on the
    %reconstruction gui. It can be called with 1 or 0 arguments to only
    %return the options the error would use (since it pulls some options
    %from the gui).
    gui = getGUI();
    if nargin == 1, options = input_img ; end
    if ~exist('options', 'var'), options = struct() ; end
    if ~isfield(options,'crop'), options.crop = gui.results.reconstruction_edgecropamounts(get(gui.results.reconstruction_edgecropfactor,'Value')) ; end
    if ~isfield(options,'metric'), options.metric = gui.results.reconstruction_errormetricoptions{get(gui.results.reconstruction_errormetric,'Value')}.code ; end
    if ~isfield(options,'filter'), options.filter = gui.results.reconstruction_fourierzoomamounts(get(gui.results.reconstruction_fourierzoomfactor,'Value')) ; end
    
    if ~isinf(options.filter)
        try
            if ~isfield(options,'pixel_size'), options.pixel_size = gui.data.params{1}.pixel_size ; end
            if ~isfield(options,'wavelength'), options.wavelength = gui.data.params{1}.wavelength ; end
            if ~isfield(options,'NA'), options.NA = gui.data.params{1}.NA ; end
        catch %#ok<CTCH>
            error = nan ;
            return ;
        end
    end
    if nargin < 2
        error = options ;
        return ;
    end
    
    if length(options.crop) == 1, options.crop = [options.crop, options.crop] ; end
    if sum(options.crop > 1)
        edge_crop = round(options.crop) ;
    else
        edge_crop = round([size(input_img,1), size(input_img,2)] .* options.crop) ;
    end
    input_img = input_img(edge_crop(1) + (1:(size(input_img,1)-2*edge_crop(1))), ...
                          edge_crop(2) + (1:(size(input_img,2)-2*edge_crop(2))),:) ;
    recon_img = recon_img(edge_crop(1) + (1:(size(recon_img,1)-2*edge_crop(1))), ...
                          edge_crop(2) + (1:(size(recon_img,2)-2*edge_crop(2))),:) ;
    
    if ~isinf(options.filter)
        if options.filter * options.NA / options.wavelength < 1 / options.pixel_size
            fx = (floor(-size(input_img,1)/2):ceil(size(input_img,1)/2-1))/(size(input_img,1)*options.pixel_size) ;
            fy = (floor(-size(input_img,2)/2):ceil(size(input_img,2)/2-1))/(size(input_img,2)*options.pixel_size) ;
            [fxx, fyy] = meshgrid(fx, fy) ;
            filt = (fxx.^2 + fyy.^2) <= (options.filter * options.NA / options.wavelength)^2 ;
            for i=1:size(input_img,3)
                input_img(:,:,i) = ifft2(ifftshift(fftshift(fft2(input_img(:,:,i))) .* filt)) ;
                recon_img(:,:,i) = ifft2(ifftshift(fftshift(fft2(recon_img(:,:,i))) .* filt)) ;
            end
        end
    end
    
    metric = find(arrayfun(@(x)strcmpi(gui.results.reconstruction_errormetricoptions{x}.name,options.metric) || strcmpi(gui.results.reconstruction_errormetricoptions{x}.code,options.metric),1:length(gui.results.reconstruction_errormetricoptions))) ;
    if isempty(metric), metric = 1 ; end
    metric = metric(1) ;
    error_fn = gui.results.reconstruction_errormetricoptions{metric} ;
    %error_metric = arrayfun(@(x)error_fn.fn(input_img(:,:,x),recon_img(:,:,x)), 1:size(input_img,3)) ;
    %error = norm(error_metric,2) ;
    error = error_fn.fn(input_img,recon_img) ;
end


function parameters = paramToTable (param)
    parameters = cell(0,2) ;
    for n=fieldnames(param)'
        value = param.(n{1}) ;
        if isnumeric(value)
            if length(value(:)) == 1
                parameters = [parameters; [n, {num2str(value)}]] ;
            else
                parameters = [parameters; [n, {[num2str(size(value,1)) 'x' num2str(size(value,2)) ' ' class(value)]}]] ;
            end
        else
            parameters = [parameters; [n, {char(value)}]] ;
        end
    end
end
function [scale_factor, label] = valueToScale (values, latex_on)
    if ~exist('latex_on','var'), latex_on = 1 ; end
    values = [0;values(:)] ;
    values = values(~isinf(values) & ~isnan(values)) ;
    scale = floor(log10(max(values))/3) ;
    switch scale
        case -1
            scale_factor = 1e3 ; label = 'mm' ;
        case -2
            if latex_on, scale_factor = 1e6 ; label = '\mum' ;
            else scale_factor = 1e6 ; label = 'um' ; end
        case -3
            scale_factor = 1e9 ; label = 'nm' ;
        case -4
            scale_factor = 1e12 ; label = 'pm' ;
        otherwise
            scale_factor = 1 ; label = 'm' ;
    end
end

function val = valueToChar (value)
    if isnumeric(value)
        val = num2str(value) ;
    else
        val = char(value) ;
    end
end


function eta = getETA( start_time, percentage )
minTime = 3; % secs
elapsedtime = round(toc( start_time )); % in seconds

% Only show the remaining time if we've had time to estimate
if elapsedtime < minTime
    % Not enough time has passed since starting, so leave blank
    eta = '';
    return ;
else
    % Calculate a rough ETA
    remainingtime = elapsedtime * (1-percentage) / percentage ;
end

if isinf(remainingtime)
    eta = '' ;
elseif remainingtime > 172800 % 2 days
    eta = sprintf( '%d days', round(remainingtime/86400) );
else
    if remainingtime > 7200 % 2 hours
        eta = sprintf( '%d hours', round(remainingtime/3600) );
    else
        if remainingtime > 120 % 2 mins
            eta = sprintf( '%d mins', round(remainingtime/60) );
        else
            % Seconds
            remainingtime = round( remainingtime );
            if remainingtime > 1
                eta = sprintf( '%d secs', remainingtime );
            elseif remainingtime == 1
                eta = '1 sec';
            else
                eta = ''; % Nearly done (<1sec)
            end
        end
    end
end
end % iGetTimeString

function evth = enterEventHandler (callback, eventdata)
    persistent in_robot ;
    if exist('eventdata','var')
        if strcmp(eventdata.Key,'return')
            if isempty(in_robot)
               callback();
            end
            return ;
        end
        in_robot = 1 ; %#ok<NASGU>
        import java.awt.Robot ;
        import java.awt.event.KeyEvent ;
        robot = Robot ;
        robot.keyPress(KeyEvent.VK_ENTER) ;
        robot.waitForIdle();
        robot.keyRelease(KeyEvent.VK_ENTER) ;
        drawnow ;
        in_robot = [] ;
        %% See if it's a valid file
        updateEnabled() ;
    else
        evth = @(~,evt,~)enterEventHandler(callback,evt) ;
    end
end

function I = getClosestPoint (ax, xpos, ypos, xdata, ydata)
    xl = xlim(ax) ; yl = ylim(ax) ;
    if strcmpi(get(ax,'XScale'),'Log')
        xdata = log10(xdata) ;
        xpos = log10(xpos) ;
        xl = log(xl) ;
    end
    if strcmpi(get(ax,'YScale'),'Log')
        ydata = log10(ydata) ;
        ypos = log10(ypos) ;
        yl = log(yl) ;
    end
    xdata = xdata - xl(1) ; xpos = xpos - xl(1) ;
    ydata = ydata - yl(1) ; ypos = ypos - yl(1) ;
    xdata = xdata / diff(xl) ; xpos = xpos / diff(xl) ;
    ydata = ydata / diff(yl) ; ypos = ypos / diff(yl) ;
    
    [val,I] = min((xdata - xpos).^2 + (ydata - ypos).^2) ;
    if isnan(val) || isinf(val)
        I = 0 ;
    end
end