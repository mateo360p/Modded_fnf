hey_allowed = true--who knows? maybe you dont' wanna use the most funny shit
HeyVolume = 0.5
local returnHey = true
function onUpdate(elapsed)
   if keyJustPressed('hey') and hey_allowed and returnHey then
      characterPlayAnim('boyfriend','hey', true)
      setProperty('boyfriend.specialAnim', true)
      playSound('eh', HeyVolume)

      returnHey = false
      runTimer('hahahahahaagain', 0.25) --yes, its funny but dont abuse 
   end
end

function onTimerCompleted(tag)
   if tag == 'hahahahahaagain' then
      returnHey = true
   end
end
function onGameOver()
   hey_allowed = false
end

