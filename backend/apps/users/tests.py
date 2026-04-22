from rest_framework.test import APITestCase,APIClient
from django.contrib.auth import get_user_model
from rest_framework import status
# Create your tests here.

User=get_user_model()

class SignupLoginTest(APITestCase):

    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            email="test@gmail.com",
            password="Amankumar@12"
        )
        #! signup test
    def test_worker_signup(self):
        data = {"email": "simple@gmail.com", "password": "Amankumar@14"}
        res = self.client.post("/api/auth/signup/", data)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        self.assertIn("email", res.data)

    def test_signup_missing_fields(self):
        res = self.client.post("/api/auth/signup/", {})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        #! login test
    def test_login_success(self):
        data = {"email": "test@gmail.com", "password": "Amankumar@12"}
        res = self.client.post("/api/auth/Login/", data)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertIn("access", res.data)

    def test_login_missing_fields(self):
        res = self.client.post("/api/auth/Login/", {})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        
    #! resendverifictiom test
    def resend_verifiction_test(self):
        data= {"email":"simple@gmail.com"}
        res= self.client.post("/api/auth/resend-code/",data)
        self.assertEqual(res.status_code,status.HTTP_200_OK)
        self.assertIn("message",res.data)
    def resend_verifiction_test_fail(self):
        res= self.client.post("/api/auth/resend-code/",{})
        self.assertEqual(res.status_code,status.HTTP_400_BAD_REQUEST)
        
        
   
    