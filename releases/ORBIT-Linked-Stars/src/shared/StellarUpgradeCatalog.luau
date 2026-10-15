local C={
    Research={
        {Id="SignalAmplifier",Name="Signal amplifier",Description="Boost another star's click production.",Cost=100000000,Growth=10,Max=5,Amount=.1,Effect="Clicks",Wallet="Currency"},
        {Id="SupplyNetwork",Name="Supply network",Description="Boost another star's passive production.",Cost=500000000,Growth=10,Max=5,Amount=.1,Effect="Passive",Wallet="Currency"},
    },
    Ascension={
        {Id="StellarLegacy",Name="Stellar legacy",Description="Improve all production in another star.",Cost=10,Growth=1.6,Max=10,Amount=.05,Effect="Production",Wallet="Stars"},
        {Id="VoyagerStorage",Name="Voyager storage",Description="Extend another star's offline earning capacity.",Cost=5,Growth=1.6,Max=8,Amount=900,Effect="Offline",Wallet="Stars"},
    },
}
function C.Get(section,id)
    for _,d in ipairs(C[section] or {})do if d.Id==id then return d end end
    return nil
end
return C
