function [headerInfo, imgOut] = Norpix2MATLAB(fileName, showImg)
% Open n-bit Norpix image sequence in MATLAB
%
% ARGUMENTS:
%    INPUTS:
%    FILENAME: String name/path of image
%    SHOWIMG: Flag to display each image read (DEFAULT: False)
%    OUTPUTS:
%    HEADER: A structure containing Norpix version, header size (bytes),
%            description, image width, image height, image bit depth, image
%            bit depth (real), image size (bytes), image format, number of
%            allocated frames, origin, true image size, and frame rate.
%            (The user is referred to the manual for discussions of these
%            values.) Also returns the timestamp of each frame, in
%            Coordinated Universal Time (UTC).
%    IMGOUT: an ImageHeight x ImageWidth x AllocatedFrames image stack.
%
% SYNTAX:
% [header, imgOut] = Norpix2MATLAB(fileName, showImg)
%    Creates output variable HEADER, containing all header information and
%    image time-stamps, and IMGOUT, containing the image reconstructed from
%    file FILENAME.
% header = ...Norpix2MATLAB(...);
%    Returns only the header.
% [~,imgOut] = Norpix2MATLAB(...)
%    Returns only the image.
%
% EXAMPLE:
%     [header,img] = Norpix2MATLAB('640x480_14bit_10frames.seq',1)
%
% Written 04/08/08 by Brett Shoelson, PhD
% v.1.0
% brett.shoelson@mathworks.com
% Modifications:
% v. 2.0
% 12/01/10       Massive overhaul, to support 12-, 14-, and 16-bit images,
%                and to capture header information and timestamps. Also,
%                the syntax has changed: the user no longer inputs bit depth
%                or image size; those values are read from the header.

if nargin < 1
    [f,p] = uigetfile({'*.seq'},'Choose SEQ file','Multiselect','off');
    if f==0 % user hit cancel
        return
    end
    fileName = fullfile(p,f);
    showImg = false;
elseif nargin < 2
    showImg = false;
end


% Open file for reading
fid = fopen(fileName,'r','b');

% Both sequences are 640x480, 5 images each.
% The 12 bit sequence is little endian, aligned on 16 bit.
% The header of the sequence is 1024 bytes long.
% After that you have the first image that has
%
% 640 x 480 = 307200 bytes for the 8 bit sequence:
% or
% 640 x 480 x 2 = 614400 bytes for the 12 bit sequence:
%
% After each image there are timestampBytes bytes that contain timestamp information.
%
% This image size, together with the timestampBytes bytes for the timestamp, are then aligned on 512 bytes.
%
% So the beginning of the second image will be at
% 1024 + (307200 + timestampBytes + 506) for the 8 bit
% or
% 1024 + (614400 + timestampBytes + 506) for the 12 bit


% HEADER INFORMATION
% OBF = {Offset (bytes), Bytes, Format}
endianType = 'ieee-le';

% Read header

OFB = {28,1,'long'};
fseek(fid,OFB{1}, 'bof');
headerInfo.Version = fread(fid, OFB{2}, OFB{3}, endianType);
% headerInfo.Version

%
OFB = {32,4/4,'long'};
fseek(fid,OFB{1}, 'bof');
headerInfo.HeaderSize = fread(fid,OFB{2},OFB{3}, endianType);
% headerInfo.HeaderSize

%
OFB = {592,1,'long'};
fseek(fid,OFB{1}, 'bof');
DescriptionFormat = fread(fid,OFB{2},OFB{3}, endianType)';
OFB = {36,512,'ushort'};
fseek(fid,OFB{1}, 'bof');
headerInfo.Description = fread(fid,OFB{2},OFB{3}, endianType)';
if DescriptionFormat == 0 %#ok Unicode
    headerInfo.Description = native2unicode(headerInfo.Description);
elseif DescriptionFormat == 1 %#ok ASCII
    headerInfo.Description = char(headerInfo.Description);
end
% headerInfo.Description

%
OFB = {548,24,'uint32'};
fseek(fid,OFB{1}, 'bof');
tmp = fread(fid,OFB{2},OFB{3}, 0, endianType);
headerInfo.ImageWidth = tmp(1);
headerInfo.ImageHeight = tmp(2);
headerInfo.ImageBitDepth = tmp(3);
headerInfo.ImageBitDepthReal = tmp(4);
headerInfo.ImageSizeBytes = tmp(5);
vals = [0,100,101,200:100:900];
fmts = {'Unknown','Monochrome','Raw Bayer','BGR','Planar','RGB',...
    'BGRx', 'YUV422', 'UVY422', 'UVY411', 'UVY444'};
headerInfo.ImageFormat = fmts{vals == tmp(6)};

%
OFB = {572,1,'ushort'};
fseek(fid,OFB{1}, 'bof');
headerInfo.AllocatedFrames = fread(fid,OFB{2},OFB{3}, endianType);
% headerInfo.AllocatedFrames

%
OFB = {576,1,'ushort'};
fseek(fid,OFB{1}, 'bof');
headerInfo.Origin = fread(fid,OFB{2},OFB{3}, endianType);
% headerInfo.Origin

%
OFB = {580,1,'ulong'};
fseek(fid,OFB{1}, 'bof');
headerInfo.TrueImageSize = fread(fid,OFB{2},OFB{3}, endianType);
% headerInfo.TrueImageSize

%
OFB = {584,1,'double'};
fseek(fid,OFB{1}, 'bof');
headerInfo.FrameRate = fread(fid,OFB{2},OFB{3}, endianType);
% headerInfo.FrameRate

if nargout > 1
    bitstr = '';
    
    % PREALLOCATION
    imSize = [headerInfo.ImageWidth,headerInfo.ImageHeight];
    imgOut = zeros(imSize(2),imSize(1),headerInfo.AllocatedFrames);
    switch headerInfo.ImageBitDepthReal
        case 8
            bitstr = 'uint8';
        case {12,14,16}
            bitstr = 'uint16';
    end
    if isempty(bitstr)
        error('Unsupported bit depth');
    end
    
    nread = 0;
    while 1
        fseek(fid, 1024 + nread * headerInfo.TrueImageSize, 'bof');
        tmp = fread(fid, headerInfo.ImageWidth * headerInfo.ImageHeight, bitstr, endianType);
        % max(tmp(:))
        if isempty(tmp)
            break
        end
        imgOut(:,:,nread+1) = permute(reshape(tmp,imSize(1),imSize(2),[]),[2,1,3]);
        tmp = fread(fid, 1, 'int32', endianType);
        tmp2 = fread(fid,2,'uint16', endianType);
        tmp = tmp/86400 + datenum(1970,1,1);
        headerInfo.timestamp{nread + 1} = [datestr(tmp) ':' num2str(tmp2(1)),num2str(tmp2(2))];
        %headerInfo.timestamp{nread + 1}

        if showImg
            if nread == 0
                % first iteration
                figure('numbertitle','off','name',fileName,'color','k');
                himg = imshow(imgOut(:,:,nread+1),[]);
            else
                set(himg,'cdata',imgOut(:,:,nread+1));
            end
            shg;
        end
        nread = nread + 1;
    end
    
end

fclose(fid);