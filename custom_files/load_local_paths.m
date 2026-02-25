function local_paths = load_local_paths()
%LOAD_LOCAL_PATHS Carica eventuali path locali da custom_files/local_paths.m.
%
%   local_paths = LOAD_LOCAL_PATHS() restituisce una struct con i path locali.
%   Se il file local_paths.m non esiste, ritorna struct vuota.

    local_paths = struct();

    if exist('local_paths', 'file') ~= 2
        return;
    end

    loaded = local_paths();
    if ~isstruct(loaded)
        error('local_paths.m deve restituire una struct.');
    end

    local_paths = loaded;
end
