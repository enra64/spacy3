def subset_sum(numbers, target, partial=[]):
    s = sum(partial)

    # check if the partial sum is equals to target
    if s == target:
        print("{" + ', '.join([str(a) for a in partial]) + "},")
    if s >= target:
        return  # if we reach the number why bother to continue

    for i in range(len(numbers)):
        n = numbers[i]
        remaining = numbers[i+1:]
        subset_sum(remaining, target, partial + [n])


if __name__ == "__main__":
    subset_sum([1,1,2,2,2,2,3,3,3,4,4,4,8,8,8], 14)

# use with python2 gen.py | uniq