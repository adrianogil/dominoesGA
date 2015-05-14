%% Return the number of points that can be done in the move
function points = getPoints(side1, side2, direction, dominoes)
    
    boolOpenPoints = getOpenPoints(dominoes);
    
    points = 0;
    
    if boolOpenPoints == [1 1 1 1]
        points = 0;
    elseif boolOpenPoints(2) == 1 && boolOpenPoints(4) == 0
        points = dominoes.initialTile(1) + dominoes.initialTile(2);
        points = points + dominoes.freeTips(4);
    elseif boolOpenPoints(4) == 1 && boolOpenPoints(2) == 0
        points = dominoes.initialTile(1) + dominoes.initialTile(2);
        points = points + dominoes.freeTips(2);
    else
        for side = 1:1:4
            if side == 1 || side == 3
                if boolOpenPoints(side) == 0
                    points = points + dominoes.freeTips(side);
                end;
            else
                points = points + dominoes.freeTips(side);
            end;
        end;
    end;
    
    % Return just dividers by 5
    if mod(points,5) ~= 0
        points = 0;
    end;

end