function evalPoints = applyStrategicHeuristic(side1, side2, direction, ...
    dominoes)
    
    
    boolOpenPoints = getOpenPoints(dominoes);
    
    
    if (boolOpenPoints(2) == 1 || boolOpenPoints(4) == 1) && ...
            (direction == 1 || direction == 3)
        evalPoints = -100;
        return
    end;

    [fx fy] = size(dominoes.freeTips);
    
    if fy < 4
        evalPoints = side1 + side2;
    elseif dominoes.freeTips(direction) == side1
        k1 = dominoes.ai_param.k1;
        k2 = dominoes.ai_param.k2;
        k3 = dominoes.ai_param.k3;
        k4 = dominoes.ai_param.k4;
        alphaK = dominoes.ai_param.alphaK;
        betaK = dominoes.ai_param.betaK;
        
        size_hand = 0;
        for x = 1:1:7
            if dominoes.hand_players{dominoes.current_player, x}(1) == -1 && ...
                dominoes.hand_players{dominoes.current_player, x}(1) == -1
                break;
            end;
            size_hand = x;
        end;
        
        %% Points Evaluation
        points_type1 = getPoints(side1, side2, direction, dominoes);
        
        points_typepassing = 0;
        
        points_type5 = 0;
        if size_hand == 1 && side1 == side2
                points_type5 = 20;
        end;
        
        points_evaluation = betaK * (points_type1 + points_typepassing + points_type5);
        
        %% Strategic Evaluation
        evaluation_term1 = k1 * (dominoes.tilesHand{dominoes.current_player, side1+1} + ...
            dominoes.tilesTable(side1+1) + ...
            dominoes.tilesFreeTips(side1+1)); 
        
        evaluation_term2 = k2 * (dominoes.tilesHand{dominoes.current_player, side2+1} +...
            dominoes.tilesTable(side2+1) + dominoes.tilesFreeTips(side2+1));
        
        if size_hand > 3
            sigmaK = 1;
        else
            sigmaK = 0;
        end;
        
        evaluation_term3 = k3 * dominoes.tilesHand{dominoes.current_player, side2+1};
        
        evaluation_term4 = k4 * dominoes.tilesPassing{mod(dominoes.current_player+1, 4)+1,side2+1};
        
        strategic_evaluation = alphaK  *( - evaluation_term1 + evaluation_term2 + ...
            sigmaK * evaluation_term3 - evaluation_term4);
        
        %% Final Evaluation
        evalPoints = strategic_evaluation + points_evaluation;
        
    else 
        evalPoints = -100;
    end

end