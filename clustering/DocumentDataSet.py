import math
from os import listdir
from os.path import isfile, isdir, join
from os import getcwd
import copy
import matplotlib.pyplot as plt
import numpy as np
import random

#Note: Some of the above libraries are not in the standard python libraries.

#Vectorizes a string by the "trigram" method.
def trivectorize(string):
    trigram = ''
    docvector = dict()
    for index in range(0, len(string)-2, 1):
        trigram = string[index] + string[index + 1] + string[index + 2]
        if trigram in docvector:
            docvector[trigram] += 1
        else:
            docvector[trigram] = 1
    return docvector

#Vectorizes a string by word frequency.
def wordvectorize(string):
    word = ''
    docvector = dict()
    ignoredpunct = ['!', '"', '#', '$', '%', '(', ')', '*', '+', ',', '.', '?', '/', ':', ';', '<', '>', '=', '[', ']', '\\', '{', '}', '|', '^', '~', '_', '`']
    for index in range(0, len(string)):
        if string[index] != ' ':
            if string[index] in ignoredpunct:
                pass
            else:
                word += string[index]
        else:
            if word != '':
                if word in docvector:
                    docvector[word] += 1
                else:
                    docvector[word] = 1
            word = ''
    return docvector

#Vectorizes a string by the "letterhop" algorithm:
#   Each character is a key in the dictionary, and is assigned a number based on
#   the average distance between each instance of that character in the string.
def lhvectorize(string):
    docvector = dict()
    letterlist = []
    start = 0
    startlist = []
    for letter in string:
        if letter not in letterlist:
            letterlist.append(letter)
            startlist.append(start)
        start += 1

    stringlen = len(string)
    elnum = 0
    for element in letterlist:
        index = 0
        count = 0
        total = 0
        for x in range(startlist[elnum], stringlen):
            if string[x] == element:
                total += index
                count += 1
                index = 0
            else:
                index += 1
        total = float(total) // float(count)
        docvector[element] = total
    return docvector

#Files are vectorized using one or a mixture of vectorizations defined.
def vectorizefile(method, filename, newfilename = None):
    if method == "trigram":
        filevector = trivectorize(filename.read())
    elif method == "word":
        filevector = wordvectorize(filename.read())
    elif method == "tri+word":
        trigramvector = trivectorize(filename.read())
        filevector = wordvectorize(filename.read())
        filevector.update(trigramvector)
        #
        #note that in this implementation, any three-letter entries shared
        #by both methods are resolved to the trigram method's value
        #
    elif method == "letterhop":
        filevector = lhvectorize(filename.read())
    elif method == "tri+lh":
        trigramvector = trivectorize(filename.read())
        filevector = lhvectorize(filename.read())
        filevector.update(trigramvector)
    try:
        if newfilename != None:
            newfilename.write(str(filevector))
    except (ValueError, NameError, TypeError):
        print("Error with method entered, please pick from the following methods: 'trigram', 'word', 'tri+word', 'letterhop', 'tri+lh'")
    return filevector




#The dataProfile class wraps different file vectors for passing into
#profileDataSet, and performs relevant computations on vectors.
class dataProfile:

    def __init__(self, method, filename, pvector = ''):  #second argument allows passing directly as vector
        if filename == 'pass as vector':
            self._vector = pvector
            self._name = 'RAW_VECTOR'
        else:
            filetemp = open(filename, 'r', encoding="utf8")
            self._vector = vectorizefile(method, filetemp)
            self._name = filename

    def __str__(self):
        return self._name

    #Retrieves the vector of this instance.
    def getVector(self):
        vectorgotten = self._vector
        return vectorgotten

    #Retrieves value for a given key; if the key is not in this instance's,
    #vector returns 0.
    def getCoord(self, key):
        if key not in self._vector:
            return 0
        else:
            return self._vector[key]

    #Computes the Euclidean distance between this instance and another instance
    #of dataProfile.
    def dist(self, other):
        keylist = list(set(self._vector.keys()) | set(other._vector.keys()))
        distancescalar = 0
        for key in keylist:
            dimen = self.getCoord(key) - other.getCoord(key)
            dimen = dimen**2
            distancescalar += dimen
        distancescalar = math.sqrt(distancescalar)
        return distancescalar

