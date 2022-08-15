from django.urls import path
from . import views


urlpatterns = [
    path('', views.home, name='home'),
    path('app/', views.app, name='app'),
    path('app/export/', views.export_data, name='export'), # successor of url: app/
]
