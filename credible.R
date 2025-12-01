# Bayes Beta estimator

T <- 60       # number of periods
theta <- 0.7      # true probability of success
ST <- 38

a0 <- 0.5
b0 <- 0.5
aT <- a0 + ST
bT <- b0 + T - ST

posterior_mean  <- aT / (aT + bT) # Find the posterior_mean

x <- seq(0,1,length.out=400)
prior_density <- dbeta(x, a0, b0)
post_density  <- dbeta(x, aT, bT)

#  equal-tailed  90% credible interval
ci_lower <- qbeta(0.05, aT, bT)  # 0.05 comes from (1 - 0.90) / 2
ci_upper <- qbeta(0.95, aT, bT)  # 0.95 comes from 1 - 0.05

# the 90% CI centered at the posterior mode



# Start the plot
plot(x, post_density,
     type = "l",
     col = "blue",
     lwd = 3,
     main = "Posterior vs Prior (BETA)",
     xlab = "(Probability of Success)",
     ylab = "Probability Density Function")

# Add the Prior Density
lines(x, prior_density, col = "black", lty = 2, lwd = 2)
abline(v = ci_lower, col = "purple", lty = 2)
abline(v = ci_upper, col = "purple", lty = 2)

# Top left Banner
legend("topleft",
       legend = c(
         paste("Prior: Beta(", a0, ", ", b0, ")", sep = ""),
         paste("Posterior: Beta(", aT, ", ", bT, ")", sep = ""),
         paste("90% CI: [", round(ci_lower, 3), ", ", round(ci_upper, 3), "]", sep="")
       ),
       col = c("black", "blue", "purple"),
       lty = c(2, 1, 2),
       lwd = c(2, 3, 1),
       cex = 0.8
)


