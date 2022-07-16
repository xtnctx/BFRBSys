from django.shortcuts import render
from django.contrib.auth.decorators import login_required

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
