function [ settings, params, images ] = loadMeasurementXML( filename, parameters )
%LOADMEASUREMENTXML Loads a measurement XML file
%   Detailed explanation goes here

attribute_paramVariable() ; %clear variables
getId('clear') ; %reset ids

if exist('parameters','var') && isstruct(parameters)
    for i=fieldnames (parameters)'
        attribute_paramVariable ('set', 'global', i{1}, parameters.(i{1})) ;
    end
end

settings = struct() ;
scope = {'global'} ;

if filename(1) == '='
    import java.io.StringBufferInputStream ;
    filename = StringBufferInputStream(filename(2:end)) ;
    root = xmlread(filename) ;
    settings.path = '' ;
else
    root = xmlread (filename) ;
    settings.path = fileparts(filename) ;
end
root = root.getDocumentElement ;
[images, params, settings] = measurementset(root, settings, scope) ;
%% Evaluate the variables
for i=fieldnames(settings)'
    value = settings.(i{1}) ;
    if strcmp(class(value),'function_handle'),value = value(settings,scope) ; end
    if isstruct(value)
        value = value.fn ;
    end
    settings.(i{1}) = value ;
end
if isfield(settings,'id'), settings = rmfield(settings,'id') ; end

%% Generate Pupil
for i=1:length(params)
    params{i} = evaluateFields (params{i}, scope) ;
    for fn=fieldnames(params{i})'
        if isstruct(params{i}.(fn{1}))
            params{i}.(fn{1}) = params{i}.(fn{1}).fn ;
        end
    end
    if isfield(params{i},'id'), params{i} = rmfield(params{i},'id') ; end
end

end

%% External Features
function [images, params] = loadImage (node, settings_in, scope)
    %image tags can have the file parameter as the content of the tag
    if ~isempty(node.getFirstChild), settings_in.data = getAttribute(char(node.getFirstChild.getData), settings_in, scope) ; end
    [settings, scope, new_fields] = attributesToStruct (node, settings_in, scope) ;
    settings = evaluateFields (settings, scope, {'path', 'data', 'pixel_size'}, ...
                                                {'','',     ''}) ;
    
    if isstruct(settings.data)
        settings = evaluateFields (settings, scope, {'size', 'pixel_size'}, ...
                                                    {'',     ''}) ;
        [xx,yy] = meshgrid(linspace(-1,1,settings.size), linspace(-1,1,settings.size)) ;
        images = settings.data.fn(xx,yy) ;
    elseif ~ischar(settings.data)
        images = settings.data ;
    else
        if regexp(settings.data, '^/|^[A-Za-z]:') %full path
            image_path = settings.data ;
        else
            image_path = [settings.path '/' settings.data] ;
        end
        [~,~,ext] = fileparts(image_path) ;
        if ~isempty(regexpi(ext,'jpg|png|bmp|tif|tiff'))
            settings = evaluateFields (settings, scope, {'scale','color'}, ...
                                                        {'',     'gray'}) ;
            [images, ~, alpha] = imread(image_path) ;
            images = im2double(images) ; alpha = im2double(alpha) ;
            if ~isempty(settings.scale)
                images = image * settings.scale ;
            end
            if size(images,3) > 1
                %color image?
                if strcmp(settings.color,'gray')
                    images = mean(images,3) ;
                elseif strcmp(settings.color,'alpha')
                    images = alpha ;
                else
                    color_index = find(strcmp(settings.color, {'red','green','blue'})) ;
                    if ~isempty(color_index) && color_index <= size(images,3)
                        images = images(:,:,color_index) ;
                    else
                        error('Invalid color channel option for loading image. You can use gray, red, green, blue, and alpha') ;
                    end
                end
            end
        else
            switch ext
                case '.mat'
                    file = load(image_path,'-mat') ;
                    fn = fieldnames (file) ;
                    for i=1:length(fn)
                        if size(file.(fn{i}),1) > 1 && size(file.(fn{i}),2) > 1
                            field = fn{i} ;
                            break ;
                        end
                    end
                    images = file.(field) ;
                case '.dat'
                    file = load(image_path) ;
                    images = reshape(file(:,3:end), max(file(:,1)), max(file(:,2)), size(file,2)-2) ;
                otherwise
                    images = [] ;
            end
        end
    end
    
    %% Set parameters to images
    if isfield(settings_in,'data'), settings_in = rmfield(settings_in,'data') ; end
    params = repmat(settings_in, 1, size(images,3)) ;
    settings = evaluateFields (settings, scope, new_fields) ;
    for fn=new_fields
        var = settings.(fn{1}) ;
        if ~ischar(var) && length(var) == size(images,3)
            for j=1:length(params)
                if iscell(var), params(j).(fn{1}) = var{j} ;
                else params(j).(fn{1}) = var(j) ; end
            end
        else
            for j=1:length(params)
                params(j).(fn{1}) = var ;
            end
        end
    end
    params = num2cell(params) ;
end
function [images, params] = object (node, settings, scope)
    %object tags don't pass on any fields
    [settings, scope, new_fields] = attributesToStruct (node, settings, scope) ;
    if ~isfield(settings,'type')
        if sum(strcmp(new_fields,'real') | strcmp(new_fields,'imag')) > 0
            settings.type = 'real';
        elseif sum(strcmp(new_fields,'phase') | strcmp(new_fields,'amplitude')) > 0
            settings.type = 'phase' ;
        elseif sum(strcmp(new_fields,'field')) > 0
            settings.type = 'field' ;
        end
    end
    if ~isfield(settings,'seed')
        rng('shuffle') ;
        settings.seed =  randi([1,10000],1) ;
    end
    %objects could be allowed to use local settings when used as a
    %parameter, but this is probably not very useful and slows down the
    %loading so it's disabled here:
    %if isfield(settings,'name')
    %    attribute_paramVariable ('set', scope{2}, settings.name, ...
    %            @(in_settings,in_scope)objectfield(mergeStruct(in_settings,settings),[in_scope,scope])) ;
    %end
    object = objectfield(settings,scope) ;
    if isfield(settings,'name')
        attribute_paramVariable ('set', scope{2}, settings.name, ...
                @(in_settings,in_scope)object) ;
    end
    new_fields = [new_fields, {'type','seed'}] ; %add fields added in this function
    settings = removeFields (settings, new_fields) ;
    settings.object = object ;
    [images, params] = loadSubnodes (node, settings, scope) ;
end

function [images, params] = propagate (node, settings, scope)
    param = attributesToStruct (node, settings, scope) ;
    param = evaluateFields (param, scope, {'defocus', 'object'}, ...
                                          {0,        '',      }) ;
    if ~isempty(param.object)
        object = param.object ;
    else
        object = objectfield(param, scope) ;
    end
    images = zeros(size(object,1),size(object,2),length(param.defocus)) ;
    params = cell(1, length(param.defocus)) ;
    for i=1:length(param.defocus)
        if ~isempty(node.getAttributes().getNamedItem ('defocus'))
            node.getAttributes().getNamedItem ('defocus').setValue(num2str(param.defocus(i))) ;
            params{i} = attributesToStruct(node, settings, scope) ;
            params{i} = evaluateFields (params{i}, scope, {'defocus', 'object', 'wavelength', 'pixel_size'}, ...
                                                          {[],        [],       [],           []}) ;
        else
            params{i} = attributesToStruct(node, settings, scope) ;
            params{i} = evaluateFields (params{i}, scope, {'defocus', 'object', 'wavelength', 'pixel_size'}, ...
                                                          {param.defocus(i),     [],       [],           []}) ;
            
        end
        p = evaluateFields (params{i}, scope, {'illumination', 'pupil'}, {'', ''}) ;
        wavelength = p.wavelength ;
        pixel_size = p.pixel_size ;
        if isstruct(p.illumination), LF = p.illumination.fn ;
        else LF = p.illumination ; end
        if isstruct(p.pupil), PF = p.pupil.fn ;
        else PF = p.pupil ; end
        images(:,:,i) = pcoh_image (object, wavelength / pixel_size, PF, LF) ;
    end
    if isfield(param,'name')
        attribute_paramVariable ('set', scope{2}, param.name, ...
                @(in_settings,in_scope)objectfield(mergeStruct(in_settings,settings),[in_scope,scope])) ;
    end
