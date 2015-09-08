import copy

#Checks the highest possible similarity between two files with the same number
#of unique characters by permutation.
def analyzefiles(infile, truthfile):
    infileobject = open(infile, 'r', encoding="utf8")
    truthfileobject = open(truthfile, 'r', encoding="utf8")
    return analyzer(infileobject.read(), truthfileobject.read())


#analyzer(resultofanalysis, actualclassification)

def analyzer(instring, truthstring):
    percentlist = []
    truthnumbers = []
    innumbers = []
    for number in truthstring:
        if number not in truthnumbers:
            truthnumbers.append(number)
    for number in instring:
        if number not in innumbers:
            innumbers.append(number)
    while len(truthnumbers) < len(innumbers):
        truthnumbers.append('!')              #therefore ! is not a valid ID
    
    combs = permute(truthnumbers)
    for possibility in combs:
        stringlist = list(instring)
        positerator = 0
        for element in instring:
            old = innumbers.index(element)
            stringlist[positerator] = possibility[old]
            positerator += 1

        accuracycount = 0
        seconditer = 0
        for element in truthstring:
            if element == stringlist[seconditer]:
                accuracycount += 1
            seconditer += 1
        percenterror = float(accuracycount) / float(seconditer)
        percentlist.append(percenterror)

    highest = 0
    thirditer = 0
    listindex = 0
    for percent in percentlist:
        if percent > highest:
            highest = percent
            listindex = thirditer
        thirditer += 1

    result = [combs[listindex], highest]
    return result


def permute(ourlist):
    if len(ourlist) == 2:
        return [ourlist, [ourlist[1], ourlist[0]]]
    else:
        permutations = []
        for element in ourlist:
            newlist = copy.deepcopy(ourlist)
            newlist.remove(element)
            cdr = permute(newlist)
            for permutation in cdr:
                result = [element] + permutation
                permutations.append(result)
    return permutations


def convertfromIDList(inputlist):
    resultstring = ""
    for number in inputlist:
        if number < 10:
            resultstring += number
        else:
            newchar = number + 48
            resultstring += chr(newchar) #starting at :
    return resultstring


def stringConvert(string):
    setlist = []
    currentword = ""
    namestatus = 1
    resultstring = ""
    for character in string:
        if (namestatus == 1) & (character != "/"):
            currentword += character
        elif (namestatus == 1) & (character == "/"):
            if currentword not in setlist:
                setlist.append(currentword)
            resultstring += str(setlist.index(currentword))
            currentword = ""
            namestatus = 0
        elif namestatus == 0:
            if character == " ":
                namestatus = 1
    return resultstring


def fileConversion(filename, newfilename = None):
    fileobject = open(filename, 'r', encoding="utf8")
    converted = stringConvert(fileobject.read())
    if newfilename != None:
        newfileobject = open(newfilename, 'w', encoding="utf8")
        newfileobject.write(str(converted))
    return
        

