function [params fval options last_pop] = runGAExperiments()

load 'lastpopulation.mat'

tic;
options = gaoptimset('UseParallel','always', 'Generations', last_pop);
[params fval exitFlag output last_pop] = ga(@fitnessDominoes,6,[],[],[],[],[],[],[],options);
toc

save 'lastpopulation.mat' 

end