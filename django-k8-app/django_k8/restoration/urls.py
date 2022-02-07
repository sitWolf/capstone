from django.urls import path
from django.views.generic import TemplateView
from django.http import Http404

from django_k8.restoration.views import (
    HomePageView
)

app_name = "restoration"
urlpatterns = [
    # path("~redirect/", view=user_redirect_view, name="redirect"),
    # path("~update/", view=user_update_view, name="update"),
    path("", view=HomePageView.as_view(), name="home"),
]
