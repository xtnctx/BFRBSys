from django.http import HttpResponse, JsonResponse
from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from validate_email import validate_email
from accounts.forms import RegisterForm
from base.models import TrainingStatus
from accounts.models import Profile
from django.contrib.auth.views import PasswordChangeView
from django.contrib.auth.forms import PasswordChangeForm
from django.contrib.auth.models import User
import os

# Create your views here.


def login_view(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        nextURL = request.POST.get('nextURL')

        user = authenticate(request, username=username, password=password)
        if user is None:
            return JsonResponse({'error': 'Invalid username or password'}, status=403)
        login(request, user)
        return JsonResponse({'success': 'Login successfull !', 'nextURL': nextURL}, status=200)

    return render(request, 'accounts/login.html', {})

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

@login_required(login_url='login')
def account_info(request):
    profile = Profile.objects.get(user=request.user)
    context = {'profile':profile}
    if request.method == 'POST':
        ...
    return render(request, 'accounts/account_info.html', context)


@login_required(login_url='login')
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
        

        # --- USER ---
        if newusername != '' and newusername != request.user.username:
            if User.objects.filter(username=newusername).exists():
                username_error = 'This username is already taken'
                return render(request, 'accounts/edit_account.html', 
                             {'profile':profile, 'username_error': username_error})
            user.username = newusername

        if newfirstname != '':
            user.first_name = newfirstname.title()

        if newlastname != '':
            user.last_name = newlastname.title()

        if validate_email(newemail):
            user.email = newemail
        elif newemail != '':
            email_error = 'Invalid email'
            return render(request, 'accounts/edit_account.html', 
                         {'profile':profile, 'email_error': email_error})


        # --- PROFILE ---
        if newprofilepic is not None:
            # Overwrite image
            try:
                if profile.image:
                    if profile.image.name != 'default.jpg':
                        os.remove(profile.image.path)
            except FileNotFoundError:
                pass
            # Uniquify - from username
            file_name, extension = newprofilepic.name.split('.')
            newprofilepic.name = f'{file_name}_{request.user.username}'+f'.{extension}'
            profile.image = newprofilepic

        if newphone != '':
            if not newphone.isdecimal():
                phone_error = 'Must be a number'
                return render(request, 'accounts/edit_account.html', 
                             {'profile':profile, 'phone_error': phone_error})
            profile.phone = newphone

        if neworg != '':
            profile.organization = neworg

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