function tests = test_generation_config_aliases
%TEST_GENERATION_CONFIG_ALIASES Smoke test su alias naming config.
    tests = functiontests(localfunctions);
end

function testNormalizeVocAliases(testCase)
    params = struct('SINO_id_imgs', ["img1", "img2"]);
    params = normalize_generation_params_names(params);

    verifyTrue(testCase, isfield(params, 'voc_ids'));
    verifyEqual(testCase, string(params.voc_ids), ["img1", "img2"]);
    verifyEqual(testCase, string(params.VOC_id_imgs), ["img1", "img2"]);
end

function testNormalizeHdf5Aliases(testCase)
    params = struct('HDF5_ids', {"sample1"});
    params = normalize_generation_params_names(params);

    verifyTrue(testCase, isfield(params, 'hdf5_ids'));
    verifyEqual(testCase, string(params.hdf5_ids), "sample1");
end

function testValidateConfigAcceptsLegacyAlias(testCase)
    config = struct();
    config.profile = "voc";
    config.rec_toolbox_path = "dummy_toolbox";
    config.source = struct('type', "voc", 'dataset_name', "VOC2012");
    config.params = struct('SINO_id_imgs', ["img1"]);

    verifyWarningFree(testCase, @() validate_generation_config(config));
end
