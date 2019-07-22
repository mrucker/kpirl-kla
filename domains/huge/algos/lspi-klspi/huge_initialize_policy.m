function policy = huge_initialize_policy(basis, discount)

  policy.explore  = 1;

  policy.basis    = basis;
  policy.actions  = huge_actions();
  policy.discount = discount;

end