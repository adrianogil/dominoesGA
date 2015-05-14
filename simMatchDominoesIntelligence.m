function results = simMatchDominoesIntelligence(ai_mode, ai_param)

% disp('Start Game');

if nargin  == 0
    dominoes.ai_mode = {1,0,1,0};
    dominoes.ai_param.k1 = 1;
    dominoes.ai_param.k2 = 0.4;
    dominoes.ai_param.k3 = 0.7;
    dominoes.ai_param.k4 = 0.2;
    dominoes.ai_param.alphaK = 0.2;
    dominoes.ai_param.betaK = 0.8;
else
    dominoes.ai_mode = ai_mode;
    dominoes.ai_param = ai_param;
end;

dominoes.boolGameEnd = 0;
dominoes.initDoubleSix = 1;
% Score Position 1: Team 1
% Score Position 2: Team 2
dominoes.score = [0 0];

while dominoes.boolGameEnd ~= 1
    lastTile = [-1 -1];
    dominoes.freeTips = [];
    dominoes.freePointsTips = cell(1,4);
    dominoes.boolMatchEnd = 0;
    dominoes.notPlayed = 0;
    dominoes.initialTile = [-1 -1];
    dominoes.tilesHand = {0,0,0,0,0,0,0;
                          0,0,0,0,0,0,0;
                          0,0,0,0,0,0,0;
                          0,0,0,0,0,0,0;};
    dominoes.tilesPlayed = {0,0,0,0,0,0,0;
                            0,0,0,0,0,0,0;
                            0,0,0,0,0,0,0;
                            0,0,0,0,0,0,0;};
    dominoes.tilesPassing =  {0,0,0,0,0,0,0;
                              0,0,0,0,0,0,0;
                              0,0,0,0,0,0,0;
                              0,0,0,0,0,0,0;};
    dominoes.tilesTable = [0,0,0,0,0,0,0];
    dominoes.tilesFreeTips = [0,0,0,0,0,0,0];

    % 1. Shuffle hands
    dominoes.hand_players = shuffleHands();

    %% 2. Start Match
%     disp('Start Match');
    if dominoes.initDoubleSix == 1
    %   2.1. Discover who has the double six
        dominoes.current_player = 1;
        for p = 1:1:4
            if hasDoubleSix(dominoes.hand_players, p) == 1
                dominoes.current_player = p;
                tile = [6 6];
                lastTile = tile;
                dominoes.initialTile = tile;
                
                % Update internal representation of the world
                dominoes = updateInternalRepresention(tile, -1, dominoes);

                dominoes.hand_players = removeTileFromHand(dominoes.hand_players, p, tile);
                dominoes.current_player = nextPlayer(p);
                break;
            end;
        end;

    else
        
        %   2.1. Discover if current player has any double
        for p_inc = 1:1:4
            p = mod(dominoes.current_player - 1 + p_inc, 4) + 1;
            if hasDouble(dominoes.hand_players, p) == 1
                dominoes.current_player = p;
                tile = chooseDouble(dominoes);
                lastTile = tile;
                dominoes.initialTile = tile;

                % Update internal representation of the world
                dominoes = updateInternalRepresention(tile, -1, dominoes);
                % Update the score of both teams
                dominoes.score = updateScore(dominoes);
                
                dominoes.hand_players = removeTileFromHand(dominoes.hand_players, p, tile);
                dominoes.current_player = nextPlayer(p);
                break;
            else
                team = 2 - mod(p,2);
                other_team = 3 - team;
                dominoes.score(other_team) = dominoes.score(other_team) + 20;
                
            end;
        end;
        
    end;
    
%     disp('First played tile of match: '); disp(lastTile);
%     disp('Current score'); disp(dominoes.score);
    

    %   2.2. Start round
    while dominoes.boolMatchEnd ~= 1
        
        %       2.2.0. If doesn't have any tile to play so passed
        dominoes.notPlayed = dominoes.notPlayed + 1;
        if canPlay(dominoes) == 1
            %       2.2.1. Choose best tile and direction
            tilePlayed = chooseTile(dominoes);
            tile = tilePlayed{1,1};
            dir = tilePlayed{1,2};
            
            if tile(1) ~= -1 && tile(2) ~= -1
