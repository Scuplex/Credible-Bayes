library(quantmod)

# --- 1. Data & Bayesian Setup ---
# Parameters from the text
rf <- 1.002           # Risk-free gross return
N  <- 60              # Sample size (observations)
t  <- 342.63          # Likelihood precision
T0 <- 12              # Prior strength
m0 <- 0.00328         # Prior mean
to <- T0 * t          # Prior precision
J  <- 100000          # Monte Carlo simulations

# Get SPY data
getSymbols("SPY", from = "2017-12-01", to = "2022-12-31", periodicity = "monthly")
SPY_adj <- Ad(SPY)
R_t     <- SPY_adj / lag(SPY_adj)
R_t     <- R_t[-1] # Remove NA
log_exc <- log(R_t) - log(rf)
r_hat   <- mean(log_exc)

# Posterior Distribution Calculation
tau_N <- to + N * t
mu_N  <- (to * m0 + t * N * r_hat) / tau_N

# Predictive Distribution Calculation (only need the sd)
pred_sd <- sqrt(1/t + 1/tau_N)

# Monte Carlo Simulation antithetic
r_half <- rnorm(J / 2, mean = mu_N, sd = pred_sd) 
r_anti <- 2 * mu_N - r_half # Antithetic
r_pred <- c(r_half, r_anti)


# 2 Plotting Setup 

# Grid of weights to test
w_grid <- seq(0, 1, length.out = 100) # i will try tomorrow to find the integral not grids

# Gamma values to loop through
gammas <- c(2, 4, 6, 8)

# Set up the plotting area 2 rows and 2 columns
par(mfrow = c(2, 2)) 

# For each Gamma find the maxCER and plot

for (g in gammas) {
  cer_values <- numeric(100) # initialize an empty numeric vector for the next gamma
  
  for (i in 1:100) {
    w <- w_grid[i]
    
    # Portfolio gross return component: (w * e^r + (1-w))
    port_term <- w * exp(r_pred) + (1 - w)
    
    # Expected Utility: E[port_term^(1-gamma)]
    eu <- mean(port_term^(1 - g))
    
    # Certainty Equivalent Return (Gross)
    # CER = Rf * (EU)^(1/(1-gamma))
    cer_gross <- rf * (eu)^(1 / (1 - g))
    
    # Convert to Net Percentage for the plot: (Gross - 1) * 100
    cer_values[i] <- (cer_gross - 1) * 100
  }
  
  # B. Find Optimal Weight
  opt_idx <- which.max(cer_values)
  opt_w   <- w_grid[opt_idx]
  opt_val <- cer_values[opt_idx]
  
  # C. Base R Plotting
  plot(w_grid, cer_values,
       type = "l",             # Line plot
       col  = "red",           # Red color
       lwd  = 2,               # Line width
       lty  = 2,               # Dashed line style
       xlab = "Portfolio weight w",
       ylab = "CER(w) (in net percentage)",
       main = "",              # We will add a custom title below
       ylim = c(min(cer_values) - 0.05, max(cer_values) + 0.05)) # Add some breathing room
  
  # Add the black dot at the maximum
  points(opt_w, opt_val, pch = 19, col = "black", cex = 1.2)
  
  # added the title
  title(main = bquote(gamma == .(g) ~ ", optimal weight " ~ w^"*" == .(sprintf("%.2f", opt_w))))
}