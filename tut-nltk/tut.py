import nltk
nltk.download()


# corpus e classe text
from nltk.corpus import machado
machado.fileids()
raw_text = machado.raw('romance/marm05.txt')
print(raw_text[5600:5800])