%                 disp(strcat('Tile successfully played by player', num2str(dominoes.current_player)));
                
                % Indicates the player have already played
                dominoes.notPlayed = 0;

    %             disp(dominoes.current_player);
                lastTile = tile;

                %       2.2.2. Remove the tile from hand and add it to the table
                dominoes.hand_players = removeTileFromHand(dominoes.hand_players, ...
                    dominoes.current_player, tile);

                %       2.2.3. Update internal representation of the world
                dominoes = updateInternalRepresention(tile, dir, dominoes);

                %       2.2.4. Update the score of both teams
                dominoes.score = updateScore(dominoes);
%             else disp('Invalid Tile!');
            end;
            
%              disp('  ');
             %       2.2.5. If the hand is empty finish the Game
                if isHandEmpty(dominoes.hand_players, dominoes.current_player) == 1
                    dominoes.boolMatchEnd = 1;

                    team = 2 - mod(dominoes.current_player,2);
                    other_team = 3 - team;

                    scoreGarage = getGarage(other_team, dominoes);
                    if mod(scoreGarage, 5) == 0
                        dominoes.score(team) = dominoes.score(team) + scoreGarage;
                    end;
%                     disp('Match END!');
                    break;
                end;
                
            %boolGameEnd = boolGameEnd + 1/2;
        end;
        
        
        team = 2 - mod(dominoes.current_player,2);
        other_team = 3 - team;
        old_player = previousPlayer(dominoes.current_player);
        
        % Player passing
        if dominoes.notPlayed == 1 && isGalo(dominoes, old_player) == 0
%             disp(strcat('Passed player ', num2str(dominoes.current_player)));
            dominoes.score(other_team) = dominoes.score(other_team) + 20;
%             disp('Current score'); disp(dominoes.score);
            % Update tiles when passing
            if lastTile(1) == lastTile(2)
                dominoes.tilesPassing{dominoes.current_player, lastTile(1) + 1} = ...
                    dominoes.tilesPassing{dominoes.current_player, lastTile(1) + 1} + 1;
            else
                dominoes.tilesPassing{dominoes.current_player, lastTile(1) + 1} = ...
                    dominoes.tilesPassing{dominoes.current_player, lastTile(1) + 1} + 1;
                dominoes.tilesPassing{dominoes.current_player, lastTile(2) + 1} = ...
                    dominoes.tilesPassing{dominoes.current_player, lastTile(2) + 1} + 1;
            end;
        % Galo
        elseif dominoes.notPlayed == 3
%             disp(strcat('Made Galo: player ', num2str(dominoes.current_player)));
            dominoes.score(other_team) = dominoes.score(other_team) + 50;
%             disp('Current score'); disp(dominoes.score);
        elseif dominoes.notPlayed >= 4
            % LookedGame
            dominoes.current_player = -1;
            scoreGarageTeam1 = getGarage(1, dominoes);
            scoreGarageTeam2 = getGarage(2, dominoes);
            if scoreGarageTeam1 > scoreGarageTeam2
                if mod(scoreGarageTeam1, 5) == 0
                    dominoes.score(2) = dominoes.score(2) + scoreGarageTeam1;
                end;
            elseif scoreGarageTeam2 > scoreGarageTeam1
                if mod(scoreGarageTeam2, 5) == 0
                    dominoes.score(1) = dominoes.score(1) + scoreGarageTeam2;
                end;
            end;
%             disp('Locked Game.');
%             disp('Current score'); disp(dominoes.score);
            break;
        end;

        dominoes.current_player = nextPlayer(dominoes.current_player);
    end;
    
    if dominoes.score(1) >= 200 || dominoes.score(2) >= 200
        dominoes.boolGameEnd = 1;
        break;
    else
        dominoes.boolGameEnd = 0;
        if dominoes.current_player == -1
            % Locked Game
            dominoes.initDoubleSix = 1;
        else dominoes.initDoubleSix = 0;
        end;
    end;
    
