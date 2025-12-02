with open('input.txt') as f: s = f.read()

""" Checks if the number is made of some sequence of 
digits repeated twice, e.g. 22 or 12341234 or 1188511885 """
def isInvalidID_method1(num: int):
    str_num = str(num)
    n = len(str_num)
    return n % 2 == 0 and str_num[0:n//2] == str_num[n//2:n]

""" "Naive" version """
def isInvalidID_method2(num: int):
    str_num = str(num)
    n = len(str_num)
    bInvalid = False
    if n <= 1:
        return bInvalid
    for sz in range(1, 1 + n//2): # the candidate pattern cannot be bigger!
        pattern = str_num[0:sz]
        # Is that candidate pattern OK?
        if n % len(pattern) != 0: # no!
            continue
        
        bInvalid = True # consider it is True and test it:
        for i in range(len(pattern), n, len(pattern)):
            # e.g. if pattern length is 2, i goes from index 2 to n with steps of 2.
            if pattern != str_num[i:i+len(pattern)]:
                bInvalid = False
                break # let's take a bigger pattern, this one didn't match!
        if bInvalid: # Found!
            break
    return bInvalid

        
isInvalidID_method2(7693676936)        


myRanges = s.split(',')
for i in range(len(myRanges)):
    myRanges[i] = myRanges[i].split('-') 

result_1, result_2 = 0, 0
for start, end in myRanges:
    for number in range(int(start), int(end)+1):
        b1 = False
        if isInvalidID_method1(number):
            result_1 += number
            b1 = True
        if isInvalidID_method2(number):
            result_2 += number
        else:
            if (b1):
                print("hi")
print(result_1)
print(result_2)
