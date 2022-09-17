from django.shortcuts import render
from rest_framework import generics, status, views
from .models import School, Meal, MealInference, MealComment
from .serializers import SchoolSerializer, MealInferenceSerializer, MealInferenceUploadSerializer, MealSerializer, MealCommentSerializer, MenuNameSerializer
from django.contrib.auth.mixins import LoginRequiredMixin
from django.db.models import Count, Q
from rest_framework.response import Response
import project.settings as settings
import Neis_API
from datetime import date, timedelta
import datetime
from .mealNameClassifier.classifier import classify
import re


def filter_menuname(menuname):
    string = ''

    for idx, char in enumerate(menuname):
        if char.isdigit():
            if menuname[idx + 1] == '.' or menuname[idx + 2] == '.':
                string = menuname[:idx]
                break

    if string[-1] == '(':
        string = string[:-1]

    if string == '':
        string = menuname

    if string[0] == '\t':
        string = string[1:]

    if string[-1] == '\n':
        string = string[:-1]
    
    while True:
        if string[-1] == ' ':
            string = string[:-1]
        else:
            break

    print(string, flush=True)
    return string


def get_allergyinfo(menuname):
    print('allergy' + menuname, flush=True)
    allergyinfo = re.findall(r'[0-9].{0,1}\.', menuname)
    
    return list(map(lambda str: int(str[:-1]), allergyinfo))


def get_mealdata(schoolcode1, schoolcode2, mealdate, mealtime):
    datestr = date.strftime(mealdate, '%y%m%d')
    meal = Meal.objects.filter(schoolcode1=schoolcode1, schoolcode2=schoolcode2, mealdate=mealdate, mealtime=mealtime)

    if meal.exists():
        if len(meal[0].menunames) == 0:
            return None
        else:
            return meal[0]
    else:
        try:
            meal = Neis_API.get_meal_data(region_code=schoolcode1, school_code=schoolcode2, meal_code=mealtime, date=datestr, key=settings.NEISAPI_KEY)
            if meal.count != 0:
                menulist = meal[0].dish_name.split('\n')
                print(menulist, flush=True)
                menunames = []
                for idx, menu in enumerate(menulist):
                    menunames.append({
                        'menuid': idx,
                        'menuname': menu,
                        'menuname_filtered': filter_menuname(menu),
                        'menuname_classified': classify(filter_menuname(menu)),
                        'menu_allergy_info': get_allergyinfo(menu)
                        })
                    print(menunames, flush=True)

                mealobj = Meal(schoolcode1=schoolcode1, schoolcode2=schoolcode2,
                            mealdate=mealdate, mealtime=mealtime,
                            menunames=MenuNameSerializer(menunames, many=True).data)
                mealobj.save()

                if len(mealobj.menunames) == 0:
                    return None
                else:
                    return mealobj
            else:
                return None
        except Exception as e:
            print(e)
            mealobj = Meal(schoolcode1=schoolcode1, schoolcode2=schoolcode2,
                        mealdate=mealdate, mealtime=mealtime,
                        menunames=MenuNameSerializer(None, many=True).data)
            mealobj.save()
            return None


def get_nextmealdata(schoolcode1, schoolcode2, mealdate, mealtime):
    for i in range(mealtime, 4):
        meal = get_mealdata(schoolcode1, schoolcode2, mealdate, i)
        if meal is not None:
            return meal

    mealdate += timedelta(days=1)

    for i in range(1, mealtime + 1):
        meal = get_mealdata(schoolcode1, schoolcode2, mealdate, i)
        if meal is not None:
            return meal

    return None


def get_prevmealdata(schoolcode1, schoolcode2, mealdate, mealtime):
    for i in reversed(range(1, mealtime + 1)):
        meal = get_mealdata(schoolcode1, schoolcode2, mealdate, i)
        if meal is not None:
            return meal

    mealdate -= timedelta(days=1)

    for i in reversed(range(mealtime, 4)):
        meal = get_mealdata(schoolcode1, schoolcode2, mealdate, i)
        if meal is not None:
            return meal

    return None


