from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login, logout
from accounts.forms import RegisterForm
from base.models import TrainingStatus
from django.contrib.auth.views import PasswordChangeView
from django.contrib.auth.forms import PasswordChangeForm
from django.contrib.auth.models import User
from django.contrib import messages
from validate_email import validate_email

# Create your views here.


def login_view(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        nextURL = request.POST.get('next')

        user = authenticate(request, username=username, password=password)
        if user is None:
            context = {'error': 'Invalid username or password'}
            return render(request, 'accounts/login.html', context)
        login(request, user)

        return redirect(nextURL) if nextURL != '' else redirect('home')

    context = {}
    return render(request, 'accounts/login.html', context)
    # return redirect(request.POST.get('next','../app/'))

def logout_view(request):
    if request.method == 'POST': 
        logout(request)
        return redirect('home')
    context = {}
    return render(request, 'accounts/logout.html', context)

def register_view(request):
    if request.method == 'POST':
        form = RegisterForm(request.POST)

        if form.is_valid():
            form.save()
            new_user = authenticate(
                request, 
                username=form.cleaned_data['username'], 
                password=form.cleaned_data['password1']
                )
            TrainingStatus(owner=new_user, message_status='').save()
            login(request, new_user)
            return redirect('home')
    else:
        form = RegisterForm()

    context = {'form': form}
    return render(request, 'accounts/register.html', context)

def account_info(request):
    if request.method == 'POST':
        ...
    context = {}
    return render(request, 'accounts/account_info.html', context)

def edit_account(request):
    if request.method == 'POST':
        newusername = " ".join(request.POST.get('newusername').split())
        newemail = " ".join(request.POST.get('newemail').split())
        newfirstname = " ".join(request.POST.get('newfirstname').split())
        newlastname = " ".join(request.POST.get('newlastname').split())

        user = User.objects.get(username = request.user.username)
        if newusername != '':
            user.username = newusername
            user.save()
        
        if newfirstname != '':
            user.first_name = newfirstname.title()
            user.save()

        if newlastname != '':
            user.last_name = newlastname.title()
            user.save()
        
        if validate_email(newemail):
            user.email = newemail
            user.save()
        elif newemail != '':
            messages.error(request, 'Invalid email')
    
        print(request.user.first_name)
        return redirect('edit_account')

    context = {}
    return render(request, 'accounts/edit_account.html', context)



class UpdatePassword(PasswordChangeView):
    form_class = PasswordChangeForm
    success_url = '/edit_account'
    template_name = 'accounts/changepassword.html'