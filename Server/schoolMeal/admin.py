from django.contrib import admin
from .models import Meal, MealInference, MealComment

# Register your models here.
admin.site.register(Meal)
admin.site.register(MealInference)
admin.site.register(MealComment)