end
function saveToFile (node, settings, scope)
    [settings, scope] = attributesToStruct (node, settings, scope) ;
    settings = evaluateFields (settings, scope, {'file'}, ...
                                                {''}) ;
    save_struct = struct() ;
    nodes = node.getChildNodes ;
    for i=1:nodes.getLength
        node = nodes.item(i-1) ;
        switch char(node.getNodeName)
            case 'value'
                value = getAttribute(char(node.getFirstChild.getData), settings, scope) ;
                if strcmp(class(value),'function_handle'), value = value(settings,scope) ; end
                save_struct.(char(node.getAttributes.getNamedItem('name').getValue)) = value ;
        end
    end
    if isempty(fieldnames(save_struct))
        value = getAttribute(char(xml.getFirstChild.getData), settings, scope) ;
        if strcmp(class(value),'function_handle'), value = value(settings,scope) ; end
        save_struct.data = value ;
    end
    
    [pathstr,~,ext] = fileparts(settings.file) ;
    if ~isempty(pathstr) && ~isdir(pathstr)
        mkdir(pathstr) ;
    end
    if regexp(lower(ext), '^(png,tiff,jpeg,jpg)$')
        fn = fieldnames(save_struct) ;
        for i=1:length(fn)
            if size(save_struct.(fn{i}),1) > 1 &&  size(save_struct.(fn{i}),2) > 1
                img = save_struct.(fn{i}) ;
                break ;
            end
        end
        range = [min(img(:)), max(img(:))] ;
        if isfield(save_struct,'min')
            range(1) = save_struct.min ;
        end
        if isfield(save_struct,'max')
            range(2) = save_struct.max ;
        end
        img = (img-range(1))/(range(2) - range(1)) ;
        img(img>1) = 1 ;
        img(img<0) = 0 ;
        img = uint16(img) ;
        imwrite(img, settings.file) ;
    else
        save (settings.file, '-struct', 'save_struct') ;
    end
end
function [images, params, settings] = include_xml (node, settings, scope)
    param = attributesToStruct (node, settings, scope) ;
    if ~isempty(node.getFirstChild), param.data = getAttribute(char(node.getFirstChild.getData), settings_in, scope) ; end
    if isfield(param,'data')
        %import java.io.StringBufferInputStream ;
        filename = StringBufferInputStream(param.data) ;
        root = xmlread(filename) ;
        root = root.getDocumentElement ;
        [images, params, settings] = measurementset(root, settings, scope) ;
    else
        param = evaluateFields (param, scope, {'file'}, ...
                                              {[]}) ;
        old_path = param.path ;
        if regexp(param.file, '^/|^[A-Za-z]:') %full path
            file = param.file ;
        else
            file = [param.path '/' param.file] ;
        end
        root = xmlread (file) ;
        settings.path = fileparts(file) ;
        root = root.getDocumentElement ;
        [images, params, settings] = measurementset(root, settings, scope) ;
        settings.path = old_path ;
    end
end






function [images, params] = noise (node, settings, scope, images, params)
    settings = attributesToStruct (node, settings, scope) ;
    settings = evaluateFields (settings, scope, {'type', 'seed', 'var','nonoise'}, ...
                                                {'',     0,      '',0}) ;
    if settings.nonoise || attribute_paramVariable (settings, scope, 'nonoise', 0), return ; end
    if ~isnumeric(settings.seed) || settings.seed <= 0
        rng('shuffle') ;
        settings.seed =  randi([1,10000],1) ;
    end
    rng(settings.seed) ;
    switch settings.type
        case 'gaussian'
            settings = evaluateFields (settings, scope, {'variance', 'std', 'mean'}, ...
                                                        {1,          '',    0}) ;
            if ~isempty(settings.std), settings.variance = settings.std.^2 ; end
            if length(settings.variance) == 1
                noise_fn = @(var)var + sqrt(settings.variance)*randn(size(var)) + settings.mean ;
            else
                noise_fn = @(var)var + imnoise(var,'localvar',settings.variance) + settings.mean ;
            end
        case 'poisson'
            noise_fn = @(var)imnoise(var,'poisson') ;
        case 'salt-pepper'
            settings = evaluateFields (settings, scope, {'density'}, ...
                                                        {''}) ;
            noise_fn = @(var)imnoise(var,'salt & pepper',settings.density) ;
        case 'speckle'
            settings = evaluateFields (settings, scope, {'variance', 'std'}, ...
                                                        {1,          ''}) ;
            if ~isempty(settings.std), settings.variance = settings.std.^2 ; end
            noise_fn = @(var)var + sqrt(12*settings.variance)*var.*(rand(size(var)-0.5)) ;
        case 'quantization'
            %settings = evaluateFields (settings, scope, {'bits', 'min', 'max'}, ...
            %                                            {1}) ;
            error ('Quantization noise has not been implemented.') ;
        case 'dither'
            error ('Dithering as a noise has not been implemented.') ;
        otherwise
            error ('Invalid noise type: %s', settings.type) ;
    end
    if isempty(settings.var), settings.var = 'images' ; end
    if strcmp(settings.var,'images')
        for i=1:length(params)
            images(:,:,i) = noise_fn(images(:,:,i)) ;
        end
    elseif isfield(params{1},settings.var)
        for i=1:length(params)
            params.(settings.var) = noise_fn(settings.var) ;
        end
    else
        error ('Invalid variable to add noise to: %s', settings.var) ;
    end
end
function varValue (node, settings, scope)
    name =  char(node.getAttributes.getNamedItem('name').getValue) ;
    if node.getChildNodes.getLength == 1 && strcmp('#text', char(node.getChildNodes.item(0).getNodeName))
        value = getAttribute(char(node.getFirstChild.getData), settings, scope) ;
    else
        [value, ~] = loadSubnodes (node, settings, scope) ;
    end
    attribute_paramVariable ('set', settings.id, name, value) ;
end

%% Postprocessing Features

function [images, params, settings] = setparam (xml, settings, scope)
    param_name  = char(xml.getAttributes.getNamedItem('name').getValue) ;
    param_value = char(xml.getAttributes.getNamedItem('value').getValue) ;
    [images, params] = loadSubnodes (xml, settings, scope) ;
    for i=1:length(params)
        p = params{i} ;
        p.index = i ;
        p.image = images(:,:,i) ;
        %if isfield(p, param_name), p.value = p.(param_name) ; end
        value = getAttribute(param_value, p, scope) ;
        if strcmp(param_name, 'image')
            if strcmp(class(value),'function_handle'), value = value(p, scope) ; end
            images(:,:,i) = value ;
        else
            params{i}.(param_name) = value(p,scope) ;
        end
    end
