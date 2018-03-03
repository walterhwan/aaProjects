
def test(arr)
  arr.combination(2).to_a
end

def exp(base, power)
  return 1 if power.zero?
  base * exp(base, power - 1)
end

def exp1(base, power)
  return 1 if power == 0

  half = exp1(base, power / 2)
  if power.even?
    half * half
  else
    base * half * half
  end
end

p exp2(2, 10)
p exp1(2, 10)
