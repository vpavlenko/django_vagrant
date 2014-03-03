from .common import *

DEBUG = eval(os.environ.get('DJANGO_DEBUG', 'False'))
TEMPLATE_DEBUG = eval(os.environ.get('DJANGO_DEBUG', 'False'))
