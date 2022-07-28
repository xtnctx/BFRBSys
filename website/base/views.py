from django.http import HttpResponse
from django.shortcuts import redirect, render
from django.contrib.auth.decorators import login_required
from django.core.files.base import File
from base.models import TModels
import pandas as pd
import csv
import os

# Create your views here.


def home(request):
    context = {}
    return render(request, 'base/home.html', context)

@login_required(login_url='login')
def app(request):
    context = {}
    return render(request, 'base/app.html', context)


def graph(request):
    context = {}
    return render(request, 'base/livePlot.html', context)




def export_data(request):
    if request.method == 'POST':

        '''

        >> This must be a header file (model.h)
        >> will fix soon ...

        '''

        data = request.POST.get('data')
        parsed_csv = list(csv.reader(data.split(';')))
        df = pd.DataFrame(parsed_csv, columns=['ax', 'ay', 'az', 'gx', 'gy', 'gz'])
        df.to_csv('static/temp.csv', encoding='utf-8', index=False)

        with open('static/temp.csv', 'rb') as f:
            fs = TModels(owner=request.user, file=File(f, name=os.path.basename(f.name)))
            fs.save()
        
        os.remove('static/temp.csv')
    
    return HttpResponse('')
