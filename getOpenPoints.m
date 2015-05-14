%% get what points never happened to be played
function boolOpenPoints = getOpenPoints(dominoes)

    boolOpenPoints = [0 0 0 0];
    [size_a size_b] = size(dominoes.freePointsTips{1,1});
    if size_a ~= 0 && size_b ~= 0
        for x = 1:1:4
            if dominoes.freePointsTips{1,x}(1) == dominoes.initialTile(1) && ...
                dominoes.freePointsTips{1,x}(2) == dominoes.initialTile(2)
                boolOpenPoints(x) = 1;
            else boolOpenPoints(x) = 0;
            end;
        end;
    end;

end