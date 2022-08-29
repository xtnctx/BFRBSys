from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login, logout
from validate_email import validate_email
from accounts.forms import RegisterForm
from base.models import TrainingStatus
from accounts.models import Profile
from django.contrib.auth.views import PasswordChangeView
from django.contrib.auth.forms import PasswordChangeForm
from django.contrib.auth.models import User
from django.contrib import messages
import os

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
            Profile(user=new_user).save()
            login(request, new_user)
            return redirect('home')
    else:
        form = RegisterForm()

    context = {'form': form}
    return render(request, 'accounts/register.html', context)

def account_info(request):
    profile = Profile.objects.get(user=request.user)
    context = {'profile':profile}
    if request.method == 'POST':
        ...
    return render(request, 'accounts/account_info.html', context)

def edit_account(request):
    if request.method == 'POST':
        newfirstname = " ".join(request.POST.get('newfirstname').split())
        newlastname = " ".join(request.POST.get('newlastname').split())
        newusername = " ".join(request.POST.get('newusername').split())
        newemail = " ".join(request.POST.get('newemail').split())
        newphone = " ".join(request.POST.get('newphone').split())
        neworg = " ".join(request.POST.get('neworg').split())
        newprofilepic = request.FILES.get('newprofilepic')

        user = User.objects.get(username=request.user.username)
        profile = Profile.objects.get(user=user)
        
        if newusername != '':
            user.username = newusername
        
        if newfirstname != '':
            user.first_name = newfirstname.title()

        if newlastname != '':
            user.last_name = newlastname.title()
        
        if validate_email(newemail):
            user.email = newemail
        elif newemail != '':
            messages.error(request, 'Invalid email')

        if newprofilepic is not None:
            # Overwrite image
            try:
                if profile.image:
                    os.remove(profile.image.path)
            except FileNotFoundError as e:
                print(e)
            profile.image = newprofilepic

        profile.save()
        user.save()
        return redirect('account_info')

    profile = Profile.objects.get(user=request.user)
    context = {'profile':profile}
    return render(request, 'accounts/edit_account.html', context)



class UpdatePassword(PasswordChangeView):
    form_class = PasswordChangeForm
    success_url = '/edit_account'
    template_name = 'accounts/changepassword.html'