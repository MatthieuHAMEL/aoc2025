with open('input.txt') as f: s = f.read()

""" Checks if the number is made of some sequence of 
digits repeated twice, e.g. 22 or 12341234 or 1188511885 """
def isInvalidID_method1(num: int):
    str_num = str(num)
    n = len(str_num)
    return n % 2 == 0 and str_num[0:n//2] == str_num[n//2:n]
    
myRanges = s.split(',')
for i in range(len(myRanges)):
    myRanges[i] = myRanges[i].split('-') 

result_1 = 0
for start, end in myRanges:
    for number in range(int(start), int(end)+1):
        if isInvalidID_method1(number):
          result_1 += number

print(result_1)
