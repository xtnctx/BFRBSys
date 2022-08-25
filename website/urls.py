from django.urls import path
from . import views


urlpatterns = [
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),
    path('register/', views.register_view, name='register'),

    path('account_info/', views.account_info, name='account_info'),
    path('account_info/edit_account/', views.edit_account, name='edit_account'),
    path('account_info/edit_account/change_password/', views.UpdatePassword.as_view(), name='change_password'),

]