end;
    

results.last_player = dominoes.current_player;
results.score = dominoes.score;
if dominoes.score(1) > dominoes.score(2)
    results.winner_team = 1;
else results.winner_team = 2;
end;

end


function new_dominoes = updateInternalRepresention(tile, dir, dominoes)

    dominoes.freeTips = updateFreeTips(tile, dir, dominoes.freeTips);
    dominoes.freePointsTips = updateFreePointsTips(tile, dir, dominoes.freePointsTips);
    if tile(1) == tile(2)
        dominoes.tilesPlayed{dominoes.current_player, tile(1) + 1} = ...
            dominoes.tilesPlayed{dominoes.current_player, tile(1) + 1} + 1;
        dominoes.tilesTable(tile(1) + 1) = ...
            dominoes.tilesTable(tile(1) + 1) + 1;
    else
        dominoes.tilesPlayed{dominoes.current_player, tile(1) + 1} = ...
            dominoes.tilesPlayed{dominoes.current_player, tile(1) + 1} + 1;
        dominoes.tilesPlayed{dominoes.current_player, tile(2) + 1} = ...
            dominoes.tilesPlayed{dominoes.current_player, tile(2) + 1} + 1;
        dominoes.tilesTable(tile(1) + 1) = ...
            dominoes.tilesTable(tile(1) + 1) + 1;
        dominoes.tilesTable(tile(2) + 1) = ...
            dominoes.tilesTable(tile(2) + 1) + 1;
    end;
    
    dominoes.tilesFreeTips = [0,0,0,0,0,0,0];
    for x = 1:1:4
        if dominoes.freePointsTips{x}(1) == dominoes.freePointsTips{x}(2)
            dominoes.tilesFreeTips(dominoes.freePointsTips{x}(1) + 1) = ...
                dominoes.tilesFreeTips(dominoes.freePointsTips{x}(1) + 1) + 1;
        else 
            dominoes.tilesFreeTips(dominoes.freePointsTips{x}(1) + 1) = ...
                dominoes.tilesFreeTips(dominoes.freePointsTips{x}(1) + 1) + 1;
            dominoes.tilesFreeTips(dominoes.freePointsTips{x}(2) + 1) = ...
                dominoes.tilesFreeTips(dominoes.freePointsTips{x}(2) + 1) + 1;
        end;
    end;
    
    new_dominoes = dominoes;
end

function hand_players = shuffleHands()

    hand_players = cell(4,7);
    allTiles = cell(1,28);
    count = 1;
    for x = 1:1:7
        for y = 1:1:7
            if x <= y
                allTiles{count} = [x-1,y-1];
                count = count + 1;
            end;
        end;
    end;

    for x = 1:1:28
        newpos = randint(1,1,[1,28]);
        aux = allTiles{newpos};
        allTiles{newpos} = allTiles{x};
        allTiles{x} = aux;
    end;

    for x = 1:1:4
        for y = 1:1:7
            hand_players{x,y} = allTiles{1,((x-1)*7+y)};
        end;
    end;

end

function boolResult = hasDoubleSix(hand, player)

    boolResult = 0;
    for x = 1:1:7
        if (hand{player,x}(1) == 6 && hand{player,x}(2) == 6)
            boolResult = 1;
            break;
        end;
    end;

end

function boolResult = hasDouble(hand, player)

    disp(player);
    boolResult = 0;
    for x = 1:1:7
        hand{player,x}
        if hand{player,x}(1) ~= -1 && hand{player,x}(1) ~= -1 && ...
                hand{player,x}(1) == hand{player,x}(2)
            boolResult = 1;
            break;
        end;
    end;

end

