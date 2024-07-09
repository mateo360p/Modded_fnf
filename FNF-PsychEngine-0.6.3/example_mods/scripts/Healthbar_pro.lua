-- OG Script by AquaStrikr (https://twitter.com/AquaStrikr_)
--Annnnnddddd a lot of changes by mateo360p (so many changes omg) ;D
ActualBar = 1 --The normal (yellow)
function onCreate()
	makeAnimatedLuaSprite('hpbar', 'healthbarpro')
	setProperty('hpbar.alpha', 1)
	setObjectCamera('hpbar', 'hud')
	--normal
	addAnimationByPrefix('hpbar', 'neutral', 'Idle', 24, true)
	addAnimationByPrefix('hpbar', 'winbf', 'Bf', 24, true)
	addAnimationByPrefix('hpbar', 'windad', 'Dad', 24, true)
	--red
	addAnimationByPrefix('hpbar', 'redneutral', 'rIdle', 24, true)
	addAnimationByPrefix('hpbar', 'redwinbf', 'rBf', 24, true)
	addAnimationByPrefix('hpbar', 'redwindad', 'rDad', 24, true)
	--static
	addAnimationByPrefix('hpbar', 'staticneutral', 'sIdle', 24, true)
	addAnimationByPrefix('hpbar', 'staticwinbf', 'sBf', 24, true)
	addAnimationByPrefix('hpbar', 'staticwindad', 'sDad', 24, true)
	--add da shit
	addLuaSprite('hpbar', true)
end

function onCreatePost()
	setObjectOrder('hpbar', getObjectOrder('healthBar') + 0)
end

function onUpdate(elapsed)
	setProperty('hpbar.x', getProperty('healthBar.x') - 55)
	setProperty('hpbar.y', getProperty('healthBar.y') - 20)
	if ActualBar == 1 then --normal
		if getProperty('health') <= .4 then
			playAnim('hpbar', 'windad')
		elseif getProperty('health') >= 1.625 then
			playAnim('hpbar', 'winbf')
		else
			playAnim('hpbar', 'neutral')
		end
	end
	if ActualBar == 2 then --red
		if getProperty('health') <= .4 then
			playAnim('hpbar', 'redwindad')
		elseif getProperty('health') >= 1.625 then
			playAnim('hpbar', 'redwinbf')
		else
			playAnim('hpbar', 'redneutral')
		end
	end
	if ActualBar == 3 then --static
		if getProperty('health') <= .4 then
			playAnim('hpbar', 'staticwindad')
		elseif getProperty('health') >= 1.625 then
			playAnim('hpbar', 'staticwinbf')
		else
			playAnim('hpbar', 'staticneutral')
		end
	end
end