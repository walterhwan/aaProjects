def factor(num)
  (1..num).to_a.select { |n| (num % n).zero? }
end
