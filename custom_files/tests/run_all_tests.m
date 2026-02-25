function results = run_all_tests()
%RUN_ALL_TESTS Esegue i test automatici minimi della repository.

    current_dir = fileparts(mfilename('fullpath'));
    repo_custom_files = fileparts(current_dir);
    addpath(repo_custom_files);

    results = runtests(current_dir, 'IncludeSubfolders', true);
    disp(table(results));
end
