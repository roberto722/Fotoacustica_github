function params = normalize_generation_params_names(params)
%NORMALIZE_GENERATION_PARAMS_NAMES Uniforma i nomi dei campi params con alias retrocompatibili.
%
% Convenzione canonica:
%   - params.voc_ids
%   - params.hdf5_ids
%   - params.forearm_complex_ids
%
% Alias supportati (retrocompatibilita'): VOC_id_imgs, SINO_id_imgs,
% HDF5_ids, ForearmComplex_ids, PRIN_imgs_id.

    if nargin < 1 || ~isstruct(params)
        error('params deve essere una struct.');
    end

    params = resolve_ids_alias(params, 'voc_ids', {'VOC_id_imgs', 'SINO_id_imgs', 'PRIN_imgs_id'});
    params = resolve_ids_alias(params, 'hdf5_ids', {'HDF5_ids'});
    params = resolve_ids_alias(params, 'forearm_complex_ids', {'ForearmComplex_ids'});

    % Esponi alias legacy per mantenere compatibilita' con funzioni esistenti.
    if ~isfield(params, 'VOC_id_imgs')
        params.VOC_id_imgs = params.voc_ids;
    end
    if ~isfield(params, 'SINO_id_imgs')
        params.SINO_id_imgs = params.voc_ids;
    end
    if ~isfield(params, 'PRIN_imgs_id')
        params.PRIN_imgs_id = params.voc_ids;
    end
    if ~isfield(params, 'HDF5_ids')
        params.HDF5_ids = params.hdf5_ids;
    end
    if ~isfield(params, 'ForearmComplex_ids')
        params.ForearmComplex_ids = params.forearm_complex_ids;
    end
end

function params = resolve_ids_alias(params, canonical_name, aliases)
    if isfield(params, canonical_name)
        canonical_value = params.(canonical_name);
        return;
    end

    found_alias = '';
    canonical_value = {};
    for i = 1:numel(aliases)
        alias = aliases{i};
        if isfield(params, alias)
            found_alias = alias;
            canonical_value = params.(alias);
            break;
        end
    end

    if strlength(string(found_alias)) == 0
        canonical_value = {};
    end

    params.(canonical_name) = canonical_value;
end
