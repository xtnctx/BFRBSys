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
    if request.method == 'POST':
        csv_string = request.POST.get('data')
        parsed_csv = list(csv.reader(csv_string.split(';')))
        df = pd.DataFrame(parsed_csv, columns=['Name', 'City', 'Info'],)
        df.to_csv('static/myfile.csv', index=False)
        return redirect('graph')
    context = {}
    return render(request, 'base/livePlot.html', context)
