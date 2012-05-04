function results = runExperiments(total_experiments, ai_paramvec)

    if nargin == 0
        total_experiments = 100000;
        ai_param.k1 = 0.1;
        ai_param.k2 = 0.1;
        ai_param.k3 = 0.1;
        ai_param.k4 = 0.1;
        ai_param.alphaK = 0.1;
        ai_param.betaK = 0.8;
    else
        ai_param.k1 = ai_paramvec(1);
        ai_param.k2 = ai_paramvec(2);
        ai_param.k3 = ai_paramvec(3);
        ai_param.k4 = ai_paramvec(4);
        ai_param.alphaK = ai_paramvec(5);
        ai_param.betaK = ai_paramvec(6);
    end;
    locked_games = 0;
    team_win = [0 0];
    ai_mode = {0,0,0,1};
    sum_score = 0;
    for x = 1:1:total_experiments
        S = simMatchDominoesIntelligence(ai_mode, ai_param);
        if S.last_player == -1
            locked_games = locked_games + 1;
        else
            team_win(S.winner_team) = team_win(S.winner_team) + 1;
        end;
        sum_score = sum_score + S.score(2);
    end;
    
    medium_score = sum_score / total_experiments;
    
    results.locked_games = locked_games;
    results.team_win = team_win;
    results.total_ai_win = team_win(2);
    results.medium_score = total_experiments;
end