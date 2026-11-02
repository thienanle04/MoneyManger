# Integer minor units

Every stored amount is an integer number of minor units, via `Money` and a currency registry that knows the decimal digits for each ISO code. That keeps VND (0 decimals) and USD (2 decimals) on one model without float rounding. `double` balances were rejected. A decimal package was rejected as extra weight for this product. Arbitrary precision or crypto subunits would be a reason to revisit.
