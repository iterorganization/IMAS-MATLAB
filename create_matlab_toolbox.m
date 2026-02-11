function create_matlab_toolbox(installDir, outputDir, version, ddVersion)
% CREATE_MATLAB_TOOLBOX Package IMAS-MATLAB as a MATLAB toolbox
% 
% Arguments:
%   installDir - Directory containing installed IMAS-MATLAB files
%   outputDir  - Directory where .mltbx file will be created
%   version    - Version string (e.g., '5.5.0')
%   ddVersion  - Data Dictionary version (e.g., '4.1.0')

if nargin < 4
    error('Usage: create_matlab_toolbox(installDir, outputDir, version, ddVersion)');
end

% Detect platform
if ispc
    platform = 'win64';
elseif ismac
    platform = 'macos';
elseif isunix
    platform = 'linux64';
else
    platform = 'unknown';
end

% Create full version string
fullVersionName = sprintf('IMAS-MATLAB/%s-DD-%s-%s', version, ddVersion, platform);

fprintf('Creating %s...\n', fullVersionName);

% Validate input directory
toolboxSource = fullfile(installDir, 'toolbox');
if ~exist(toolboxSource, 'dir')
    error('Toolbox directory not found: %s', toolboxSource);
end

% Create temporary packaging directory
packDir = fullfile(outputDir, 'toolbox_temp');
if exist(packDir, 'dir')
    rmdir(packDir, 's');
end
mkdir(packDir);

try
    % Copy toolbox contents
    fprintf('  Copying toolbox files...\n');
    copyfile(fullfile(toolboxSource, '*'), packDir);
    
    % Create startup script
    fprintf('  Creating startup script...\n');
    create_startup_script(packDir, version, ddVersion, platform);
    
    % Create README
    fprintf('  Creating README...\n');
    create_readme(packDir, version, ddVersion, platform);
    
    % Configure toolbox metadata
    fprintf('  Configuring toolbox metadata...\n');
    % Create a valid identifier (alphanumeric and hyphens only)
    toolboxId = sprintf('IMAS-MATLAB-%s', strrep(version, '.', '-'));
    opts = matlab.addons.toolbox.ToolboxOptions(packDir, toolboxId);
    
    opts.ToolboxName = 'IMAS-MATLAB';
    opts.ToolboxVersion = version;
    opts.AuthorName = 'ITER Organization';
    opts.Summary = sprintf('MATLAB interface for IMAS Access Layer - %s', fullVersionName);
    opts.Description = sprintf(['High Level Interface for accessing IMAS fusion simulation data from MATLAB. ', ...
                        '%s includes all MEX files, MATLAB functions, and required ', ...
                        'dependencies for Data Dictionary %s. Built for %s.'], ...
                        fullVersionName, ddVersion, platform);
    
    % Add all files from package directory
    opts.ToolboxFiles = {packDir};
    opts.ToolboxMatlabPath = {packDir};
    
    % Set output file with full version name including platform
    outputFileName = sprintf('IMAS-MATLAB_%s-DD-%s-%s.mltbx', version, ddVersion, platform);
    outputFile = fullfile(outputDir, outputFileName);
    opts.OutputFile = outputFile;
    
    % Package the toolbox
    fprintf('  Building toolbox package...\n');
    matlab.addons.toolbox.packageToolbox(opts);
    
    fprintf('\n========================================\n');
    fprintf('✓ Toolbox created successfully!\n');
    fprintf('========================================\n\n');
    fprintf('Output file: %s\n', outputFile);
    
    if exist(outputFile, 'file')
        fileInfo = dir(outputFile);
        fprintf('File size: %.2f MB\n', fileInfo.bytes / 1024 / 1024);
    end
    
    fprintf('\n--- Installation Instructions ---\n');
    fprintf('1. Double-click: %s\n', outputFile);
    fprintf('   OR\n');
    fprintf('2. Run: matlab.addons.install(''%s'')\n', outputFile);
    
    % Clean up temp directory
    fprintf('\n  Cleaning up temporary files...\n');
    rmdir(packDir, 's');
    fprintf('Done!\n');
    
catch ME
    fprintf('\n✗ Failed to create toolbox:\n');
    fprintf('  %s\n\n', ME.message);
    fprintf('Temporary files kept in: %s\n', packDir);
    rethrow(ME);
end

end

function create_startup_script(packDir, version, ddVersion, platform)
% Create the toolbox startup script

fullVersionName = sprintf('IMAS-MATLAB/%s-DD-%s-%s', version, ddVersion, platform);
startupFile = fullfile(packDir, 'imas_toolbox_startup.m');
fid = fopen(startupFile, 'w');

