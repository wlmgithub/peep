# compute n-th fibonacci number with cache

memo = {0:0, 1:1}

def fib(n):
    if n not in memo:
        memo[n] = fib(n-1) + fib(n-2)
    return memo[n]

for i in range(200):
    print i, fib(i)
