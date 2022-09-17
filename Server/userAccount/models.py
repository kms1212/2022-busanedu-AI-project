from django import utils
from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
import common

class UserManager(BaseUserManager):
    def create_user(self, userid, username, email, usertype, firstname, lastname, birthdate, schoolcode1,
                    schoolcode2, schoolgrade, schoolclass, schoolpid, allergyinfo, password=None):
        if not email:
            raise ValueError('Email field is empty')
        if not userid:
            raise ValueError('UserID field is empty')
        if not username:
            raise ValueError('UserName field is empty')
        if not firstname:
            raise ValueError('FirstName field is empty')
        if not lastname:
            raise ValueError('LastName field is empty')
        if not birthdate:
            raise ValueError('BirthDate field is empty')

        user = self.model(
            userid=userid,
            username=username,
            email=self.normalize_email(email),
            description="",
            profileimage=None,
            usertype=usertype,
            firstname=firstname,
            lastname=lastname,
            birthdate=birthdate,
            schoolcode1=schoolcode1,
            schoolcode2=schoolcode2,
            schoolgrade=schoolgrade,
            schoolclass=schoolclass,
            schoolpid=schoolpid,
            allergyinfo=allergyinfo)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, userid, username, email, usertype, firstname, lastname, birthdate,
                         schoolcode1, schoolcode2, schoolgrade, schoolclass, schoolpid, allergyinfo, password=None):
        user = self.create_user(userid=userid,
                                username=username,
                                email=self.normalize_email(email),
                                usertype=usertype,
                                firstname=firstname,
                                lastname=lastname,
                                birthdate=birthdate,
                                schoolcode1=schoolcode1,
                                schoolcode2=schoolcode2,
                                schoolgrade=schoolgrade,
                                schoolclass=schoolclass,
                                schoolpid=schoolpid,
                                allergyinfo=allergyinfo)
        user.is_admin = True
        user.set_password(password)
        user.save(using=self._db)
        return user


    def modify_user(self, userid, username = None, email = None, description = None, profileimage = None,
                    usertype = None, firstname = None, lastname = None, birthdate = None, schoolcode1 = None,
                    schoolcode2 = None, schoolgrade = None, schoolclass = None, schoolpid = None, allergyinfo = None):
        if User.objects.contains(userid):
            user = User.objects.filter(userid=userid)
            if username is not None:
                user.update(username=username)
            if email is not None:
                user.update(email=email)
            if description is not None:
                user.update(description=description)
            if profileimage is not None:
                user.update(profileimage=profileimage)
            if usertype is not None:
                user.update(usertype=usertype)
            if firstname is not None:
                user.update(firstname=firstname)
            if lastname is not None:
                user.update(lastname=lastname)
            if birthdate is not None:
                user.update(birthdate=birthdate)
            if schoolcode1 is not None:
                user.update(schoolcode1=schoolcode1)
            if schoolcode2 is not None:
                user.update(schoolcode2=schoolcode2)
            if schoolgrade is not None:
                user.update(schoolgrade=schoolgrade)
            if schoolclass is not None:
                user.update(schoolclass=schoolclass)
            if schoolpid is not None:
                user.update(schoolpid=schoolpid)
            if allergyinfo is not None:
                user.update(allergyinfo=allergyinfo)
            return user
        else:
            return None


class User(AbstractBaseUser):
    class UserType(models.IntegerChoices):
        USER_STUDENT = 0, 'User'

    userid = models.CharField(max_length=64, primary_key=True)
    username = models.CharField(max_length=64, blank=False)
    email = models.EmailField(default='', blank=False, unique=True)
    profileimage = models.ImageField(upload_to=common.PathAndRename('account'), null=True, blank=True)
    description = models.TextField(blank=True, null=True)
    usertype = models.IntegerField(default=UserType.USER_STUDENT, choices=UserType.choices, blank=False, null=False)
    firstname = models.CharField(max_length=32, blank=False, default="")
    lastname = models.CharField(max_length=32, blank=False, default="")
    birthdate = models.DateField(default=utils.timezone.now)
    schoolcode1 = models.CharField(max_length=10, default="")
    schoolcode2 = models.CharField(max_length=20, default="")
    schoolgrade = models.IntegerField(default=0)
    schoolclass = models.IntegerField(default=0)
    schoolpid = models.IntegerField(default=0)
    allergyinfo = models.JSONField(default=list)

    is_active = models.BooleanField(default=True)
    is_admin = models.BooleanField(default=False)

    objects = UserManager()

    USERNAME_FIELD = 'userid'
    EMAIL_FIELD = 'email'
    REQUIRED_FIELDS = ['username', 'email', 'usertype', 'firstname', 'lastname', 'birthdate']

    def has_perm(self, perm, obj=None):
        return True

    def has_module_perms(self, app_label):
        return True

    @property
    def is_staff(self):
        return self.is_admin

    def __str__(self):
        return self.userid
