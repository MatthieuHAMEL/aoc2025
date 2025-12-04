""" Checks if the number is made of some sequence of 
digits repeated twice, e.g. 22 or 12341234 or 1188511885 """
def isInvalidID_method1(num: int):
    str_num = str(num)
    n = len(str_num)
    return n % 2 == 0 and str_num[0:n//2] == str_num[n//2:n]

"""Checks if the number is made of some sequence of 
digits repeated twice or more, e.g. 22 or 12341234123412341234 or 1188511885"""
def isInvalidID_method2(num: int) -> bool:
    s = str(num)
    n = len(s)
    if n <= 1:
        return False    
    for sz in range(1, n//2 + 1):
        if n % sz != 0: # the string cannot be divided in k patterns of size sz
            continue
        pattern = s[:sz]
        if pattern * (n//sz) == s:
            return True
    return False

###################################################
with open('input.txt') as f: s = f.read()

# Construct a list of pairs representing the ranges
myRanges = s.split(',')
for i in range(len(myRanges)):
    myRanges[i] = myRanges[i].split('-') 

result_1, result_2 = 0, 0
for start, end in myRanges:
    for number in range(int(start), int(end)+1):
        if isInvalidID_method1(number):
            result_1 += number
        if isInvalidID_method2(number):
            result_2 += number

print(result_1)
print(result_2)
