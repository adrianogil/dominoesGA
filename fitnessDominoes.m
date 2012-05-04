function eval = fitnessDominoes(params)

total_experiments = 300;

results = runExperiments(total_experiments, params);

eval = total_experiments - results.total_ai_win;

end