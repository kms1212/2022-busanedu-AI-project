from django.db import models
from userAccount.models import User
import common

class School(models.Model):
    schoolcode1 = models.CharField(default="", max_length=5, blank=False, null=False)
    schoolcode2 = models.CharField(default="", max_length=10, blank=False, null=False)
    school_name = models.CharField(default="", max_length=100, blank=False, null=False)
    school_grade = models.CharField(default="", max_length=20, blank=False, null=False)
    location = models.CharField(default="", max_length=20, blank=False, null=False)
    found_type = models.CharField(default="", max_length=10, blank=False, null=False)
    school_addr = models.CharField(default="", max_length=100, blank=False, null=False)
    coedu = models.CharField(default="", max_length=10, blank=False, null=False)
    school_type = models.CharField(default="", max_length=10, blank=False, null=False)
    latitude = models.DecimalField(default=0, max_digits=11, decimal_places=9, blank=False, null=False)
    longitude = models.DecimalField(default=0, max_digits=11, decimal_places=8, blank=False, null=False)
    
class Meal(models.Model):
    class MealTime(models.IntegerChoices):
        NONE = 0, 'None'
        BREAKFAST = 1, 'Breakfast'
        LUNCH = 2, 'Lunch'
        DINNER = 3, 'Dinner'

    mealid = models.AutoField(primary_key=True)
    schoolcode1 = models.CharField(default="", max_length=5, blank=False, null=False)
    schoolcode2 = models.CharField(default="", max_length=10, blank=False, null=False)
    mealdate = models.DateField()
    mealtime = models.IntegerField(default=MealTime.NONE, choices=MealTime.choices, blank=False, null=False)
    menunames = models.JSONField()
    menulikes = models.ManyToManyField(User, related_name='meallikes')

    class Meta:
        unique_together = ('schoolcode1', 'schoolcode2', 'mealdate', 'mealtime')

    def __str__(self):
        return self.schoolcode1 + '-' + self.schoolcode2 + ':' + str(self.mealdate) + ' ' + str(Meal.MealTime(self.mealtime))

class MealInference(models.Model):
    inferenceid = models.AutoField(primary_key=True)
    meal = models.ForeignKey(Meal, on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    mealimage = models.ImageField(upload_to=common.PathAndRename('meal'), blank=False, null=True)
    jsondata = models.JSONField()

    def __str__(self):
        return str(self.meal) + ' @' + str(self.user)


class MealComment(models.Model):
    commentid = models.AutoField(primary_key=True)
    meal = models.ForeignKey(Meal, on_delete=models.CASCADE, null=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    comment = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return str(self.meal) + ' @' + str(self.user) + ': ' + self.comment
