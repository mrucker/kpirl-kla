function policy = huge_initialize_policy(basis, discount)

  policy.explore  = 1;

  policy.basis    = basis;
  policy.discount = discount;
  
  policy.actions  = huge_actions();
end