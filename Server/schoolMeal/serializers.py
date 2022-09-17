from .models import School, Meal, MealInference, MealComment
from rest_framework import serializers


class SchoolSerializer(serializers.ModelSerializer):
    class Meta:
        model = School
        fields = ['id',
                  'schoolcode1',
                  'schoolcode2',
                  'school_name',
                  'school_grade',
                  'location',
                  'found_type',
                  'school_addr',
                  'coedu',
                  'school_type',
                  'latitude',
                  'longitude']


class MealSerializer(serializers.ModelSerializer):
    likecnt = serializers.IntegerField(source="menulikes.count", read_only=True)

    class Meta:
        model = Meal
        fields = ['mealid',
                  'schoolcode1',
                  'schoolcode2',
                  'mealdate',
                  'mealtime',
                  'likecnt',
                  'menunames']


class MenuNameSerializer(serializers.ModelSerializer):
    menuid = serializers.IntegerField()
    menuname = serializers.CharField()
    menuname_filtered = serializers.CharField()
    menuname_classified = serializers.CharField()
    menu_allergy_info = serializers.ListField(child=serializers.IntegerField())

    class Meta:
        model = Meal
        fields = ['menuid',
                  'menuname',
                  'menuname_filtered',
                  'menuname_classified',
                  'menu_allergy_info']


class MealInferenceSerializer(serializers.ModelSerializer):
    class Meta:
        model = MealInference
        fields = ['inferenceid',
                  'meal',
                  'user',
                  'mealimage',
                  'jsondata']


class MealInferenceUploadSerializer(serializers.ModelSerializer):
    class Meta:
        model = MealInference
        fields = ['meal',
                  'mealimage',
                  'jsondata']


class MealCommentSerializer(serializers.ModelSerializer):
    class Meta:
        model = MealComment
        fields = ['commentid',
                  'meal',
                  'user',
                  'comment',
                  'created_at']
                  