fprintf(fid, 'function imas_toolbox_startup()\n');
fprintf(fid, '%% IMAS_TOOLBOX_STARTUP Initialize IMAS-MATLAB toolbox\n');
fprintf(fid, '%% Auto-generated startup script for %s\n\n', fullVersionName);
fprintf(fid, '    toolboxRoot = fileparts(mfilename(''fullpath''));\n\n');
fprintf(fid, '    %% Add to path\n');
fprintf(fid, '    if ~contains(path, toolboxRoot)\n');
fprintf(fid, '        addpath(toolboxRoot);\n');
fprintf(fid, '    end\n\n');
fprintf(fid, '    %% On Windows, add DLLs to system PATH\n');
fprintf(fid, '    if ispc\n');
fprintf(fid, '        currentPath = getenv(''PATH'');\n');
fprintf(fid, '        if ~contains(currentPath, toolboxRoot)\n');
fprintf(fid, '            setenv(''PATH'', [toolboxRoot pathsep currentPath]);\n');
fprintf(fid, '        end\n');
fprintf(fid, '    end\n\n');
fprintf(fid, '    fprintf(''%s loaded successfully\\n'');\n\n', fullVersionName);
fprintf(fid, '    %% Display version information\n');
fprintf(fid, '    try\n');
fprintf(fid, '        v = imas_versions();\n');
fprintf(fid, '        fprintf(''Access Layer: %%s | Data Dictionary: %%s\\n'', ...\n');
fprintf(fid, '                v.access_layer, v.data_dictionary);\n');
fprintf(fid, '    catch ME\n');
fprintf(fid, '        warning(''Could not retrieve version information: %%s'', ME.message);\n');
fprintf(fid, '    end\n');
fprintf(fid, 'end\n');

fclose(fid);
end

function create_readme(packDir, version, ddVersion, platform)
% Create README file

fullVersionName = sprintf('IMAS-MATLAB/%s-DD-%s-%s', version, ddVersion, platform);
readmeFile = fullfile(packDir, 'README.md');
fid = fopen(readmeFile, 'w');

fprintf(fid, '# %s\n\n', fullVersionName);
fprintf(fid, 'MATLAB High Level Interface to the IMAS Access Layer.\n\n');
fprintf(fid, '**Platform:** %s\n\n', platform);
fprintf(fid, '## Installation\n\n');
fprintf(fid, 'This toolbox is installed via MATLAB Add-On Manager.\n\n');
fprintf(fid, '## Getting Started\n\n');
fprintf(fid, 'Initialize the toolbox (automatically done on installation):\n');
fprintf(fid, '```matlab\n');
fprintf(fid, 'imas_toolbox_startup()\n');
fprintf(fid, '```\n\n');
fprintf(fid, 'Verify installation:\n');
fprintf(fid, '```matlab\n');
fprintf(fid, 'v = imas_versions()\n');
fprintf(fid, '```\n\n');
fprintf(fid, '## Basic Usage\n\n');
fprintf(fid, '### Opening and Reading Data\n\n');
fprintf(fid, '```matlab\n');
fprintf(fid, '%% Open IMAS database using URI\n');
fprintf(fid, 'uri = ''imas:hdf5?path=./test_db'';\n');
fprintf(fid, 'ctx = imas_open(uri, 43);\n');
fprintf(fid, 'if ctx < 0\n');
fprintf(fid, '    error(''Unable to open pulse'');\n');
fprintf(fid, 'end\n\n');
fprintf(fid, '%% Get IDS data\n');
fprintf(fid, 'm = ids_get(ctx, ''magnetics'');\n\n');
fprintf(fid, '%% Display data\n');
fprintf(fid, 'disp(m.time);\n');
fprintf(fid, 'disp(m.flux_loop{1}.flux.data);\n\n');
fprintf(fid, '%% Close connection\n');
fprintf(fid, 'imas_close(ctx);\n');
fprintf(fid, '```\n\n');
fprintf(fid, '### Writing Data\n\n');
fprintf(fid, '```matlab\n');
fprintf(fid, '%% Open/create pulse\n');
fprintf(fid, 'uri = ''imas:hdf5?path=./test_db'';\n');
fprintf(fid, 'ctx = imas_open(uri, 43);\n');
fprintf(fid, 'if ctx < 0\n');
fprintf(fid, '    error(''Unable to open pulse'');\n');
fprintf(fid, 'end\n\n');
fprintf(fid, '%% Generate IDS structure\n');
fprintf(fid, 'm = ids_gen(''magnetics'');\n\n');
fprintf(fid, '%% Populate data\n');
fprintf(fid, 'm.ids_properties.homogeneous_time = 1;\n');
fprintf(fid, 'm.flux_loop{1}.flux.data(1) = 10.0;\n');
fprintf(fid, 'm.flux_loop{1}.flux.data(2) = 20.0;\n');
fprintf(fid, 'm.time(1) = 2.0;\n');
fprintf(fid, 'm.time(2) = 5.0;\n\n');
fprintf(fid, '%% Write to database\n');
fprintf(fid, 'ids_put(ctx, ''magnetics'', m);\n\n');
fprintf(fid, '%% Close\n');
fprintf(fid, 'imas_close(ctx);\n');
fprintf(fid, '```\n\n');
fprintf(fid, '## Documentation\n\n');
fprintf(fid, 'For complete documentation, visit: https://imas-matlab.readthedocs.io/\n\n');
fprintf(fid, '## License\n\n');
fprintf(fid, 'See LICENSE.txt for license information.\n');

fclose(fid);
end
