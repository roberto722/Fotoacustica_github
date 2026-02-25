function results = run_lambda_sweep_residuals(params, model, reg_methods, lambdas, dataset_name)
%RUN_LAMBDA_SWEEP_RESIDUALS Execute lambda sweep and collect residual metrics.
%   Shared utility used by residual scripts to avoid duplicated logic.

    results = initialize_results(reg_methods, params.voc_ids, lambdas);

    for i = 1:numel(lambdas)
        params.lambda_shearlet = str2double(lambdas(i));
        params.lambda_TV = str2double(lambdas(i));

        [recs, ~, lCurveErrImg, lCurveErrReg] = reconstruct_from_VOC_residuals( ...
            dataset_name, model, params, reg_methods, true);

        recs_names = fieldnames(recs);
        for id = 1:numel(params.voc_ids)
            for j = 1:numel(recs_names)
                recs_name = recs_names{j};
                if recs_name ~= "BACKPROJECTION"
                    results.(recs_name){id}(i, :) = {lambdas(i), lCurveErrImg.(recs_name), lCurveErrReg.(recs_name)};
                end
            end
        end
    end
end

function results = initialize_results(reg_methods, image_ids, lambdas)
    results = struct();
    for a = 1:numel(reg_methods)
        results.(reg_methods(a)) = cell(1, numel(image_ids));
        for b = 1:numel(image_ids)
            results.(reg_methods(a)){b} = table('Size', [numel(lambdas), 3], ...
                'VariableTypes', ["string", "double", "double"], ...
                'VariableNames', ["Lambda", "lCurveErrImg_" + string(image_ids(b)), "lCurveErrReg_" + string(image_ids(b))]);
        end
    end
end