end
function [images, params, settings] = imagecrop (xml, settings, scope)
    if isstruct(xml)
        images = xml.images ;
        params = xml.params ;
    else
        [images, params] = loadSubnodes (xml, settings, scope) ;
    end
    fractional_shifts = zeros(length(params),2) ;
    %% Integer Shifts
    if ~isempty(params)
        for i=1:length(params)
            if isstruct(xml)
                pset = params{i} ;
            else
                p = params{i} ;
                p.index = i ;
                p.image = images(:,:,i) ;
                pset = attributesToStruct (xml, p, scope) ;
                %pset = mergeStruct (settings, pset) ;
                pset = mergeStruct (pset, settings) ;
            end
            pset = evaluateFields (pset, scope, {'offset_x', 'offset_y','size','pixel_size','crop','subpixel'}, ...
                                                {0,          0,         '',    '',[size(images,1),size(images,2)],'on'}) ;
            if length(pset.crop) == 1, pset.crop = [pset.crop, pset.crop] ; end
            offset_x = -pset.offset_x / pset.pixel_size ;
            offset_y = -pset.offset_y / pset.pixel_size ;
            offset_x = offset_x - size(images,1) / 2 + pset.crop(1) / 2 ;
            offset_y = offset_y - size(images,2) / 2 + pset.crop(2) / 2 ;
            integer_offset_x = round(offset_x) ; integer_offset_y = round(offset_y) ;
            fractional_shifts(i,:) = [offset_x - integer_offset_x,...
                                      offset_y - integer_offset_y] ;
            switch pset.subpixel
                case 'x'
                    fractional_shifts(i,2) = 0 ;
                case 'y'
                    fractional_shifts(i,1) = 0 ;
                case 'off'
                    fractional_shifts(i,:) = 0 ;
                case 'on'
                otherwise
                    error('Subpixel can have values: x,y,on,off. Invalid value "%s" provided.', pset.subpixel) ;
            end
            images(:,:,i) = circshift(images(:,:,i),[integer_offset_y,integer_offset_x]) ;
        end
        settings.size = size(images) ;
        sel_area_x = 1:pset.crop(1) ;
        sel_area_y = 1:pset.crop(2) ;
        images = images(sel_area_x, sel_area_y, :) ;
        %% Fractional Shifts
        [xx, yy] = meshgrid(fftshift(((-size(images,1)/2):(size(images,1)/2-1)) / size(images,1)), ...
                            fftshift(((-size(images,2)/2):(size(images,2)/2-1)) / size(images,2))) ;
        for i=1:length(params)
            if fractional_shifts(i,1) ~= 0 || fractional_shifts(i,2) ~= 0
                images(:,:,i) = ifft2(fft2(images(:,:,i)) .* exp(-2*pi*1i * (fractional_shifts(i,1) * xx + fractional_shifts(i,2) * yy))) ;
            end
        end
        images = abs(images) ; %any numerical problems from the fft    
    end
end
function [images, params, settings] = imageregister (xml, settings, scope)
    [images, params] = loadSubnodes (xml, settings, scope) ; %don't pass on inherited values
    params_limited = params ; old_subpixel = cell(size(params)) ;
    for i=1:length(params)
        p = params{i} ;
        p.index = i ;
        p.image = images(:,:,i) ;
        pset = attributesToStruct (xml, p, scope) ;
        pset = mergeStruct (settings, pset) ;
        pset = evaluateFields (pset, scope, {'offset_x', 'offset_y','size','pixel_size','crop',                        'subpixel','precision'}, ...
                                            {0,          0,         '',    '',          [size(images,1),size(images,2)],'on',     1}) ;
        old_subpixel{i} = pset.subpixel ;
        pset.subpixel = 'off' ;
        params_limited{i} = pset ;
    end
    images_crop = imagecrop (struct('xml',xml, 'images', images, 'params', {params_limited}), settings, scope) ;
    
    dx = zeros(1,size(images,3)) ;
    dy = zeros(1,size(images,3)) ;
    for i=2:size(images,3)
        if params_limited{i}.precision == 0, continue ; end
        output = dftregistration(fft2(images_crop(:,:,i-1)),fft2(images_crop(:,:,i)), params_limited{i}.pixel_size / params_limited{i}.precision) ;
        %output =  [error,diffphase,net_row_shift,net_col_shift]
        dy(i) = output(3) + dy(i-1) ;
        dx(i) = output(4) + dx(i-1) ;
    end
    dx = dx - mean(dx(:)) ;
    dy = dy - mean(dy(:)) ;
    
    for i=1:size(images,3)
        params_limited{i}.offset_x = params_limited{i}.offset_x - dx(i) * params_limited{i}.pixel_size ;
        params_limited{i}.offset_y = params_limited{i}.offset_y - dy(i) * params_limited{i}.pixel_size ;
        params_limited{i}.subpixel = old_subpixel{i} ;
    end
    [images, ~, settings] = imagecrop (struct('xml',xml, 'images', images, 'params', {params_limited}), settings, scope) ;
