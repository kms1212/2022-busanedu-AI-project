from django.urls import path, include
from . import views

urlpatterns = [
    path('school', views.SchoolView.as_view()),
    path('data', views.MealDataView.as_view()),
    path('like', views.MealLikeView.as_view()),
    path('inference', views.MealInferenceView.as_view()),
    path('ranking', views.MealRankingView.as_view()),
    path('comment', views.MealCommentView.as_view()),
    path('randmeal', views.RandomMealsView.as_view()),
]
