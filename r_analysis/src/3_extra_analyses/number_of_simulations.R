# Multi-scale modeling

# Main simulations
main <- 15748          # neuronal model [2 neuronal models; 7874 locations]
main[2] <- 7762        # gyral shape    [7762 for the mushroom shaped gyrus]
main[3] <- 94488       # rotate cells around Y axis  [7874 locations; 12 angles]
main[4] <- 25467       # neuronal depth
main[5] <- 38843       # gyral height   [5 different heights]

# Control simulations
control <- 1000        # mesh resolution
control[2] <- 70866    # synaptic strength
control[3] <- 15748    # neuronal morphology
control[4] <- 110236   # coil angle     [7 coil angles; 2 neuronal models; 7874 locations]

# Summarize
sum(main)
sum(control)
sum(main) + sum(control)