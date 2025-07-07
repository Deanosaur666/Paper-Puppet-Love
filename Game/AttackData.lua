
function AttackData(damage, stun, knockback, flags, hitfreeze)
    return {
        Damage = damage,
        Stun = stun,
        Knockback = knockback,
        Flags = flags,
        HitFreeze = hitfreeze,
    }
end

function AttackData_Power(power)
    return AttackData(10 + power*10, 14 + power*3, 150 + power*30, 0, 5 + power*3)
end