theta1 = 1 - a
theta2 = a * (1 - t) * (1 - f) * (1 - c) + a * t * (1 - f) * (1 - c)
theta3 = a * (1 - t) * (1 - f) * c +  a * t * (1 - f) * c
theta4 = a * (1 - t) * f
theta5 = a * t * f

a <- .75
t <- .9
f <- .8
c <- .1

theta1 + theta2 + theta3 +theta4

N_trials = 5309
resp = c(1211, 1423, 1258, 1417)

theta_u = 1211/5309
theta_p = 1423/5309
theta_s = 1258/5309
theta_c = 1417/5309

theta_u + theta_p +theta_s + theta_c

theta[1] = 1 - a; //Pr_unrel
theta[2] = a + a * b * (1-c); //Pr_phon
theta[3] = a * (1-b);  //S
theta[4] = a * (b) + a  * (1-b) * c; //Pr_correct


a_true <- .75
t_true <- .9
f_true <- .8
c_true <- .1
# Probability of the different answers:
Theta <- tibble(NR = Pr_NR(a_true, t_true, f_true, c_true),
                Neologism = Pr_Neologism(a_true, t_true, f_true, c_true),
                Formal = Pr_Formal(a_true, t_true, f_true, c_true),
                Mixed = Pr_Mixed(a_true, t_true, f_true, c_true),
                Correct = Pr_Correct(a_true, t_true, f_true, c_true))
N_trials <- 200
(ans <- rmultinom(1, N_trials, c(Theta)))

