from django.urls import path
from . import views


urlpatterns = [
    path('', views.home, name='home'),
    path('app/', views.app, name='app'),
    path('app/export/', views.train_model, name='export'), # successor of url: app/
    path('app/status/', views.get_status, name='status'), # successor of url: app/
]
