from django.shortcuts import render
from .models import TestModel

TEXT = 'some text'

def home(request):
    tw = TestModel(text=TEXT)
    tw.save()

    test_db_ok = False

    try:
        test_db_ok = TestModel.objects.filter(text=TEXT).count() >= 1
    except Error as e:
        raise e

    return render(request, 'index.html', {'test_db_ok': test_db_ok})
