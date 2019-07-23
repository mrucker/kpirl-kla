function policy = huge_initialize_policy(basis, discount, reward)

  policy.explore  = 1;

  policy.basis    = basis;
  policy.discount = discount;
  policy.reward   = reward;
  
  policy.actions  = huge_actions();
end