function boolResult = canPlay(dominoes)

    boolResult = 0;
    for x = 1:1:4
        for tile = 1:1:7
            if (dominoes.hand_players{dominoes.current_player,tile}(1) ~= -1 && ...
                    dominoes.hand_players{dominoes.current_player,tile}(2) ~= -1) && ...
                (dominoes.freeTips(x) == dominoes.hand_players{dominoes.current_player,tile}(1) || ...
                    dominoes.freeTips(x) == dominoes.hand_players{dominoes.current_player,tile}(2))
                boolResult = 1;
            end;
        end;
    end;

end


%% Update Score for both team
function score = updateScore(dominoes)

    team = 1;
    if mod(dominoes.current_player,2) == 0
        team = 2;
    end;
    
    boolOpenPoints = getOpenPoints(dominoes);
    
    points = 0;
    
    if boolOpenPoints == [1 1 1 1]
        points = 0;
    elseif boolOpenPoints(2) == 1
        points = dominoes.initialTile(1) + dominoes.initialTile(2);
        points = points + dominoes.freeTips(4);
    elseif boolOpenPoints(4) == 1
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
    
    % Return just dividers by 5Home
    if mod(points,5) ~= 0
        points = 0;
    end;
    
%     if points > 0
%         disp(strcat(strcat('player', num2str(dominoes.current_player)), ...
%             strcat(strcat(' made ', num2str(points)), 'points')));
%     end;
    
    score = dominoes.score;
    score(team) = score(team) + points;

end

function freeTips = updateFreeTips(tile, targetSide, oldFreeTips)
    if targetSide == -1 
        if tile(1) == tile(2)
            freeTips = [tile(1), tile(1), tile(1), tile(1)];
        end;
    else
        freeTips = oldFreeTips;
        if freeTips(targetSide) == tile(1)
            freeTips(targetSide) = tile(2);
        end;
    end;
end

function freePointsTips = updateFreePointsTips(tile, dir, freePointsTips)

    if dir == -1 && tile(1) == tile(2)
        freePointsTips = {tile, tile, tile, tile};
    else
        freePointsTips{1,dir} = tile;
    end;

end

function player = nextPlayer(currentPlayer)

    player = currentPlayer + 1;
    if player > 4
        player = 1;
    end;

end

function player = previousPlayer(currentPlayer)

    player = currentPlayer - 1;
    if player < 1
        player = 4;
    end;

end

function hand = removeTileFromHand(hand, player, tile)

    for t = 1:1:7
        if (hand{player,t}(1) == tile(1) && hand{player,t}(2) == tile(2)) || ...
                (hand{player,t}(2) == tile(1) && hand{player,t}(1) == tile(2))
            hand{player,t} = [-1,-1];
        end;
    end;

end

function boolResult = isHandEmpty(hand, player)

    count = 0;
    boolResult = 0;

    for t = 1:1:7
        if hand{player,t}(1) == -1 && hand{player,t}(2) == -1
            count = count + 1;
        end;
    end;

    if count == 7
        boolResult = 1;
    end;

end

function evalPoints = applyHeuristic(side1, side2, direction, dominoes)

if dominoes.ai_mode{dominoes.current_player} == 0
    evalPoints = applyRandomHeuristic(side1, side2, direction, dominoes);
else
    evalPoints = applyStrategicHeuristic(side1, side2, direction, dominoes);
end;

end

function evalPoints = applyRandomHeuristic(side1, side2, direction, ...
    dominoes)

    boolOpenPoints = getOpenPoints(dominoes);

    [size_a size_b] = size(dominoes.freeTips);
    
    if (boolOpenPoints(2) == 1 || boolOpenPoints(4) == 1) && ...
            (direction == 1 || direction == 3)
        evalPoints = -100;
    elseif size_a ~= 0 && dominoes.freeTips(direction) == side1
        evalPoints = randi(1,1,[0,6]);
    else 
        evalPoints = -100;
    end

end



function tilePlayed = chooseTile(dominoes)

