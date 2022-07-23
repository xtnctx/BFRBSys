import re
with open('data.txt') as stream:
    contents = stream.read()
    x = re.sub('\s$', '', contents, flags=re.MULTILINE)


start = len('constunsignedcharmodel[]={')
parsedFile = x.replace(" ", "").replace("\n","")

z = parsedFile[start:-2]

print(len(z))