#The profileDataSet class contains references to a set of dataProfile
#instances, and provides tools for their analysis.
class profileDataSet:

    def __init__(self):
        self._profileList = []
        self._masterKeyList = []

    #Adds an instance of dataProfile to this set.
    def addProfile(self, profile):
        self._profileList.append(profile)
        self._masterKeyList = list(set(self._masterKeyList) | set(profile.getVector().keys()))

    #Vectorizes all files (not of extension .py) and loads them into this
    #instance of profileDataSet.
    def loadCurrentDir(self, method):
        #Available methods: "trigram", "word", "tri+word", "letterhop"
        currentdir = getcwd()
        files = []
        for f in listdir(currentdir):
            if isfile(join(currentdir, f)):
                files.append(f)
            elif isdir(f):
                for e in listdir(f):
                    if isfile(join(f, e)):
                        files.append(e)

        #Files in the directory are chosen and added.
        for filename in files:
            if '.py' in filename:  #This means it only skips over .py files; this can be modified to fit different sorts of directories.
                pass
            else:
                self.addProfile(dataProfile(method, filename))

    #Returns a displayable list of the current profiles as strings.
    def __str__(self):
        strlist = []
        for profile in self._profileList:
            strlist.append(str(profile))
        return str(strlist)

    #Returns the current number of profiles (length of profileList).
    def getLength(self): #check necessity
        return len(self._profileList)

    #Retrieves the list of current profiles.
    def getprofileList(self):
        listgotten = copy.deepcopy(self._profileList)
        return listgotten

    #Computes the average of all current profiles and returns this as a profile.
    def getMean(self):
        #Running time proportional to (number of unique characters overall) *
        #(number of profiles in data set).
        meanVector = dict((key, 0) for key in self._masterKeyList)
        for meankey in meanVector:
            for vector in self._profileList:
                if meankey in vector.getVector():
                    meanVector[meankey] += vector.getVector()[meankey]
            meanVector[meankey] = float(meanVector[meankey]) / float(self.getLength())
        meanWrapper = dataProfile("vector", 'pass as vector', meanVector)
        return meanWrapper

    #Performs a k-means clustering algorithm on the profiles in this set, and
    #returns list containing first a list of the centroid assignments for each
    #profile, and second the average Euclidean distance between profiles and
    #their assigned centroid mean.
    def kCluster(self, k):
        IDList = []
        for vector in self._profileList:
            IDList.append(1)
        meanList = []
        index = 0
        #Streamlining of the k=1 case...
        if k == 1:
            allmean = self.getMean()
            ADCC = 0
            index = 0
            for vector in self._profileList:
                vdist = vector.dist(allmean)
                ADCC += vdist * vdist
                index += 1
            ADCCk = float(ADCC) / float(index)
            return [IDList, ADCCk]
        #And here the k>1 case.
        else:
            rintlist = []
            while len(meanList) < k:  #setting initial mean vectors
                rint = random.randint(0, len(self._profileList))
                if rint in rintlist: #Is this check necessary? Can I skip this line?
                    while rint in rintlist:
                        rint = random.randint(0, len(self._profileList))
                rintlist.append(rint)
                meanList.append(self._profileList[rint])
                index += 1
            index = 0
            for vector in self._profileList:  #setting initial clusters
                lowestdist = vector.dist(meanList[0])
                for mean in meanList:
                    tempdist = vector.dist(mean)
                    if tempdist < lowestdist:
                        lowestdist = tempdist
                        IDList[index] = meanList.index(mean) + 1
                    else:
                        pass
                index += 1

            loopiterator = 0
            completion = 0
            while completion == 0:  #primary clustering loop
                oldIDList = copy.deepcopy(IDList)
                oldMeanList = copy.deepcopy(meanList)
                for clusterID in range(1, k+1, 1):  #computing new meanList
                    clusterSet = profileDataSet()
                    for index in range(len(IDList)):
                        if IDList[index] == clusterID:
                            clusterSet.addProfile(self._profileList[index])
                        else:
                            pass
                    meanList[clusterID-1] = clusterSet.getMean()

                index = 0
                ADCCk = 0
                for vector in self._profileList:  #assigning new IDs
                    lowestdist = vector.dist(meanList[0])
                    for mean in meanList:
                        tempdist = vector.dist(mean)
                        if tempdist <= lowestdist:  #<= for lowestdist == case
                            lowestdist = tempdist
                            IDList[index] = meanList.index(mean) + 1
                        else:
                            pass
                    index += 1
                    ADCCk += lowestdist * lowestdist
                ADCCk = float(ADCCk) / float(len(IDList))

                oldmeans = []
                for profile in oldMeanList:
                    oldmeans.append(profile.getVector())
                newmeans = []
                for profile in meanList:
                    newmeans.append(profile.getVector())

                loopiterator += 1
                if (oldmeans == newmeans) & (oldIDList == IDList):
                    completion = 1
                print(loopiterator)
                print(ADCCk)

            return [IDList, ADCCk]


    #Performs a series of kCluster trials for k = 1 to k = maxk, maxk being
    #the input argument. Prints a list of the average distances between
    #vectors and their centroid mean, and plots these according to k value.
    def kAnalysis(self, maxk):
        averagelist = []
        for k in range(1, maxk+1):
            clusteringlist = self.kCluster(k)
            clusterID = clusteringlist[1]
            averagelist.append(clusterID)
            print(k, ' done.')

        print(averagelist)
        plt.plot(np.arange(1, maxk + 1), np.array(averagelist))
        plt.xlabel('k')
        plt.ylabel('Average Distance from Cluster Center')
        plt.show()
