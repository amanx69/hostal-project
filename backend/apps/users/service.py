import  random


def gernate_username():
    name= random.choices('abcdefghijklmnopqrstuvwxyz0123456789', k=8)
    return ''.join(name)
        