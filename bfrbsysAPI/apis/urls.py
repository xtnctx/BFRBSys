from django.urls import path, include
from . import views
from knox import views as knox_views

urlpatterns = [
    path('', views.home, name='home'),
    path('api/', views.NeuralNetworkBuilder.as_view(), name='api'),
    # path('user/', views.UserCreation.as_view(), name='users'),
    path('api/auth/register/', views.RegisterAPI.as_view()),
    path('api/auth/login/', views.LoginAPI.as_view()),
    path('api/auth/user/', views.UserAPI.as_view()),
    path('api/auth/logout/', knox_views.LogoutView.as_view(), name='knox_logout'),
    path('api/auth/', include('knox.urls')),
]