%     disp(strcat('player ', strcat(num2str(dominoes.current_player), ' is Choosing a tile...')));
%     disp('Current freeTips:'); disp(dominoes.freeTips);
%     disp('Current freePointTips'); 
    
    disp(dominoes.freePointsTips{1,1});
    disp(dominoes.freePointsTips{1,2});
    disp(dominoes.freePointsTips{1,3});
    disp(dominoes.freePointsTips{1,4});
    
    
%     if dominoes.ai_mode{dominoes.current_player} == 0
%         disp('Randomic Mode');
%     else disp('Strategic Mode');
%     end;
    
    bigger = -100;
    bestDirection = -1;
    bestTile = [-1,-1];
    
    for dir = 1:1:4
        heuristicEvaluation = [-1,-1,-1,-1,-1,-1,-1];
        for t = 1:1:7
            current_tile = dominoes.hand_players{dominoes.current_player,t};
            if current_tile(1) == -1 || current_tile(2) == -1
                heuristicEvaluation(t) = -100;
            elseif current_tile(1) == current_tile(2)
                heuristicEvaluation(t) = applyHeuristic(current_tile(1),...
                    current_tile(2), dir, dominoes);
            else
                h1 = applyHeuristic(current_tile(1),...
                    current_tile(2), dir, dominoes);
                h2 = applyHeuristic(current_tile(2),...
                    current_tile(1), dir, dominoes);
                if h2 > h1
                    heuristicEvaluation(t) = h2;
                    x_point =  current_tile(1);
                    current_tile(1) = current_tile(2);
                    current_tile(2) = x_point;
                    dominoes.hand_players{dominoes.current_player,t} = current_tile;
                else
                    heuristicEvaluation(t) = h1;
                end;         
            end;
            if heuristicEvaluation(t) > bigger
                bigger = heuristicEvaluation(t);
                bestDirection = dir;
                bestTile = current_tile;
            end;
        end;
    end;
    
    tilePlayed = {bestTile, bestDirection};
%     disp('Choice made! Tile will be played: '); disp(tilePlayed{1,1});
%     disp('');

end


function doubleTile = chooseDouble(dominoes)

    bigger = -1000;
    bestTile = [-1,-1];
   
    heuristicEvaluation = [-1,-1,-1,-1,-1,-1,-1];
    for t = 1:1:7
        current_tile = dominoes.hand_players{dominoes.current_player,t};
        if current_tile(1) == -1 || current_tile(2) == -1
            heuristicEvaluation(t) = -100;
        elseif current_tile(1) == current_tile(2)
            heuristicEvaluation(t) = current_tile(1) + current_tile(2);
        else
            heuristicEvaluation(t) = -100;       
        end;
        
        if heuristicEvaluation(t) > bigger
            bigger = heuristicEvaluation(t);
            bestTile = current_tile;
        end;
    end;
    
    doubleTile = bestTile;

end


function scoreGarage = getGarage(team, dominoes)

player = team;
for tile = 1:1:7
    if dominoes.hand_players{player,tile}(1) ~= -1 && ...
            dominoes.hand_players{player,tile}(2) ~= -1
        scoreGarage = dominoes.hand_players{player,tile}(1) + ...
            dominoes.hand_players{player,tile}(2);
    end;
end;

player = team + 2;
for tile = 1:1:7
    if dominoes.hand_players{player,tile}(1) ~= -1 && ...
            dominoes.hand_players{player,tile}(2) ~= -1
        scoreGarage = dominoes.hand_players{player,tile}(1) + ...
            dominoes.hand_players{player,tile}(2);
    end;
end;

end


function boolGalo = isGalo(dominoes, old_player)

boolGalo = 0;

total = 0;

for p = 1:1:4
    free_tip = dominoes.freeTips(p);
    total = total + dominoes.tilesHand{old_player, free_tip+1} + ...
        dominoes.tilesTable(free_tip+1);
end;

if total == 28
    boolGalo = 1;
end;

end