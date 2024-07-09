drainHP_allowed = true
drainingHP = 0.022
function opponentNoteHit()
    health = getProperty('health')
    if drainHP_allowed == true then
        if getProperty('health') > 0.05 then
            setProperty('health', health- drainingHP);
        end
    end
end
function onUpdate(elapsed)
    setGlobalFromScript('scripts/Kill_On_Miss', 'drainingHP', drainingHP)
end