end
function [images_out, params, settings] = imagepad (xml, settings, scope)
    [images, params] = loadSubnodes (xml, settings, scope) ; %don't pass on inherited values
    [settings, scope] = attributesToStruct (xml, settings, scope) ;
    settings = evaluateFields(settings,scope, {'size'}, ...
                                              {[]    }) ;
    if isempty(settings.size)
        images_out = images ;
        return ;
    elseif length(settings.size) == 1
        settings.size = [settings.size, settings.size] ;
    end
    
    images_out = ones(settings.size(1), settings.size(2), size(images,3)) ;
    if ~isempty(params)
        for i=1:length(params)
            p = params{i} ;
            p.index = i ;
            p.image = images(:,:,i) ;
            pset = attributesToStruct (xml, p, scope) ; %add the node params to this one
            pset = mergeStruct (settings, pset) ;
            pset = evaluateFields (pset, scope, {'offset_x', 'offset_y','value','pixel_size'}, ...
                                                {0,          0,         0,    '',[size(images,1),size(images,2)],'on'}) ;
            if strcmp(pset.value, 'border')
                pset.value = mean([reshape(images(1,:,i),1,[]), reshape(images(end,:,i),1,[]), reshape(images(:,1,i),1,[]), reshape(images(:,end,i),1,[])]) ;
            end
            offset_x = -pset.offset_x / pset.pixel_size + (size(images_out,2) - size(images,2)) / 2 ;
            offset_y = -pset.offset_y / pset.pixel_size + (size(images_out,1) - size(images,1)) / 2 ;
            integer_offset_x = round(offset_x) ; integer_offset_y = round(offset_y) ;
            %TODO: I need to consider what happens if the offsets cause the
            %image to shift outside the new image (maybe even merge the
            %imagepad with the crop function
            images_out(:,:,i) = pset.value ;
            images_out((1:size(images,1)) + integer_offset_y, (1:size(images,2)) + integer_offset_x, i) = images(:,:,i) ;
        end
    end
end
function [images, params, settings] = removeoutliers (xml, settings, scope)
    [settings, scope] = attributesToStruct (xml, settings, scope) ;
    [images, params] = loadSubnodes (xml, settings, scope) ;
    settings = evaluateFields (settings, scope, {'mode','outliers','cutoff', 'inpaintmethod'}, ...
                                                {'cutoff',1,'', 5}) ;
    switch settings.mode
        case 'cutoff'
            img_mean = mean(images(:)) ;
            images( (images > ( img_mean * (1 + settings.cutoff) ) ) | (images < (img_mean * (1 - settings.cutoff) ) ) ) = NaN ;
        case 'outlier'
            if settings.outliers < 1, settings.outliers = settings.outliers * length(images(:)) ; end
            sz = size(images) ;
            images = outliers (images(:), settings.outliers) ;
            images = reshape(images, sz) ;
    end
    for i=1:length(params)
        images(:,:,i) = inpaint_nans(images(:,:,i), settings.inpaintmethod) ;
    end
end
function [images, params, settings] = normalizebackground (xml, settings, scope)
    [images, params] = loadSubnodes (xml, settings, scope) ;
    if ~isempty(xml.getAttributes.getNamedItem('mode'))
        mode  = char(xml.getAttributes.getNamedItem('mode').getValue) ;
    else
        mode = 'polynomial' ;
    end
    switch mode
        case 'dividemean'
            mn = mean(images,3) ;
            images = images ./ repmat(mn, [1,1,size(images,3)]) ;
        case 'polynomial'
            [Y, X] = ndgrid(1:size(images,1), 1:size(images,2)) ;
            ivar = [X(:), Y(:)] ;
            for i=1:length(params)
                p = params{i} ;
                p.index = i ;
                p.image = images(:,:,i) ;
                pset = attributesToStruct (xml, p, scope) ;
                pset = evaluateFields (pset, scope, {'bgorders', 'mask'}, ...
                                                    {-1, []}) ;
                if pset.bgorders >= 0
                    if isstruct(pset.mask) && isfield(pset.mask, 'fn'), pset.mask = pset.mask.fn ; end
                    if strcmp(class(pset.mask),'function_handle')
                        [xx,yy] = meshgrid(linspace(-1,1,size(images,1)), linspace(-1,1,size(images,2))) ;
                        pset.mask = pset.mask(xx,yy) ~= 0 ;
                    end
                    if ~isempty(pset.mask) && isequal(size(pset.mask),size(images(:,:,i)))
                        img = reshape(images(:,:,i),1,[]) ;
                        p = polyfitn(ivar(pset.mask(:),:), img(pset.mask(:)), pset.bgorders) ;
                    elseif ~isempty(pset.mask)
                        error('Background normalization mask must be the same size as the image.') ;
                    else
                        p = polyfitn(ivar, reshape(images(:,:,i),1,[]), pset.bgorders) ;
                    end
                    background = reshape(polyvaln(p, ivar),size(images,1),size(images,2)) ;
                    images(:,:,i) = images(:,:,i) ./ background ;
                end
            end
        case 'max'
            images = images ./ max(images(:)) ;
        case 'min'
            images = images - min(images(:)) ;
        case 'range'
            images = images - min(images(:)) ;
            images = images ./ max(images(:)) ;
    end
end
function [images, params, settings] = importImages (xml, settings, scope)
    [settings, scope] = attributesToStruct (xml, settings, scope) ;
    settings = evaluateFields (settings, scope, {'params', 'images'}, ...
                                                {'', ''}) ;
    if length(settings.params) ~= size(settings.images,3)
        error ('Import tag requires params to have same length as size(images,3)') ;
    elseif ~isempty(settings.params) && ~isempty(settings.images)
        images = settings.images ;
        params = settings.params ;
        for i=1:length(params)
            for fn=fieldnames(params{i})'
                if strcmp(class(params{i}.(fn{1})),'function_handle'), params{i}.(fn{1}) = struct('fn',params{i}.(fn{1})) ; end
            end
        end
    else
        error ('Import tag requires params and images') ;
    end
end
function [images, params] = filterImages (xml, settings, scope)
    [images, params] = loadSubnodes (xml, settings, scope) ;
    
    settings = attributesToStruct (xml, settings, scope) ;
    settings.size = size(images,1) ;
    settings = evaluateFields (settings, scope, {'type',      'wh_ratio', 'fmin', 'fmax', 'pixel_size', 'disabled', 'neighborhood'}, ...
                                                {'bandreject', 1,         0,      inf,    '',           0,          2}) ;
    if length(settings.neighborhood) == 1, settings.neighborhood = [1,1] * settings.neighborhood ; end
    if ~settings.disabled
        if length(settings.pixel_size) == 1, settings.pixel_size = [1,1] * settings.pixel_size ; end
        [xx, yy] = meshgrid(((-size(images,1)/2):(size(images,1)/2-1)) / (size(images,1) * settings.pixel_size(1)), ...
                            ((-size(images,2)/2):(size(images,2)/2-1)) / (size(images,2) * settings.pixel_size(2))) ;
        xx = xx / sqrt(settings.wh_ratio) ;
        yy = yy * sqrt(settings.wh_ratio) ;
        f = xx.^2 + yy.^2 ;
        switch settings.type
            case 'bandreject'
                for i=1:size(images,3)
                    images(:,:,i) = ifft2(ifftshift(fftshift(fft2(images(:,:,i))) .* ...
                        ( (f <= settings.fmin^2) | (f >= settings.fmax^2)) )) ;
                end
            case 'bandpass'
                for i=1:size(images,3)
                    images(:,:,i) = ifft2(ifftshift(fftshift(fft2(images(:,:,i))) .* ...
                        ( (f >= settings.fmin^2) & (f <= settings.fmax^2)) )) ;
                end
            case 'median'
                for i=1:size(images,3)
                    images(:,:,i) = medfilt2(images(:,:,i), settings.neighborhood) ;
                end
        end
    end
end
function [images_out, params] = resampleImages (xml, settings, scope)
    [images, params] = loadSubnodes (xml, settings, scope) ;
    if isempty(images)
        images_out = images ;
        return ;
    end
    settings = attributesToStruct (xml, settings, scope) ;
    settings = evaluateFields (settings, scope, {'power'}, ...
                                                {'0'}) ;
    new_size = size(images) * 2^settings.power ; new_size = new_size(1:2) ;
    new_size = 2.^floor(log2(new_size)) ; %make it next lowest power of 2
    images_out = zeros(new_size(1), new_size(2), size(images,3)) ;
    ps_factor = size(images,1) / new_size(1) ;
    if settings.power <= 0
        %downsample by a factor of 2^-power
        f1 = (-size(images,1)/2):(size(images,1)/2-1) ;
        f2 = (-size(images,2)/2):(size(images,2)/2-1) ;
        [~, I] = sort(abs(f1+0.1)) ; filt_1 = I(1:new_size(1)) ; filt_1 = sort(filt_1) ;
        [~, I] = sort(abs(f2+0.1)) ; filt_2 = I(1:new_size(2)) ; filt_2 = sort(filt_2) ;
        for i=1:size(images,3)
            param = evaluateFields(params{i}, scope, {'pixel_size'}, ...
                                                     {''}) ;
            img = fftshift(fft2(images(:,:,i))) ;
            img = img(filt_1, filt_2) ;
            images_out(:,:,i) = real(ifft2(ifftshift(img))) ;
            params{i}.pixel_size = param.pixel_size * ps_factor ;
        end
        images_out = images_out * new_size(1) * new_size(2) / size(images,1) / size(images,2) ;
    else
        %upsample
        images_out = zeros(new_size(1), new_size(2), size(images,3)) ;
        for i=1:size(images,3)
            param = evaluateFields(params{i}, scope, {'pixel_size'}, ...
                                                     {''}) ;
            img = fftshift(fft2(images(:,:,i))) ;
            img = padarray(img, [ceil((new_size(1) - size(images,1)) / 2), ceil((new_size(2) - size(images,2)) / 2)], 0) ;
            img = img(1:new_size(1), 1:new_size(2)) ;
            images_out(:,:,i) = real(ifft2(ifftshift(img))) ;
            params{i}.pixel_size = param.pixel_size * ps_factor ;
        end
        images_out = images_out * new_size(1) * new_size(2) / size(images,1) / size(images,2) ;
    end
        
end
function [images, params, settings] = ifparam (xml, settings, scope)
    if ~isempty(xml.getAttributes.getNamedItem('true'))
        truth = getAttribute(char(xml.getAttributes.getNamedItem('true').getValue), settings, scope) ;
        if strcmp(class(truth),'function_handle'), truth = truth(settings,scope) ; end
    elseif ~isempty(xml.getAttributes.getNamedItem('false'))
        truth = getAttribute(char(xml.getAttributes.getNamedItem('false').getValue), settings, scope) ;
        if strcmp(class(truth),'function_handle'), truth = truth(settings,scope) ; end
        truth = ~truth ;
    else
        truth = 0 ;
    end
    if truth
        [settings, scope] = attributesToStruct (xml, settings, scope) ;
        if isfield(settings,'true'), settings = rmfield(settings,'true') ; end
        if isfield(settings,'false'), settings = rmfield(settings,'false') ; end
        [images, params] = loadSubnodes (xml, settings, scope) ;
    else
        images = [] ;
        params = [] ;
    end
end
function [images, params, settings] = forparam (xml, settings, scope)
    [settings, scope, new_fields] = attributesToStruct (xml, settings, scope) ;
    settings = evaluateFields (settings, scope, new_fields) ;
    if sum(abs(diff(arrayfun(@(x)length(settings.(x{1})), new_fields))))
        error('All the attributes in a for tag must have the same length') ;
    end
    n = length(settings.(new_fields{1})) ;
    params = {} ; images = [] ;
    for i=1:n
        set = settings ;
        set.index = i ;
        for j=1:length(new_fields)
            set.(new_fields{j}) = settings.(new_fields{j})(i) ;
            if iscell(set.(new_fields{j})), set.(new_fields{j}) = set.(new_fields{j}){1} ; end
        end
        [img, param] = loadSubnodes (xml, set, scope) ;
        if ~isempty(img)
            if ~isempty(images) && (size(images,1) ~= size(img,1) || size(images,2) ~= size(img,2)), error ('Image has dimensions that do not match.') ; end
            images = cat(3, images, img) ;
            params = [params, param] ; %#ok<AGROW>
        end
    end
end
function [images, params, settings] = selectimages (xml, settings, scope)
    [settings, scope] = attributesToStruct (xml, settings, scope) ;
    [images, params, settings] = loadSubnodes (xml, settings, scope) ;
    settings.images = images ;
    settings.N = size(images,3) ;
    settings = evaluateFields (settings, scope, {'index'}, ...
                                                {'all'}) ;
    if ischar(settings.index)
        switch settings.index
            case 'all'
                %keep all images
            otherwise
                error('select tag index must be an array of indices or ''all''') ;
        end
    else
        try
            images = images(:,:,settings.index(:)) ;
            params = params(settings.index(:)) ;
        catch %#ok<CTCH>
            error('Invalid select tag index. %d Images. Index provided: %s', size(images,3), num2str(settings.index(:))) ;
        end
    end
end












%% Load XML File
function [images, params, settings] = measurementset (xml, settings, scope)
    [settings, scope] = attributesToStruct (xml, settings, scope) ;
    if isfield(settings,'cache')
        sett = evaluateFields (settings, scope, {'cache', 'nocache'}, ...
                                                {[], 0}) ;
        if ~sett.nocache
            if regexp(sett.cache, '^/|^[A-Za-z]:') %full path
                file = sett.cache ;
            else
                file = [sett.path '/' sett.cache] ;
            end
            if exist(file,'file')
                load(file, '-mat') ;
            else
                [images, params, settings] = loadSubnodes (xml, settings, scope) ;
                save(file, '-mat', 'images', 'params', 'settings') ;
            end
        else
            [images, params, settings] = loadSubnodes (xml, settings, scope) ;
        end
    else
        [images, params, settings] = loadSubnodes (xml, settings, scope) ;
    end
end
function [images, params, settings] = loadSubnodes (node, settings, scope)
    params = {} ;
    images = [] ;
    image_nodes = node.getChildNodes ;
    %% Run Scripts /  Load Objects
    for i=1:image_nodes.getLength
        node = image_nodes.item(i-1) ;
        img = [] ; param = [] ;
        switch char(node.getNodeName)
            case 'image'
                [img, param] = loadImage (node, settings, scope) ;
            case 'propagate'
                [img, param] = propagate (node, settings, scope) ;
            case 'object'
                [img, param] = object (node, settings, scope) ;
            case 'measurementset'
                [img, param] = measurementset (node, settings, scope) ;
            case 'save'
                saveToFile (node, settings, scope) ;
            case 'setparam'
                [img, param] = setparam (node, settings, scope) ;
            case 'imagecrop'
                [img, param] = imagecrop (node, settings, scope) ;
            case 'imageregister'
                [img, param] = imageregister (node, settings, scope) ;
            case 'pad'
                [img, param] = imagepad (node, settings, scope) ;
            case 'removeoutliers'
                [img, param] = removeoutliers (node, settings, scope) ;
            case 'normalizebackground'
                [img, param] = normalizebackground (node, settings, scope) ;
            case 'filter'
                [img, param] = filterImages(node, settings, scope) ;
            case 'resample'
                [img, param] = resampleImages(node, settings, scope) ;
            case 'select'
                [img, param] = selectimages(node, settings, scope) ;
            case 'import'
                [img, param] = importImages(node, settings, scope) ;
            case 'if'
                [img, param, sett] = ifparam(node, settings, scope) ;
                settings = mergeStruct (settings, sett) ;
            case 'for'
                [img, param] = forparam(node, settings, scope) ;
            case 'include'
                [img, param, sett] = include_xml (node, settings, scope) ;
                settings = mergeStruct (settings, sett) ;
        end
        if ~isempty(img)
            if ~isempty(images) && (size(images,1) ~= size(img,1) || size(images,2) ~= size(img,2)), error ('Image has dimensions that do not match.') ; end
            images = cat(3, images, img) ;
            params = [params, param] ; %#ok<AGROW>
        end
    end
    %% Apply Noise Factors
    for i=1:image_nodes.getLength
        node = image_nodes.item(i-1) ;
        img = [] ; param = [] ;
        switch char(node.getNodeName)
            case 'noise'
                [images, params] = noise (node, settings, scope, images, params) ;
        end
    end
end
function [settings, scope, new_fields] = attributesToStruct (node, settings, scope)
% This function loads all the attributes into a struct
    %we do not inherit id or name fields
    literal_fields = {'name', 'path'} ;
    new_fields = [] ;
    if isfield(settings, 'id'), settings = rmfield(settings, 'id') ; end
    if isfield(settings, 'name'), settings = rmfield(settings, 'name') ; end
    old_path = settings.path ;
    attributes = node.getAttributes ;
    settings.id = attributes.getNamedItem('id') ;
    if isempty(settings.id), settings.id = getId() ;
    else settings.id = char(settings.id.getValue) ; end
    scope = [settings.id, scope] ;
    for i=1:attributes.getLength
        name = char(attributes.item(i-1).getName) ;
        value = char(attributes.item(i-1).getValue) ;
        if sum(strcmp(literal_fields,name)) == 0
            settings.(name) = getAttribute(value, settings, scope) ;
        else
            settings.(name) = value ;
        end
        new_fields = [new_fields, {name}] ; %#ok<AGROW>
    end
    settings.id = scope{1} ;
    if ~strcmp(old_path, settings.path) && ~isdir(settings.path)
        settings.path = [old_path '/' settings.path] ;
    end
    %% Load any settings or variables defined in this scope
    child_nodes = node.getChildNodes ;
    if isfield(settings,'import')
        settings = evaluateFields (settings, scope, {'import'}, {''}) ;
        s_import = settings.import ;
        for fn=fieldnames(s_import)'
            if strcmp(class(s_import.(fn{1})),'function_handle'), s_import.(fn{1}) = struct('fn',s_import.(fn{1})) ; end
        end
        settings = mergeStruct(s_import,settings) ;
        settings = rmfield(settings,'import') ;
    end
    for i=1:child_nodes.getLength
        node = child_nodes.item(i-1) ;
        switch char(node.getNodeName)
            case 'illumination'
                name =  char(node.getAttributes.getNamedItem('name').getValue) ;
                attribute_paramVariable ('set', settings.id, name, ...
                                         shape (node, settings, scope)) ;
            case 'pupil'
                name =  char(node.getAttributes.getNamedItem('name').getValue) ;
                attribute_paramVariable ('set', settings.id, name, ...
                                         shape (node, settings, scope)) ;
            case 'shape'
                name =  char(node.getAttributes.getNamedItem('name').getValue) ;
                attribute_paramVariable ('set', settings.id, name, ...
                                         shape (node, settings, scope)) ;
            case 'var'
                %name =  char(node.getAttributes.getNamedItem('name').getValue) ;
                %value = getAttribute(char(node.getFirstChild.getData), settings, scope) ;
                %attribute_paramVariable ('set', settings.id, name, value) ;
                varValue (node, settings, scope) ;
            case 'setting'
                name =  char(node.getAttributes.getNamedItem('name').getValue) ;
                value = getAttribute(char(node.getFirstChild.getData), settings, scope) ;
                settings.(name) = value ;
                new_fields = [new_fields, {name}] ; %#ok<AGROW>
        end
    end
end
%% Attribute Like
function [value, settings] = shape (node, settings, scope)
    [settings, scope] = attributesToStruct (node, settings, scope) ;
    %% Generate Illumination Function
    shapes = [] ;
    nodes = node.getChildNodes ;
    for i=1:nodes.getLength
        node = nodes.item(i-1) ;
        switch char(node.getNodeName)
            case 'circle'
                at = attributesToStruct(node, settings, scope) ;
                at.type = 'circle' ;
                shapes{length(shapes)+1} = at ; %#ok<AGROW>
            case 'arc'
                at = attributesToStruct(node, settings, scope) ;
                at.type = 'arc' ;
                shapes{length(shapes)+1} = at ; %#ok<AGROW>
            case 'zernike'
                at = attributesToStruct(node, settings, scope) ;
                at.type = 'circle' ;
                at.value = @(settings, scope)getPupil(settings,scope) ;
                shapes{length(shapes)+1} = at ; %#ok<AGROW>
        end
    end
    value = @(in_settings,in_scope)struct('fn',evalulateShapes(shapes,mergeStruct(in_settings,settings),[in_scope,scope])) ;
end
function shape_fn = evalulateShapes (shapes, settings, scope)
    for i=1:length(shapes)
        s = shapes{i} ;
        s = mergeStruct(settings, s) ;
        switch s.type
            case 'circle'
                s = evaluateFields (s, scope, {'x', 'y', 'radius' 'value', 'mode', 'type', 'binary'}, ...
                                              {0,   0,   inf,      1,      'union', ''       0}, '*') ;
                value = s.value ;
                if ~strcmp(class(s.value),'function_handle'), s.value = @(x,y)ones(size(x))*value ; end
            case 'arc'
                s = evaluateFields (s, scope, {'x', 'y', 'start', 'end', 'radius' 'value', 'mode', 'type', 'binary'}, ...
                                              {0,   0,   0,       2*pi,  '',      1,      'union', '',      0}, '*') ;
                value = s.value ;
                if ~strcmp(class(s.value),'function_handle'), s.value = @(x,y)ones(size(x))*value ; end
        end
        shapes{i} = s ;
    end
    if isfield(settings,'invert')
        invert = ~~settings.invert ;
    else
        invert = 0 ;
    end
    if isfield(settings,'sampling')
        sampling = settings.sampling ;
    else
        sampling = 1 ;
    end
    clear ('settings', 'scope', 's', 'value', 'i') ; 
    if invert
        if sampling ~= 1
            %shape_fn = @(fx,fy)oversample('down',sampling,~runShapes(oversample('up',sampling,fx),oversample('up',sampling,fy),shapes)) ;
            shape_fn = @(fx,fy)oversample(sampling,fx,fy,@(fx2,fy2)~runShapes(fx2,fy2,shapes)) ;
        else
            shape_fn = @(fx,fy)~runShapes(fx,fy,shapes) ;
        end
    else
        if sampling ~= 1
            %shape_fn = @(fx,fy)oversample('down',sampling,runShapes(oversample('up',sampling,fx),oversample('up',sampling,fy),shapes)) ;
            shape_fn = @(fx,fy)oversample(sampling,fx,fy,@(fx2,fy2)runShapes(fx2,fy2,shapes)) ;
        else
            shape_fn = @(fx,fy)runShapes(fx,fy,shapes) ;
        end
    end
end
function values = runShapes (fx, fy, shapes)
    values = [] ;
    %% Generate Illumination Function
    for i=1:length(shapes)
        s = shapes{i} ;
        shape_value = zeros(size(values)) ;
        shape_pts = zeros(size(values)) ;
        switch s.type
            case 'circle'
                shape_value = fillpole(s.x+fx,s.y+fy,s.radius,[],[],s.value) ;
                shape_pts = fillpole(s.x+fx,s.y+fy,s.radius,[],[],'') ;
            case 'arc'
                shape_value = fillpole(s.x+fx,s.y+fy,s.radius,s.start,s.end,s.value) ;
                shape_pts = fillpole(s.x+fx,s.y+fy,s.radius,s.start,s.end,'') ;
        end
        if s.binary == 1, shape_value = shape_value > 0 ; end
        if isempty(values), values = shape_value ;
        else
            switch s.mode
                case 'set'
                    values(shape_pts ~= 0) = shape_value(shape_pts ~= 0) ; %#ok<AGROW>
                case 'intersect'
                    values(~shape_pts) = 0 ; %#ok<AGROW>
                case 'subtract'
                    values = values - shape_value ;
                case 'union'
                    values = values | shape_value ;
                case 'add'
                    values = values + shape_value ;
                case 'xor'
                    values = xor(values > 0, shape_value > 0) ;
                case 'multiply'
                    values = values .* (shape_value + 1 - shape_pts) ;
            end
        end
        if s.binary == 1, values = values > 0 ; end
    end
end
function [PF] = getPupil (param, scope)
    param = evaluateFields (param, scope, {'aberration_unit','NA','shift_x','shift_y','defocus', 'wavelength', ...
            'piston', 'tilt', 'tip', 'astigmatism_45', 'astigmatism_90', 'coma_y', 'coma_x', 'trefoil1', 'trefoil2', 'astigmatism_secondary_45', 'astigmatism_secondary_90', 'primary_spherical'}, ...
                                                 {'rms',[], 0,         0,   0,        '', ...
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, '*') ;
    param.aberration = [0, param.tilt, param.tip, param.astigmatism_45, 0, param.astigmatism_90, param.trefoil1, param.coma_y, param.coma_x, param.trefoil2, 0, param.astigmatism_secondary_45, param.primary_spherical, param.astigmatism_secondary_90, 0] ;
    switch param.aberration_unit
        case 'rms'
            param.aberration = param.aberration / param.wavelength ;
    end
    %PF = @(fx, fy) exp( 1i * pi * param.defocus / param.wavelength * ((fx-param.shift_x).^2 + (fy-param.shift_y).^2) + 2i*pi*getAberration(fx-param.shift_x,fy-param.shift_y,param.aberration,param.NA,param.aberration_unit)) ;
    PF = @(fx, fy) exp( -2i * pi * param.defocus / param.wavelength * sqrt( 1 - (fx-param.shift_x).^2 - (fy-param.shift_y).^2) + 2i*pi*getAberration(fx-param.shift_x,fy-param.shift_y,param.aberration,param.NA,param.aberration_unit)) ;
end
function A = getAberration(f_x, f_y, aberration_weights, NA, mode)
    f_x = f_x / NA ;
    f_y = f_y / NA ;
    r = sqrt(f_x.^2 + f_y.^2) ;
    theta = atan2(f_y, f_x) ;
    r(r>1) = 1 ;

    aw = zeros(15, 1) ;
    aw(1:min(length(aberration_weights), length(aw))) = aberration_weights ;
    
    %piston, tilt, tip, defocus, astigmatism_x, astigmatism_y, 
    n = [0  1  1  2  2  2  3  3  3  3  4  4 4 4 4];
    m = [0 -1  1 -2  0  2 -3 -1  1  3 -4 -2 0 2 4];
    
    Z = zernfun (n,m,r(:),theta(:),'norm') ;
    %columns of Z are each polynomial
    switch mode
        case 'rms'
            NA_filt = ( (f_x.^2+f_y.^2) <= 1 ) ;
            Z(~repmat(NA_filt(:), 1, size(Z,2))) = nan ;
            nstd = nanstd(Z) ; nstd(nstd == 0) = nan ;
            Z = Z ./ repmat(nstd, size(Z,1), 1) ;
            Z(isnan(Z)) = 0 ;
            A = Z * aw ;
            A = reshape(A, size(f_x)) ;
        case 'waves'
            NA_filt = ( (f_x.^2+f_y.^2) <= 1 ) ;
            Z(~repmat(NA_filt(:), 1, size(Z,2))) = nan ;
            nstd = nanstd(Z) ; nstd(nstd == 0) = nan ;
            Z = Z ./ repmat(nstd, size(Z,1), 1) ;
            Z(isnan(Z)) = 0 ;
            A = Z * aw ;
            A = reshape(A, size(f_x)) ;
        case 'amplitude'
            A = Z * aw ;
            A = reshape(A, size(f_x)) ;
            A = A .* ( (f_x.^2+f_y.^2) <= 1 ) ;
    end
end
function [mask] = objectfield (settings, scope)
    settings = evaluateFields (settings, scope, {'type','pixel_size','size','oversample'}, ...
                                                {'',    [],          [],    1}) ;
    settings.pixel_size = settings.pixel_size ./ settings.oversample ;
    settings.size = settings.size .* settings.oversample ;
    switch settings.type
        case 'speckle'
            settings = evaluateFields (settings, scope, {'rms', 'correlation_length', 'slope_1', 'slope_2', 'option', 'seed'}, ...
                                                        {[],    [],                   0 ,        -inf,      '',        ''}) ;
            rng(settings.seed) ;
            [psd, f] = getPSD('CUTOFF-ISO', [], settings.rms, 1/settings.correlation_length, settings.slope_1, settings.slope_2) ;
            psd = [0,psd] ; f = [0,f] ;
            mask = getPSD('ISO-REAL', settings.size, settings.pixel_size, f, psd, settings.option) ;
            mask = downsample (mask, settings.oversample) ;
        case 'gaussian'
            settings = evaluateFields (settings, scope, {'sigma', 'integrated', 'offset_x', 'offset_y', 'sigma_x', 'sigma_y', 'peak'}, ...
                                                        {[],      1,            0,          0,          '',        '',        ''}) ;
            mask_size = settings.size ; if length(mask_size) == 1, mask_size = [mask_size, mask_size] ; end
            if isempty(settings.sigma_x), settings.sigma_x = settings.sigma ; end
            if isempty(settings.sigma_y), settings.sigma_y = settings.sigma ; end
            if ~isempty(settings.peak), settings.integrated = settings.peak * (settings.sigma_x * settings.sigma_y * 2 * pi) ; end
            [x,y] = meshgrid(settings.pixel_size:settings.pixel_size:(mask_size(1)*settings.pixel_size), ...
                             settings.pixel_size:settings.pixel_size:(mask_size(2)*settings.pixel_size)) ;
            settings.offset_x = settings.offset_x + settings.pixel_size * ceil(mask_size(1)/2) ;
            settings.offset_y = settings.offset_y + settings.pixel_size * ceil(mask_size(2)/2) ;
            mask = settings.integrated / (settings.sigma_x * settings.sigma_y * 2 * pi) * exp(-((x-settings.offset_x).^2 / settings.sigma_x^2 + (y-settings.offset_y).^2 / settings.sigma_y^2)/2) ;
            mask = downsample (mask, settings.oversample) ;
        case 'frequency'
            settings = evaluateFields (settings, scope, {'f', 'amplitude', 'phase', 'option'}, ...
                                                        {[],  1,           0,       'sin'}) ;
            mask_size = settings.size ; if length(mask_size) == 1, mask_size = [mask_size, mask_size] ; end
            f = settings.f ; if length(f) == 1, f = [f, 0] ; end
            [x,y] = meshgrid(settings.pixel_size:settings.pixel_size:(mask_size(1)*settings.pixel_size), ...
                             settings.pixel_size:settings.pixel_size:(mask_size(2)*settings.pixel_size)) ;
            x = x - settings.pixel_size * mask_size(1) / 2 ;
            y = y - settings.pixel_size * mask_size(2) / 2 ;
            if ischar(settings.phase) && strcmp(settings.phase,'rand')
                rng(settings.seed) ;
                settings.phase = rand(1) * 2*pi ;
            end
            switch settings.option
                case 'sin'
                    mask = settings.amplitude * sin(2*pi*(f(1)*x+f(2)*y)+settings.phase) ;
                case 'cos'
                    mask = settings.amplitude * cos(2*pi*(f(1)*x+f(2)*y)+settings.phase) ;
                case 'exp'
                    mask = settings.amplitude * exp(2i*pi*(f(1)*x+f(2)*y)+settings.phase) ;
                case 'rect'
                    mask = settings.amplitude * ( cos(2*pi*(f(1)*x+f(2)*y)+settings.phase+eps) > 0 ) ;
                otherwise
                    error ('Invalid option provided for frequency object.') ;
            end
            mask = downsample (mask, settings.oversample) ;
        case 'planewave'
            %this is a phase ramp
            settings = evaluateFields (settings, scope, {'wavelength', 'theta', 'f'}, ...
                                                        {1, 0,[]}) ;
            mask_size = settings.size ; if length(mask_size) == 1, mask_size = [mask_size, mask_size] ; end
            [x,y] = meshgrid(settings.pixel_size:settings.pixel_size:(mask_size(1)*settings.pixel_size), ...
                             settings.pixel_size:settings.pixel_size:(mask_size(2)*settings.pixel_size)) ;
            mask = exp(1i * 2*pi * ( sin(settings.theta(1)) .* x ) / settings.wavelength) ;
        case 'real'
            settings = evaluateFields (settings, scope, {'real', 'imag'}, ...
                                                        {'',     ''}, ...
                                                        {'real', 'imag'}) ;
            mask = 0 ;
            if ~isempty(settings.real), mask = mask + settings.real ; end
            if ~isempty(settings.imag), mask = mask + 1i*settings.imag ; end
        case 'phase'
            settings = evaluateFields (settings, scope, {'phase', 'amplitude'}, ...
                                                        {'',      ''}, ...
                                                        {'phase', 'amplitude'}) ;
            mask = 1 ;
            if ~isempty(settings.amplitude), mask = mask .* settings.amplitude ; end
            if ~isempty(settings.phase), mask = mask .* exp(1i*settings.phase) ; end
        case 'field'
            settings = evaluateFields (settings, scope, {'field'}, ...
                                                        {''}, ...
                                                        {'field'}) ;

            mask = settings.field ;
        case 'aberration'
            settings = evaluateFields (settings, scope, {'field', 'wavelength'}, ...
                                                        {'',      ''}, ...
                                                        {'field', 'wavelength'}) ;
            PF = getPupil (settings, scope) ;
            settings.pixel_size = settings.pixel_size .* settings.oversample ; %this should not apply
            fx = ((-size(settings.field,1)/2):(size(settings.field,1)/2-1)) / (size(settings.field,1)*settings.pixel_size) * settings.wavelength ;
            fy = ((-size(settings.field,2)/2):(size(settings.field,2)/2-1)) / (size(settings.field,2)*settings.pixel_size) * settings.wavelength ;
            [fx,fy] = ndgrid(fx,fy) ;
            mask = ifft2(ifftshift(fftshift(fft2(settings.field)) .* PF(fx,fy))) ;
        otherwise
            error ('No valid objectfield mode.') ;
    end
end

%% Attribute Handling
function attr = getAttribute (value_in, settings, scope)
    % This function will take a particular value in the xml file and
    % convert it into the appropriate function.
    unit_names =  {'%',  'k', 'u',  'n',  'p',   'km', 'mm', 'um', 'nm', 'pm',  'deg',  'rad', 'px', 'pi', 'f0', 'fx', 'fy','fr'} ;
    unit_values = {0.01, 1e3, 1e-6, 1e-9, 1e-12, 1e3,  1e-3, 1e-6, 1e-9, 1e-12, pi/180, 1, '#pixel_size', pi, '(1/(#pixel_size*#size))', 'fourierFrequency(#size,#pixel_size,''x'')', 'fourierFrequency(#size,#pixel_size,''y'')', 'fourierFrequency(#size,#pixel_size,''r'')'} ;
    
    %handle some common cases to avoid str2func call
    number_var = regexp(value_in,['^\s*(?<number>[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?|[Ii][Nn][Ff]|[Nn][Aa][Nn])\s*$'],'names') ;
    text_var = regexp(value_in,'^\s*(?<text>[A-Za-z]+\w*)\s*$','names') ;
    if length(number_var) == 1
        attr = str2double(number_var.number) ;
    elseif length(text_var) == 1
        attr = text_var.text ;
    else
        value = value_in ;
        if value(1) == '='
            value = value(2:end) ;
        else
            for i=1:length (unit_names)
                value = regexprep(value, ['(^|[ \)\]-+*/])([^A-Za-z@#$*]+)' unit_names{i} '(?=(\W+|$))'], ['$1$2*' num2str(unit_values{i},8) ' ']) ;
            end
            value = regexprep(value,  '(^\s*|[^A-Za-z0-9_@#$ \)*.\])([^0-9_\[@#$\(\)\]\[ {}-]+[^@#$\(\)\]\[]*)(?=\W|\s*$)(?!\s*\()', '$1''$2''') ;
        end
        value = iregexprep(value, '(\W+|^)#([A-Za-z]+\w*)\s*=\s*{([^}]*)}', '$1attribute_settingVariable(settings,scope,''$2'',$3)') ;
        value = iregexprep(value, '(\W+|^)#([A-Za-z]+\w*)\s*=\s*(.*)', '$1attribute_settingVariable(settings,scope,''$2'',$3)') ;
        value = iregexprep(value, '(\W+|^)#([A-Za-z]+\w*)', '$1attribute_settingVariable(settings,scope,''$2'')') ;
        value = iregexprep(value, '(\W+|^)\$([A-Za-z]+\w*)\s*=\s*{([^}]*)}', '$1attribute_fileVariable(settings,scope,''$2'',$3)') ;
        value = iregexprep(value, '(\W+|^)\$([A-Za-z]+\w*)\s*=\s*(.*)', '$1attribute_fileVariable(settings,scope,''$2'',$3)') ;
        value = iregexprep(value, '(\W+|^)\$([A-Za-z]+\w*)', '$1attribute_fileVariable(settings,scope,''$2'')') ;
        value = iregexprep(value, '(\W+|^)@([A-Za-z]+\w*)\s*=\s*{([^}]*)}', '$1attribute_paramVariable(settings,scope,''$2'',$3)') ;
        value = iregexprep(value, '(\W+|^)@([A-Za-z]+\w*)\s*=\s*(.*)', '$1attribute_paramVariable(settings,scope,''$2'',$3)') ;
        value = iregexprep(value, '(\W+|^)@([A-Za-z]+\w*)', '$1attribute_paramVariable(settings,scope,''$2'')') ;
        try
            fn = str2func (['@(settings,scope,attribute_paramVariable,attribute_settingVariable,attribute_fileVariable)' value]) ;
            attr = @(in_settings,in_scope)fn(mergeStruct(in_settings,settings),[in_scope,scope],@attribute_paramVariable,@attribute_settingVariable,@attribute_fileVariable) ;
        catch e %#ok<NASGU>
            error ('Invalid attribute value: %s ---> %s', value_in, value) ;
        end
    end
end
function value = attribute_settingVariable (setting, scope, var, default)
    persistent setting_stack ;
    if isfield(setting, var)
        value = setting.(var) ;
    elseif exist('default', 'var')
        value = default ;
    else
        error ('Setting variable %s not defined', var) ;
    end
    if strcmp(class(value),'function_handle')
        if sum(strcmp(setting_stack, var)) > 0, error ('Recursive setting reference: %s', var) ; end
        setting_stack = [setting_stack, {var}] ;
        value = value(setting,scope) ;
        setting_stack = setting_stack(~strcmp(setting_stack,var)) ;
    end
end
function value = attribute_fileVariable (setting, scope, field, default)
    if ~isfield(setting,'file'), error ('File setting not provided for file variable.') ; end
    if ~isfield(setting,'path')
        path = '' ;
    elseif strcmp(class(setting.path),'function_handle')
        path = setting.path(setting,scope) ;
    else
        path = setting.path ;
    end
    if strcmp(class(setting.file),'function_handle')
        file = [path, '/', setting.file(setting,scope)] ;
    else
        file = [path, '/', setting.file] ;
    end
    if ~exist(file,'file')
        if exist('default','var'), value = default ; return ;
        else error ('File does not exist and no default provided.') ; end
    end
    value = load(file,'-mat',field) ;
    if ~isfield(value, field)
        if exist('default','var'), value = default ; return ;
        else error ('Field not present in file and no default provided: %s', field) ; end
    end
    value = value.(field) ;
end
function value = attribute_paramVariable (setting, scope, field, default)
    persistent store param_stack ;
    if nargin == 0
        store = struct() ;
        param_stack = [] ;
        value = [] ;
    elseif ischar(setting) && strcmp(setting,'set')
        name = strrep(field, '.', '_') ;
        store.(['a' scope '_' name]) = default ;
    else
        scope = unique(scope) ;
        %set variable mode
        name = strrep(field, '.', '_') ;
        for i=1:length(scope)
            scope_name = ['a' scope{i} '_' name] ;
            if isfield(store, scope_name)
                value = store.(scope_name) ;
                if strcmp(class(value),'function_handle')
                    if sum(strcmp(param_stack, scope_name)) > 0
                        error ('Recursive param reference: %s', field) ; 
                    end
                    param_stack = [param_stack, {scope_name}] ; %#ok<AGROW>
                    value = value(setting,scope) ;
                    param_stack = param_stack(~strcmp(param_stack,scope_name)) ;
                end
                return ;
            end
        end
        if exist('default','var')
            value = default ;
            return ;
        end
        error ('Reference variable not defined in scope: %s', field) ;
    end
end

%% Helpers
function id = getId (clear)  %#ok<INUSD>
    persistent last_id ;
    if isempty(last_id) || nargin == 1, last_id = 0 ; end
    last_id = last_id + 1 ;
    id = ['I' num2str(last_id)] ;
end
function [str, err] = requiredFields (str, required, defaults)
    err = {} ;
    for i=1:length(required)
        if ~isfield(str,required{i}) ;
            err{length(err)+1} = required{i} ; %#ok<AGROW>
        end
    end
    if nargin == 3
        fn = fieldnames(defaults) ;
        for i=1:length(fn)
            if ~isfield(str,fn{i})
                str.(fn{i}) = defaults.(fn{i}) ;
            end
        end
    end
    if nargout < 2 && ~isempty(required) && ~isempty(err)
        error (sprintf('Required field (%s) not specified.', err{1})) ;
    end
end
function str_new = iregexprep (str_new, exp, rep)
    str = [] ;
    while ~strcmp(str_new,str)
        str = str_new ;
        str_new = regexprep(str,exp,rep,'once') ;
    end
end
function str = mergeStruct (str, add)
    %overwrites fields in first argument with fields in second
    for fn=fieldnames(add)', str.(fn{1}) = add.(fn{1}) ; end
end
function settings = evaluateFields (settings, scope, fields, defaults, rm_fields)
    pass_settings = settings ;
    if exist('rm_fields','var')
        if isequal(rm_fields,'*')
            settings = struct() ;
            for i=1:length(fields)
                if isfield(pass_settings,fields{i}), settings.(fields{i}) = pass_settings.(fields{i}) ; end
            end
        else
            for i=1:length(rm_fields)
                if isfield(pass_settings,rm_fields{i}), pass_settings = rmfield(pass_settings,rm_fields{i}) ; end
            end
        end
    end
    
    if ~exist('fields','var'), fields = fieldnames (settings) ; end
    for i=1:length(fields)
        if ~isfield(settings,fields{i})
            if exist('defaults','var'), settings.(fields{i}) = defaults{i} ; end
            continue ;
        end
        value = settings.(fields{i}) ;
        if strcmp(class(value),'function_handle')
            value = value(pass_settings,scope) ;
        end
        settings.(fields{i}) = value ;
    end
end
function settings = removeFields (settings, fields)
    for i=1:length(fields)
        if isfield(settings,fields{i})
            settings = rmfield (settings,fields{i}) ;
        end
    end
end
function P = fillpole (x, y, radius, arc_start, arc_end, mode)
% This function returns an array of size size(x) where 
%   x.^2 + y.^2 < radius^2 but has at least one point
% If mode='normalized' then the result is normalized so that the points sum to 1.
% If the radius is so small that it lies between the grid points
%   then it is snapped to the nearest grid point.
% arc_start and arc_end turn the circle into an arc with angles measured
% from the x axis.

P = (x.^2 + y.^2 < radius^2) ;

if ~any(P)
    [~, I] = min(reshape(x.^2 + y.^2,1,[])) ;
    P(I) = 1 ;
end

if (exist('arc_start','var') && ~isempty(arc_start)) || ...
   (exist('arc_end','var') && ~isempty(arc_end))
    if ~exist('arc_end','var'), arc_end = 2*pi ; end
    if ~exist('arc_start','var'), arc_start = 0 ; end
    while arc_end < arc_start, arc_end = arc_end + 2*pi ; end
    arc_mask = false(size(P)) ;
    if arc_start ~= arc_end
        tx = atan2(y,x) ;
        for i=[-1,0,1]
            arc_mask = arc_mask | ( ...
                (tx + i*2*pi) >=  arc_start & (tx + i*2*pi) <= arc_end ) ;
        end
    end
    P = P & arc_mask ;
end

if ischar(mode)
    switch mode
        case 'normalized'
            P = P / sum(P(:)) ;
    end
elseif strcmp(class(mode),'function_handle')
    P = mode(x,y) .* P ;
elseif ~isempty(mode)
    P = P .* mode ;
end
end
