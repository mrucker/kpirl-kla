function policy = huge_initialize_policy(basis, discount, reward)

  policy.explore  = 1;

  policy.discount = discount;
  policy.reward   = reward;

  policy.basis    = feval(basis);
  policy.actions  = huge_actions();
end