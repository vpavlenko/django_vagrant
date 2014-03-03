from .common import *
import os

DEBUG = eval(os.environ.get('DJANGO_DEBUG', 'True'))
TEMPLATE_DEBUG = eval(os.environ.get('DJANGO_DEBUG', 'True'))
