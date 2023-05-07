from django.contrib import admin
from django.urls import path
from lot.views import *

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', index),
    path('entry', entry),
    path('exit', exit),
]
