data { 
  int<lower = 1> N_trials;
  int<lower = 0, upper = N_trials> resp[4];
}
parameters {
  real<lower = 0, upper = 1> a;
  real<lower = 0, upper = 1> b;
  real<lower = 0, upper = 1> c;
} 
transformed parameters {
  simplex[5] theta;
  theta[1] = 1 - a; //Pr_unrel
  theta[2] = a + a * b * (1-c); //Pr_phon
  theta[3] = a * (1-b);  //S
  theta[4] = a * (b) + a  * (1-b) * c; //Pr_correct
}
model {
  target += beta_lpdf(a | 2, 2);
  target += beta_lpdf(b | 2, 2);
  target += beta_lpdf(c | 2, 2);
  target += multinomial_lpmf(resp | theta);
}
generated quantities{
    int pred_resp[5];
    pred_resp = multinomial_rng(theta, 5);
}