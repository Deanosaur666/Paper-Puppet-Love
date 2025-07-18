
function AttackData(damage, stun, knockback, flags, hitfreeze)
    return {
        Damage = damage,
        Stun = stun,
        Knockback = knockback,
        Flags = flags,
        HitFreeze = hitfreeze,

        GuardStun = math.floor(stun * 0.75),
        GuardKnockback = math.floor(knockback * 0.75),
        GuardHitFreeze = math.floor(hitfreeze * 0.75),
    }
end

function AttackData_Power(power)
    local attackData = AttackData(10 + power*10, 14 + power*3, 150 + power*30, 0, 5 + power*5)

    return attackData
end