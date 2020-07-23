#Python program to fetch Amazon Web Services CIDRs 

#os is used to remove output file of curl commands
import os,sys

#subprocess is used to execute curl commands
import subprocess

if(len(sys.argv) != 2 and len(sys.argv) != 3):
  print "Usage : getAwsIpByZone.py <region> [<service>]"
  sys.exit()

region = sys.argv[1]
service = "ALL"
if (len(sys.argv) == 3):
  service = sys.argv[2]

def calcDottedNetmask(mask):
    mask = int(mask)
    bits = 0
    for i in xrange(32-mask,32):
        bits |= (1 << i)
    return "%d.%d.%d.%d" % ((bits & 0xff000000) >> 24, (bits & 0xff0000) >> 16, (bits & 0xff00) >> 8 , (bits & 0xff))



#Gets IP address ranges of AWS
try :
        #Get the json file from amazonaws.com with a curl command
        subprocess.check_output(["curl", "-o", "json.txt", "-s", "https://ip-ranges.amazonaws.com/ip-ranges.json"])
except subprocess.CalledProcessError :
        #Error during the curl command
        print "Access to ipinfo.io impossible"
#Read the result of the curl command
jsonFile = open("json.txt", "r")
json = jsonFile.read()

lignes = []

#Remove useless symbols
json = json.replace(" ", "")
json = json.replace("\n", "")
json = json.replace('"', "")
json = json.replace("}", "")
json = json.replace("]", "")
json = json.replace("ip_prefix:", "")
json = json.replace("ipv6_prefix:", "")
json = json.replace("region:", "")
json = json.replace("service:", "")

#Split the remaining codes into lines
lines = json.split("{")

addresses = []
commands = []
updates = []
deletes = []

#Remove useless two first lines
lines.remove(lines[0])
lines.remove(lines[0])

for l in lines :
        ligne = l.split(",")
        if ((ligne[1] == region) and (ligne[0].find(":") == -1 )) :
          if(service == "ALL" or service==ligne[2]):
                addresses.append(ligne[0])
                cidrName = ligne[0].replace("/","-")
                ip = ligne[0].split("/")[0]
                netMask = calcDottedNetmask(ligne[0].split("/")[1])
                netName = "AWS_"+ligne[2]+"_"+region+"_"+cidrName
                print netName+";"+ip+";"+netMask

#Remove the output of the curl command
os.remove("json.txt")
