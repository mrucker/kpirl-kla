function expect = episodes2expect(episodes, func, gamma)

    expect   = 0;
    episodes = cellfun( @(e) { if_else(iscell(e), @() e, @() num2cell(e,1)) }, episodes);

    for episode = episodes
        for t = 1:numel(episode{1})
            expect = expect + gamma^(t-1) * func(episode{1}{t});
        end
    end

    expect = expect/numel(episodes);
end