function local_paths = load_local_paths()
%LOAD_LOCAL_PATHS Carica eventuali path locali da custom_files/local_paths.m.
%
%   local_paths = LOAD_LOCAL_PATHS() restituisce una struct con i path locali.
%   Se il file local_paths.m non esiste, ritorna struct vuota.

    local_paths = struct();

    % Preferisci il file local_paths.m nella stessa cartella di questa funzione,
    % così funziona anche quando la current directory non è custom_files.
    this_dir = fileparts(mfilename('fullpath'));
    candidate_file = fullfile(this_dir, 'local_paths.m');

    if exist(candidate_file, 'file') ~= 2
        return;
    end

    % Esegui la funzione locale senza dipendere dall'ordine del MATLAB path.
    already_on_path = ~isempty(strfind(path, this_dir));
    if ~already_on_path
        addpath(this_dir, '-begin');
        cleanup_obj = onCleanup(@() rmpath(this_dir)); %#ok<NASGU>
    end

    loaded = feval(str2func('local_paths'));
    if ~isstruct(loaded)
        error('local_paths.m deve restituire una struct.');
    end

    local_paths = loaded;
end