# Create your views here.

class SchoolView(views.APIView, LoginRequiredMixin):
    queryset = School.objects.all()
    http_method_names = ['get', 'post']
    
    def get(self, request):
        action = request.GET.get('action', 'code')

        if action == 'nearby':
            latitude = float(request.GET.get('latitude'))
            longitude = float(request.GET.get('longitude'))

            if latitude is not None or longitude is not None:
                school = School.objects.filter(latitude__range=(latitude - 0.01, latitude + 0.01), longitude__range=(longitude - 0.01, longitude + 0.01))
                serializer = SchoolSerializer(school, many=True)
                return Response({
                    'count': school.count(),
                    'data': serializer.data}, status=status.HTTP_200_OK)
            else:
                return Response(status=status.HTTP_400_BAD_REQUEST)
        elif action == 'code':
            schoolcode1 = request.GET.get('schoolcode1')
            schoolcode2 = request.GET.get('schoolcode2')

            if schoolcode1 is not None and schoolcode2 is not None:
                school = School.objects.filter(schoolcode1=schoolcode1, schoolcode2=schoolcode2)

                if school.exists():
                    serializer = SchoolSerializer(school[0])
                    return Response(serializer.data)
                else:
                    return Response("School data not found.", status=status.HTTP_404_NOT_FOUND)
            else:
                return Response(status=status.HTTP_400_BAD_REQUEST)
        elif action == 'search':
            keyword = request.GET.get('keyword')
            page = int(request.GET.get('page', 1))
            pagesz = int(request.GET.get('pagesize', 10))

            if keyword is not None:
                school = School.objects.filter(school_name__contains=keyword)
                datacnt = school.count()
            
                startidx = (page - 1) * pagesz
                endidx = startidx + pagesz

                if startidx > datacnt:
                    return Response("Data not found.", status=status.HTTP_404_NOT_FOUND)
                elif endidx > datacnt:
                    endidx = datacnt

                serializer = SchoolSerializer(school[startidx:endidx], many=True)
                
                return Response({
                    'count': datacnt,
                    'data': serializer.data}, status=status.HTTP_200_OK)
            else:
                return Response(status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response(status=status.HTTP_400_BAD_REQUEST)

    def post(self, request):
        action = request.POST.get('action', 'code')
        
        if action == 'code':
            codelist = request.data.get('codelist')
            schoollist = []

            for schcode in codelist:
                reqid = schcode['reqid']
                schoolcode1 = schcode['schoolcode1']
                schoolcode2 = schcode['schoolcode2']
                
                school = School.objects.filter(schoolcode1=schoolcode1, schoolcode2=schoolcode2)

                serializer = SchoolSerializer(school[0])
                if school.exists():
                    schoollist.append({
                        'reqid': reqid,
                        'data': serializer.data
                    })

            if len(schoollist) != 0:
                return Response(schoollist)
            else:
                return Response("School data not found.", status=status.HTTP_404_NOT_FOUND)
        else:
            return Response(status=status.HTTP_400_BAD_REQUEST)


# logged-in user only
class MealDataView(views.APIView, LoginRequiredMixin):
    queryset = Meal.objects.all()
    http_method_names = ['get', 'post']

    def get(self, request):
        action = request.GET.get('action', 'code')
        sc1 = request.GET.get('schoolcode1')
        sc2 = request.GET.get('schoolcode2')
        md = request.GET.get('mealdate')
        mt = request.GET.get('mealtime')
        
        if action == 'next':
            if sc1 is not None and sc2 is not None and md is not None:
                mdate = datetime.datetime.strptime(md, '%y%m%d').date()

                if mt is not None:
                    mt = int(mt)
                    
                    meal = get_nextmealdata(sc1, sc2, mdate, mt)
                    if meal is not None:
                        return Response(data=MealSerializer([meal], many=True).data, status=status.HTTP_200_OK)
                    
                    return Response(data="Meal not found in next 4 meal times", status=status.HTTP_404_NOT_FOUND)
                else:
                    return Response(data="Invalid request", status=status.HTTP_400_BAD_REQUEST)
            else:
                return Response(data="Invalid request", status=status.HTTP_400_BAD_REQUEST)
        elif action == 'prev':
            if sc1 is not None and sc2 is not None and md is not None:
                mdate = datetime.datetime.strptime(md, '%y%m%d').date()

                if mt is not None:
                    mt = int(mt)
                    
                    meal = get_prevmealdata(sc1, sc2, mdate, mt)
                    if meal is not None:
                        return Response(data=MealSerializer([meal], many=True).data, status=status.HTTP_200_OK)
                    
                    return Response(data="Meal not found in next 4 meal times", status=status.HTTP_404_NOT_FOUND)
                else:
                    return Response(data="Invalid request", status=status.HTTP_400_BAD_REQUEST)
            else:
                return Response(data="Invalid request", status=status.HTTP_400_BAD_REQUEST)
        elif action == 'code':
            if sc1 is not None and sc2 is not None and md is not None:
                mdate = datetime.datetime.strptime(md, '%y%m%d').date()

                if mt is not None:
                    meal = get_mealdata(sc1, sc2, mdate, mt)
                    
                    if meal is not None:
                        return Response(data=MealSerializer([meal], many=True).data, status=status.HTTP_200_OK)
                    else:
                        return Response(data="No meal found from NEIS", status=status.HTTP_404_NOT_FOUND)
                else:
                    meals = []
                    for i in range(1, 4):
                        meal = get_mealdata(sc1, sc2, mdate, i)
                        if meal is not None:
                            meals.append(meal)

                    return Response(data=MealSerializer(meals, many=True).data, status=status.HTTP_200_OK)
            else:
                return Response(data="Invalid request", status=status.HTTP_400_BAD_REQUEST)
        elif action == 'id':
            mid = request.GET.get('mealid')
            if mid is not None:
                meal = Meal.objects.filter(mealid=mid)
                if meal.exists():
                    return Response(data=MealSerializer(meal[0]).data, status=status.HTTP_200_OK)
                else:
                    return Response(data="Meal not found", status=status.HTTP_404_NOT_FOUND)
            else:
                return Response(data="Invalid request", status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response(data="Invalid request", status=status.HTTP_400_BAD_REQUEST)

    def post(self, request):
        action = request.data.get('action', 'code')
        
        if action == 'code':
            codelist = request.data.get('codelist')
            meallist = []

            for schcode in codelist:
                reqid = schcode['reqid']
                schoolcode1 = schcode['schoolcode1']
                schoolcode2 = schcode['schoolcode2']
                mealdate = schcode['mealdate']
                mealtime = int(schcode['mealtime'])
                
                mdate = datetime.datetime.strptime(mealdate, '%y%m%d').date()

                meal = get_mealdata(schoolcode1, schoolcode2, mdate, mealtime)
                serializer = MealSerializer(meal)
                
                if meal is not None:
                    meallist.append({
                        'reqid': reqid,
                        'data': serializer.data
                    })

            if len(meallist) != 0:
                return Response(meallist)
            else:
                return Response("Meal data not found.", status=status.HTTP_404_NOT_FOUND)
        elif action == 'next':
            codelist = request.data.get('codelist')
            meallist = []

            for schcode in codelist:
                reqid = schcode['reqid']
                schoolcode1 = schcode['schoolcode1']
                schoolcode2 = schcode['schoolcode2']
                mealdate = schcode['mealdate']
                mealtime = int(schcode['mealtime'])
                
                mdate = datetime.datetime.strptime(mealdate, '%y%m%d').date()

                meal = get_nextmealdata(schoolcode1, schoolcode2, mdate, mealtime)
                serializer = MealSerializer(meal)
                
                if meal is not None:
                    meallist.append({
                        'reqid': reqid,
                        'data': serializer.data
                    })

            if len(meallist) != 0:
                return Response(meallist)
            else:
                return Response("Meal data not found.", status=status.HTTP_404_NOT_FOUND)
        elif action == 'prev':
            codelist = request.data.get('codelist')
            meallist = []

            for schcode in codelist:
                reqid = schcode['reqid']
                schoolcode1 = schcode['schoolcode1']
                schoolcode2 = schcode['schoolcode2']
                mealdate = schcode['mealdate']
                mealtime = int(schcode['mealtime'])
                
                mdate = datetime.datetime.strptime(mealdate, '%y%m%d').date()

                meal = get_prevmealdata(schoolcode1, schoolcode2, mdate, mealtime)
                serializer = MealSerializer(meal)
                
                if meal is not None:
                    meallist.append({
                        'reqid': reqid,
                        'data': serializer.data
                    })

            if len(meallist) != 0:
                return Response(meallist)
            else:
                return Response("Meal data not found.", status=status.HTTP_404_NOT_FOUND)
        elif action == 'id':
            codelist = request.data.get('codelist')
            meallist = []

            for mealcode in codelist:
                reqid = mealcode['reqid']
                mealid = mealcode['mealid']
                
                meal = Meal.objects.get(mealid=mealid)
                serializer = MealSerializer(meal)
                
                if meal is not None:
                    meallist.append({
                        'reqid': reqid,
                        'data': serializer.data
                    })

            if len(meallist) != 0:
                return Response(meallist)
            else:
                return Response("Meal data not found.", status=status.HTTP_404_NOT_FOUND)
        else:
            return Response(status=status.HTTP_400_BAD_REQUEST)


# logged-in user only
class MealLikeView(views.APIView, LoginRequiredMixin):
    queryset = Meal.objects.all()
    http_method_names = ['get', 'post']

    def get(self, request):
        mealid = request.GET.get('mealid')
        action = request.GET.get('action')

        if mealid is not None and action is not None:
            if action == "count":
                meal = Meal.objects.get(mealid=mealid)
                return Response(data=meal.menulikes.count(), status=status.HTTP_200_OK)
            elif action == "stat":
                meal = Meal.objects.get(mealid=mealid)

                if meal.menulikes.filter(userid=request.user.userid).exists():
                    return Response(data=1, status=status.HTTP_200_OK)
                else:
                    return Response(data=0, status=status.HTTP_200_OK)
            else:
                return Response(data="Invalid request", status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response(data="Invalid request", status=status.HTTP_400_BAD_REQUEST)

    def post(self, request):
        mealid = request.data.get('mealid')
        if mealid is not None:
            meal = Meal.objects.get(mealid=mealid)
            user = request.user

            if meal.menulikes.filter(userid=request.user.userid).exists():
                meal.menulikes.remove(user)
            else:
                meal.menulikes.add(user)
            return Response(data="OK", status=status.HTTP_200_OK)
        else:
            return Response(data="Invalid request", status=status.HTTP_400_BAD_REQUEST)


class MealInferenceView(views.APIView, LoginRequiredMixin):
    http_method_names = ['get', 'post']
    queryset = MealInference.objects.all()
    serializer_class = MealInferenceUploadSerializer

    def get(self, request):
        mealid = request.GET.get('mealid', None)
        count = request.GET.get('count', None)

        if count is not None:
            count = int(count)

        if mealid is None:
            return Response(data="Invalid request", status=status.HTTP_400_BAD_REQUEST)
        else:
            mi = MealInference.objects.filter(meal=mealid)[:count]
            miser = MealInferenceSerializer(mi, many=True)

            return Response(data=miser.data, status=status.HTTP_200_OK)

    def post(self, request):
        mealid = int(request.data['mealid'])
        if mealid is None:
            return Response(data="Invalid request", status=status.HTTP_400_BAD_REQUEST)
        else:
            meal = Meal.objects.filter(mealid=mealid)
            if meal.exists():
                mi = MealInference(meal=meal[0], user=request.user, mealimage=request.data['mealimage'], jsondata=request.data['jsondata'])
                mi.save()

                return Response(data="OK", status=status.HTTP_200_OK)
            else:
                return Response(data="No corrosponding meal id found", status=status.HTTP_404_NOT_FOUND)


class MealRankingView(views.APIView, LoginRequiredMixin):
    queryset = Meal.objects.all()
    http_method_names = ['get']

    def get(self, request):
        start = int(request.GET.get('start', '0'))
        end = int(request.GET.get('end', '10'))
        meals = Meal.objects.filter(~Q(menunames=[])).annotate(ml_count=Count('menulikes')).filter(ml_count__gt=0)
        cnt = meals.count()

        if start >= cnt:
            return Response(data="No content available.", status=status.HTTP_204_NO_CONTENT)
        
        if end > cnt:
            end = cnt

        meal = meals.annotate(ml_count=Count('menulikes')).order_by('-ml_count')[start:end]
        mealser = MealSerializer(meal, many=True)

        return Response(data=mealser.data, status=status.HTTP_200_OK)


class MealCommentView(views.APIView, LoginRequiredMixin):
    queryset = MealComment.objects.all()
    http_method_names = ['get', 'post']

    def get(self, request):
        mealid = request.GET.get('mealid', None)
        if mealid is None:
            return Response(data="Invalid request", status=status.HTTP_400_BAD_REQUEST)
        else:
            comments = MealComment.objects.filter(meal=mealid)
            commentser = MealCommentSerializer(comments, many=True)
            return Response(data=commentser.data, status=status.HTTP_200_OK)

    def post(self, request):
        mealid = request.data['mealid']
        if mealid is None:
            return Response(data="Invalid request", status=status.HTTP_400_BAD_REQUEST)
        else:
            meal = Meal.objects.get(mealid=mealid)
            comment = MealComment(meal=meal, user=request.user, comment=request.data['comment'])
            comment.save()
            return Response(data="OK", status=status.HTTP_200_OK)

class RandomMealsView(views.APIView, LoginRequiredMixin):
    http_method_names = ['get']

    def get(self, request):
        schoolcode1 = request.GET.get('schoolcode1', None)
        schoolcode2 = request.GET.get('schoolcode2', None)

        inferences = Meal.objects.raw('''
        SELECT     DISTINCT mealtbl.*
        FROM       schoolMeal_mealinference inftbl
        INNER JOIN (SELECT     mealtbl.*
                    FROM       schoolMeal_meal mealtbl
                    INNER JOIN (SELECT   schoolcode1, schoolcode2, MAX(mealdate) AS maxmealdate
                                FROM     (SELECT     mealtbl.*, inftbl.inferenceid
                                        FROM       schoolMeal_mealinference inftbl
                                        INNER JOIN schoolMeal_meal mealtbl
                                                ON inftbl.meal_id = mealtbl.mealid AND mealtbl.menunames != '[]') mealtbl
                                WHERE    schoolcode1 != '%s' OR schoolcode2 != '%s'
                                GROUP BY schoolcode1, schoolcode2) latmealtbl
                            ON mealtbl.schoolcode1 = latmealtbl.schoolcode1
                                AND mealtbl.schoolcode2 = latmealtbl.schoolcode2
                                AND mealtbl.mealdate = latmealtbl.maxmealdate
                                AND mealtbl.menunames != '[]') mealtbl
                ON inftbl.meal_id = mealtbl.mealid
        ''' % (schoolcode1, schoolcode2))
        return Response(data=MealSerializer(inferences, many=True).data, status=status.HTTP_200_OK)
