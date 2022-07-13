from django.shortcuts import render

# Create your views here.


def home(request):
    context = {}
    return render(request, 'base/home.html', context)


def app(request):
    context = {}
    return render(request, 'base/app.html', context)