from django.urls import path
from . import views


urlpatterns = [
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),
    path('register/', views.register_view, name='register'),

    path('<str:username>/', views.account_info, name='profile'),
    path('<str:username>/edit/', views.edit_account, name='edit-profile'),
    path('<str:username>/edit/changepass/', views.UpdatePassword.as_view(), name='change-password'),

]
