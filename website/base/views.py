from django.http import HttpResponse
from django.shortcuts import redirect, render
from django.contrib.auth.decorators import login_required
import pandas as pd
import csv


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
        data = request.POST.get('data')
        print(data.split(';'))

        # parsed_csv = list(csv.reader(data.split(';')))
        # df = pd.DataFrame(parsed_csv, columns=['ax', 'ay', 'az', 'gx', 'gy', 'gz'])
        # df.to_csv('static/myfile.csv', index=False)
    
    return HttpResponse('')
